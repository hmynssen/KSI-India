#!/bin/bash 
Usage() {
    echo -e ""
    echo -e "Creates 4 binary masks that can be used for surface reconstruction. Two for each hemisphere of the pial surface and the white matter surface"
    echo -e ""
    echo -e "Usage: `basename $0` [options] -i <brain_volume.nii.gz> -m <brain_mask.nii.gz> \
    -rh <rh.nii.gz> -lh <lh.nii.gz> -gm <brigthness values> -wm <brigthness values> "
    echo -e ""
    echo -e "Compulsory Arguments"
    echo -e " -i <image.nii.gz> \t Skull stripped image; must be nii or nii.gz file"
    echo -e " -m <mask.nii.gz> \t Binary mask; must be nii or nii.gz file"
    echo -e " -R <mask.nii.gz> \t Right hemisphere; must be nii or nii.gz file"
    echo -e " -L <mask.nii.gz> \t Left hemisphere; must be nii or nii.gz file"
    echo -e " -G <string> \t\t GM or Cortical plate brightness value; use quotes/string \n\t\t\t declaration for possible multple values "
    echo -e " -P <mask.nii.gz> \t Pial surface; must be nii or nii.gz file"
    echo -e " -W <string> \t\t GM or Cortical plate brightness value; use quotes/string \n\t\t\t declaration for possible multple values "
    echo -e " -E <string> \t\t Erase brightness value; use quotes/string declaration for  \n\t\t\t possible multple values.  "
    echo -e ""
    echo -e "Optional Arguments" 
    echo -e " -o <string> \t\t Path to output folder"
    echo -e ""
    echo -e "Toggle Arguments" 
    echo -e " -h returns this help message"
    echo -e ""
    echo -e "Example:  ./`basename $0` -s "FB141" \
    -i ../data/FB141/FB141_BrainVolume_SkullStripped.nii.gz \
    -m ../data/FB141/FB141_BrainMask.nii.gz \
    -R ../data/FB141/rh.nii.gz \
    -L ../data/FB141/lh.nii.gz \
    -o \"../results\" \
    "
    echo -e ""
    exit 1

}


if [ $# -lt 6 ]; then 
    Usage
    exit 0
else
    mgz_dir='./'
    out_dir='./'
    save_name=''
    KSI=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    while getopts ":s:i:m:P:W:R:L:o:h" opt ; do 
        case $opt in
            s) subj=`echo $OPTARG`;;
            i) mgz_brain_file=`echo $OPTARG`; base_name=$(basename ${mgz_brain_file});;
            m) mgz_mask_file=`echo $OPTARG`; mask_base_name=$(basename ${mgz_mask_file});;
            P) pial_file=`echo $OPTARG`;;
            W) white_file=`echo $OPTARG`;;
            R) rh_file=`echo $OPTARG`;;
            L) lh_file=`echo $OPTARG`;;
            o) out_dir=`echo $OPTARG`
                if ! [ -d "${out_dir}" ]; then mkdir "${out_dir}"; fi;;
            \?) echo -e "Invalid option:  -$OPTARG" >&2; Usage; exit 1;;
        esac 
    done
fi

declare -a hemispheres=("lh" "rh")
export SUBJECTS_DIR="${out_dir}"


## Making folder structure for Freesurfer
if ! [ -d "${out_dir}/${subj}" ]; then mkdir "${out_dir}/${subj}"; fi
if ! [ -d "${out_dir}/${subj}/mri" ]; then mkdir "${out_dir}/${subj}/mri"; fi
if ! [ -d "${out_dir}/${subj}/surf" ]; then mkdir "${out_dir}/${subj}/surf"; fi
# if ! [ -d "${out_dir}/${subj}/label" ]; then mkdir "${out_dir}/${subj}/label"; fi
if ! [ -d "${out_dir}/${subj}/stats" ]; then mkdir "${out_dir}/${subj}/stats"; fi
if ! [ -d "${out_dir}/${subj}/scripts" ]; then mkdir "${out_dir}/${subj}/scripts"; fi


