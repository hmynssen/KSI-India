#!/bin/bash 
Usage() {
    echo -e ""
    echo -e "Create a surface between white matter and pial."
    echo -e "There must exist *h.pial and *h.white in the folder ouput/subj/surf"
    echo -e ""
    echo -e "Usage: `basename $0` -s <Zebra> -o </path/to/Zebra/surf> "
    echo -e ""
    echo -e "Compulsory Arguments"
    echo -e " -s <string> \t\t Subject name"
    echo -e " -o <string> \t\t Path to output folder"
    echo -e ""
    echo -e "Example:  ./`basename $0` -s "FB141" \
    -o \"../results\" \
    "
    echo -e ""
    exit 1
}


if [ $# -lt 2 ]; then 
    Usage
    exit 0
else
    mgz_dir='./'
    out_dir='./'
    KSI=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    while getopts ":s:o:h" opt ; do 
        case $opt in
            s) subj=`echo $OPTARG`;;
            o) out_dir=`echo $OPTARG`
                if ! [ -d "${out_dir}" ]; then mkdir "${out_dir}"; fi;;
            \?) echo -e "Invalid option:  -$OPTARG" >&2; Usage; exit 1;;
        esac 
    done
fi

declare -a hemispheres=("lh" "rh")
export SUBJECTS_DIR="${out_dir}"
cd "${out_dir}/${subj}"

if ! [ -d "${out_dir}/${subj}/surf" ]; then echo "Could not found surf directory with pial files"; exit; fi
cd surf

for hemi in ${hemispheres[@]}; do

    if ! [ -f "${out_dir}/${subj}/surf/${hemi}.white" ]; then echo "Could not found surf directory with pial files"; exit; fi
    if ! [ -f "${out_dir}/${subj}/surf/${hemi}.pial" ]; then echo "Could not found surf directory with pial files"; exit; fi
    echo ' '
    echo ' '
    echo '----------MID SURFACE CALCULATION---------'
    mris_convert ${hemi}.white ${hemi}.white.surf.gii
    mris_convert ${hemi}.pial ${hemi}.pial.surf.gii
    wb_command  -surface-average ${hemi}.midthickness.surf.gii -surf ${hemi}.white.surf.gii -surf ${hemi}.pial.surf.gii

    echo ' '
    echo ' '
    echo '----------SULCI SURFACE GENERATION---------'
    wb_command -surface-smoothing ${hemi}.midthickness.surf.gii .5 15 ${hemi}.midthickness_smoothed_5_15.surf.gii
    wb_command -surface-smoothing ${hemi}.midthickness.surf.gii .2 15 ${hemi}.midthickness_smoothed_2_15.surf.gii

    mris_convert ${hemi}.midthickness.surf.gii ${subj}_${hemi}.midthickness.stl
    mris_convert ${hemi}.midthickness_smoothed_5_15.surf.gii ${subj}_${hemi}.midthickness_smoothed_5_15.stl
    mris_convert ${hemi}.midthickness_smoothed_2_15.surf.gii ${subj}_${hemi}.midthickness_smoothed_2_15.stl

done