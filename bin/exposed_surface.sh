#!/bin/bash 
Usage() {
    echo -e ""
    echo -e "Creates a .stl file that represents the exposed surface of a given object"
    echo -e ""
    echo -e "Usage: `basename $0` -i <surface.stl> -s <exposed.stl> -R <radius> -B <cutoff> "
    echo -e ""
    echo -e "Compulsory Arguments"
    echo -e " -i <surface.stl> \t\t Pial surface; must be .stl format because of FreeSurfer"
    echo -e ""
    echo -e "Optional Arguments" 
    echo -e " -R <int> \t\t Ball radius; default is 15 mm"
    echo -e " -B <int> \t\t Cuttoff value from the gaussian blur; default is 15 from reference 255 max"
    echo -e " -s <string> \t\t Save name; default is \${basename}_exposed.stl"
    echo -e " -o <string> \t\t Path to output folder"
    echo -e ""
    echo -e "Toggle Arguments" 
    echo -e " -S toggles smooth option with mris_smooth from FreeSurfer"
    echo -e " -h returns this help message"
    echo -e ""
    echo -e "Example:  ./`basename $0` -i pial.stl -R 15 -B 15 "
    echo -e ""
    exit 1
}

if [ $# -lt 1 ]; then 
    Usage
    exit 0
else
    save_name=''
    out_dir='./'
    radius=15
    blur=15
    KSI=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    smooth=false
    while getopts ":i:R:B:s:o:Sh" opt ; do 
        case $opt in
            i) surf_file=`echo $OPTARG`; base_name=$(basename ${surf_file});;
            R) radius=`echo $OPTARG`;;
            B) blur=`echo $OPTARG`;;
            s) save_name=`echo $OPTARG`;;
            o) out_dir=`echo $OPTARG`
                if ! [ -d "${out_dir}" ]; then mkdir "${out_dir}"; fi ;;
            S) smooth=true;;
            h) Usage; exit 0;;
            \?) echo -e "Invalid option:  -$OPTARG" >&2; Usage; exit 1;;
        esac 
    done
fi

if ! [ -f "${surf_file}" ]; then echo -e "CHECK IMAGE FILE PATH"; Usage; exit 1; fi
if ! [ "${surf_file: -4}" == ".stl" ]; then echo "CHECK IMAGE FILE EXTENSION"; Usage; exit 1 ; fi

if [ "${save_name}" == '' ]; then save_name="${base_name}_exposed"; fi
if [ "${save_name: -4}" == ".stl" ]; then save_name="${filename%.*}"; fi

## copy original image to results folder
## Makes life easier
if ! [ -f "${out_dir}/${base_name}" ]; then cp "${surf_file}" "${out_dir}/${base_name}"; fi

## This step will voxelize the surface
## Conversion to .pial is necessary for compatibility with FreeSurfer
## Watch out! Surface input format must be .stl, any other format is not properly
## handled by FreeSurfer unfortunately
mris_convert "${surf_file}" "${out_dir}/${base_name}.pial"
mris_fill -c -r 1 "${out_dir}/${base_name}.pial" "${out_dir}/${base_name}.pial.filled.mgz"

## Remember that mgz format is something that basically only FreeSurfer uses
## The rest of planet earth uses Nifti...
mri_convert "${out_dir}/${base_name}.pial.filled.mgz" "${out_dir}/${base_name}.pial.filled.nii"
rm -rf "${out_dir}/${base_name}.pial.filled.mgz"

## The rolling ball method, as the name says, rolls a ball of radius R over the surface
## All points in which the surface of the sphere and the cortical surface touch one another
## will be used to reconstruct the exposed surface via marching cubes algorithm.
python "${KSI}/rolling_ball.py" "${out_dir}/${base_name}.pial.filled.nii" -b ${blur} -d ${radius} -s "${out_dir}/${save_name}.stl"
rm -rf "${out_dir}/${base_name}.pial.filled.nii"
rm -rf "${out_dir}/${base_name}.pial"


## Self explanatory
if [ ${smooth} == true ]; then
    mris_smooth "${out_dir}/${save_name}.stl" "${out_dir}/${save}_smooth.stl"
fi
echo -e ""