cd "${out_dir}/${subj}"

## Checking for overlaping wm and pial masks
num1=$(fslstats "${pial_file}" -k "${white_file}" -V | grep -oE '[0-9]+([.][0-9]+)?' | head -1)

if ! [ $num1 -eq 0 ]; then
    echo "Pial and white matter masks are overlaping"
    exit
fi

##In case someone skiped the previous file creations and is using this script directly
##If you used the pial_wm_masks.sh, you should already have this files
if ! [ -f "../wm.nii.gz" ]; then cp "${white_file}" "../wm.nii.gz"; fi
if ! [ -f "../pial.nii.gz" ]; then cp "${pial_file}" "../pial.nii.gz"; fi
if ! [ -f "../brain_bin.nii.gz" ]; then cp "${mgz_mask_file}" "../brain_bin.nii.gz"; fi
if ! [ -f "../${base_name}" ]; then cp "${mgz_brain_file}" "../${base_name}"; fi

if [[ ! -f "../pial_full.nii.gz" || !  -f "../lh_pial.nii.gz" || !  -f "../rh_pial.nii.gz"  || !  -f "../lh_wm.nii.gz"  || !  -f "../rh_wm.nii.gz" ]]; then
    fslmaths "${pial_file}" -add "${white_file}" -bin "../pial_full.nii.gz"
    fslmaths "../pial_full.nii.gz" -mul "${lh_file}" "../lh_pial.nii.gz"
    fslmaths "../pial_full.nii.gz" -mul "${rh_file}" "../rh_pial.nii.gz"
    fslmaths "../wm.nii.gz" -mul "${lh_file}" "../lh_wm.nii.gz"
    fslmaths "../wm.nii.gz" -mul "${rh_file}" "../rh_wm.nii.gz"
fi

## Copying, renaming and conforming stuff to match FreeSurfer's requirements
cp "${mgz_brain_file}" "./mri/brain.nii.gz"
fslmaths "../wm.nii.gz" -mul 110 "./mri/brain.nii.gz"
fslmaths "${pial_file}" -mul "${mgz_brain_file}" -inm 1 -mul 70 -nan "./mri/brain_pial.nii.gz" 
fslmaths "./mri/brain.nii.gz" -add "./mri/brain_pial.nii.gz" -nan "./mri/brain.nii.gz"
mri_convert "./mri/brain.nii.gz" "./mri/brain.mgz" #--conform

if [ -f "../csf_mask.nii.gz" ]; then 
    fslmaths "../csf_mask.nii.gz" -mul 255 -nan "./mri/brain_csf_mask.nii.gz" -odt int
fi

python3 "${KSI}/random-noise.py" -p "${pial_file}" -w "${white_file}" -o "${out_dir}/${subj}/mri"
fslmaths "./mri/brain.finalsurfs.nii.gz" -nan "./mri/brain.finalsurfs.nii.gz"
mri_convert "./mri/brain.finalsurfs.nii.gz" "./mri/brain.finalsurfs.mgz"
cp "./mri/brain.finalsurfs.mgz" "./mri/norm.mgz"

fslmaths "./mri/brain.finalsurfs.nii.gz" -mul "${lh_file}" -nan "./mri/lh_brain.nii.gz"
fslmaths "./mri/brain.finalsurfs.nii.gz" -mul "${rh_file}" -nan "./mri/rh_brain.nii.gz"
mri_convert "./mri/lh_brain.nii.gz" "./mri/lh.brain.finalsurfs.mgz" #--conform
mri_convert "./mri/rh_brain.nii.gz" "./mri/rh.brain.finalsurfs.mgz" #--conform

rm -rf "./mri/brain.nii.gz"
rm -rf "./mri/brain.finalsurfs.nii.gz"
rm -rf "./mri/rh_brain.nii.gz"
rm -rf "./mri/lh_brain.nii.gz"
rm -rf "./mri/brain_pial.nii.gz"
rm -rf "./mri/brain_csf_mask.nii.gz"

cp "${white_file}" "./mri/wm.nii.gz"
fslmaths "./mri/wm.nii.gz" -mul 110 "./mri/wm.nii.gz"
mri_convert "./mri/wm.nii.gz" "./mri/wm.seg.mgz" #--conform
cp "./mri/wm.seg.mgz" "./mri/wm.mgz"
cp "./mri/wm.seg.mgz" "./mri/wm.asegedit.mgz"

fslmaths "${white_file}" -mul "${lh_file}" "./mri/lh_wm.nii.gz"
fslmaths "./mri/lh_wm.nii.gz" -mul 255 -nan "./mri/lh_wm.nii.gz" -odt int
fslmaths "${white_file}" -mul "${rh_file}" "./mri/rh_wm.nii.gz"
fslmaths "./mri/rh_wm.nii.gz" -mul 127 -nan "./mri/rh_wm.nii.gz" -odt int
fslmaths "./mri/lh_wm.nii.gz" -add "./mri/rh_wm.nii.gz" -nan "./mri/filled.nii.gz" -odt int
mri_convert "./mri/filled.nii.gz" "./mri/filled.mgz" #--conform

fslmaths "./mri/wm.nii.gz" -mul 0 "./mri/aseg.nii.gz"
fslmaths "./mri/aseg.nii.gz" -add ../lh_wm.nii.gz -mul 2 "./mri/aseg_lh_wm.nii.gz"
fslmaths "./mri/aseg.nii.gz" -add ../lh_pial.nii.gz -sub ../lh_wm.nii.gz -mul 3 "./mri/aseg_lh_pial.nii.gz"
fslmaths "./mri/aseg.nii.gz" -add ../rh_wm.nii.gz -mul 41 "./mri/aseg_rh_wm.nii.gz"
fslmaths "./mri/aseg.nii.gz" -add ../rh_pial.nii.gz -sub ../rh_wm.nii.gz -mul 42 "./mri/aseg_rh_pial.nii.gz"
fslmaths "./mri/aseg.nii.gz" -add "./mri/aseg_lh_wm.nii.gz" \
            -add "./mri/aseg_lh_pial.nii.gz" \
            -add "./mri/aseg_rh_wm.nii.gz" \
            -add "./mri/aseg_rh_pial.nii.gz" -nan "./mri/aseg.nii.gz" -odt int
rm -f "./mri/aseg_lh_wm.nii.gz" "./mri/aseg_lh_pial.nii.gz" "./mri/aseg_rh_wm.nii.gz" "./mri/aseg_rh_pial.nii.gz"
mri_convert "./mri/aseg.nii.gz" "./mri/aseg.mgz" #--conform
cp "./mri/aseg.mgz" "./mri/aseg.presurf.mgz"

mri_pretess "./mri/filled.mgz" 255 "./mri/norm.mgz" "./mri/filled-pretess255.mgz"
mri_tessellate "./mri/filled-pretess255.mgz" 255 "./surf/lh.orig.nofix"
mri_pretess "./mri/filled.mgz" 127 "./mri/norm.mgz" "./mri/filled-pretess127.mgz"
mri_tessellate "./mri/filled-pretess127.mgz" 127 "./surf/rh.orig.nofix"
rm -f "./mri/filled-pretess255.mgz" "./mri/filled-pretess127.mgz"

rm -rf "./mri/aseg.nii.gz"
rm -rf "./mri/filled.nii.gz"
rm -rf "./mri/lh_wm.nii.gz"
rm -rf "./mri/rh_wm.nii.gz"
rm -rf "./mri/wm.nii.gz"
cd surf

for hemi in ${hemispheres[@]}; do

    echo ' '
    echo ' '
    echo '----------MAIN COMPONENT---------'
    mris_extract_main_component ${hemi}.orig.nofix ${hemi}.orig.nofix
    cp ${hemi}.orig.nofix ${hemi}.smoothwm.nofix
    echo ' '
    echo ' '
    echo '----------SMOOTH---------'
    mris_smooth -nw ${hemi}.orig.nofix ${hemi}.smoothwm.nofix

    echo ' '
    echo ' '
    echo '----------INFLATE---------'
    mris_inflate -n 1000 -no-save-sulc ${hemi}.smoothwm.nofix ${hemi}.inflated.nofix
    mris_sphere -q -seed 1234 ${hemi}.inflated.nofix ${hemi}.qsphere.nofix 
    cp ${hemi}.orig.nofix ${hemi}.orig
    cp ${hemi}.inflated.nofix ${hemi}.inflated

    
    echo ' '
    echo ' '
    echo '----------FIX_TOPOLOGY---------'
    mris_fix_topology -seed 1234 -mgz -sphere qsphere.nofix -ga ${subj} ${hemi}

    echo ' '
    echo ' '
    echo '----------EULER---------'
    mris_euler_number ${hemi}.orig

    echo ' '
    echo ' '
    echo '----------INTERSECTION---------'
    mris_remove_intersection ${hemi}.orig ${hemi}.orig

    # rm ${hemi}.inflated

    # echo ' '
    # echo ' '
    # echo '----------MAKE_SURFACE---------'
    # mris_make_surfaces -aseg ../mri/aseg.presurf -whiteonly -noaparc -mgz -T1 brain.finalsurfs ${subj} ${hemi}
    # cp ${hemi}.white ${hemi}.white.preaparc

    # echo ' '
    # echo ' '
    # echo '----------SMOOTH2---------'
    # mris_smooth -n 3 -nw ${hemi}.white.preaparc ${hemi}.smoothwm

    # echo ' '
    # echo ' '
    # echo '----------INFLATE2---------'
    # mris_inflate ${hemi}.smoothwm ${hemi}.inflated

    # echo ' '
    # echo ' '
    # echo '----------CURVS1---------'
    # mris_curvature -seed 1234 -w ${hemi}.white.preaparc

    # echo ' '
    # echo ' '
    # echo '----------CURVS2---------'
    # mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 ${hemi}.inflated

    # echo ' '
    # echo ' '
    # echo '----------CURVS3---------'
    # mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/${hemi}.curv.stats -F smoothwm ${subj} ${hemi} curv sulc

    # echo ' '
    # echo ' '
    # echo '----------RECONALL3---------'
    # mris_sphere -seed 1234  ${hemi}.inflated ${hemi}.sphere
    # mris_register -curv ${hemi}.sphere $FREESURFER_HOME/average/${hemi}.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ${hemi}.sphere.reg
    # mris_jacobian ${hemi}.white ${hemi}.sphere.reg ${hemi}.jacobian_white
    # mrisp_paint -a 5 $FREESURFER_HOME/average/${hemi}.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ${hemi}.sphere.reg ${hemi}.avg_curv
    # mris_ca_label -l ../label/${hemi}.cortex.label -aseg ../mri/aseg.presurf.mgz ${subj} ${hemi} ${hemi}.sphere.reg $FREESURFER_HOME/average/${hemi}.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ${hemi}.aparc.annot

    echo ' '
    echo ' '
    echo '----------PIAL SURFACE---------'
    #tol=1.0e-04, sigma=2.0, host=unkno, nav=4, nbrs=2, l_repulse=5.000, l_tspring=25.000, l_nspring=1.000, l_intensity=0.200, l_curv=1.000
    mris_make_surfaces -noaseg -noaparc -mgz -T1 ${hemi}.brain.finalsurfs ${subj} ${hemi}
    mris_convert ${hemi}.pial ${subj}_${hemi}_pial.stl
    mris_convert ${hemi}.white ${subj}_${hemi}_wm.stl
done

echo ' '
echo ' '
echo '----------Volumetric mask---------'
# only with both hemispheres
mris_volmask --aseg_name aseg.presurf --save_ribbon ${subj}
mri_convert "../mri/ribbon.mgz" "../mri/ribbon.nii.gz"

echo ' '
echo ' '
echo "Surface reconstrution for ${subj} has ended"
echo ' '
echo ' '