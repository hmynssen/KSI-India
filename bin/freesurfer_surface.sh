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
    echo -e " -E <string> \t\t Erase brightness value; use quotes/string declaration for  \n\t\t\t possible multple values.  "
    echo -e ""
    echo -e "Optional Arguments" 
    echo -e " -o <string> \t\t Path to output folder"
    echo -e ""
    echo -e "Toggle Arguments" 
    echo -e " -h returns this help message"
    echo -e ""
    echo -e "Example:  ./`basename $0` -i ../data/FB141/FB141_BrainVolume_SkullStripped.nii.gz \
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
if ! [ -d "${out_dir}/${subj}/label" ]; then mkdir "${out_dir}/${subj}/label"; fi

cd "${out_dir}/${subj}"


## Copying, renaming and conforming stuff to match FreeSurfer's requirements
cp "${mgz_brain_file}" "./mri/brain.nii.gz"
mri_convert "./mri/brain.nii.gz" "./mri/brain.mgz" --conform
cp "./mri/brain.mgz" "./mri/brainmask.mgz"
cp "./mri/brain.mgz" "./mri/brain.finalsurfs.mgz"
cp "./mri/brain.mgz" "./mri/norm.mgz"
rm -rf "./mri/brain.nii.gz"

cp "${white_file}" "./mri/wm.nii.gz"
mri_convert "./mri/wm.nii.gz" "./mri/wm.seg.mgz" --conform
cp "./mri/wm.seg.mgz" "./mri/wm.mgz"
cp "./mri/wm.seg.mgz" "./mri/wm.asegedit.mgz"

fslmaths "./mri/wm.nii.gz" -mul "${lh_file}" "./mri/lh_wm.nii.gz"
fslmaths "./mri/lh_wm.nii.gz" -mul 255 "./mri/lh_wm.nii.gz"
fslmaths "./mri/wm.nii.gz" -mul "${rh_file}" "./mri/rh_wm.nii.gz"
fslmaths "./mri/rh_wm.nii.gz" -mul 127 "./mri/rh_wm.nii.gz"
fslmaths "./mri/lh_wm.nii.gz" -add "./mri/rh_wm.nii.gz" "./mri/filled.nii.gz"
mri_convert "./mri/filled.nii.gz" "./mri/filled.mgz" --conform
mri_convert "./mri/filled.mgz" "./mri/filled.nii.gz"
fslmaths "./mri/filled.nii.gz" -thr 255 "./mri/filled-pretess255.nii.gz"
fslmaths "./mri/filled-pretess255.nii.gz" -uthr 255 "./mri/filled-pretess255.nii.gz"
fslmaths "./mri/filled.nii.gz" -thr 127 "./mri/filled-pretess127.nii.gz"
fslmaths "./mri/filled-pretess127.nii.gz" -uthr 127 "./mri/filled-pretess127.nii.gz"
fslmaths "./mri/filled-pretess127.nii.gz" -add "./mri/filled-pretess127.nii.gz" "./mri/filled.nii.gz"
mri_convert "./mri/filled.nii.gz" "./mri/filled.mgz"
rm -f "./mri/wm.nii.gz" "./mri/lh_wm.nii.gz""./mri/rh_wm.nii.gz" "./mri/filled.nii.gz"
rm -f "./mri/filled-pretess255.nii.gz" "./mri/filled-pretess127.nii.gz"

mri_pretess "./mri/filled.mgz" 255 "./mri/norm.mgz" "./mri/filled-pretess255.mgz"
mri_tessellate "./mri/filled-pretess255.mgz" 255 "./surf/lh.orig.nofix"
mri_pretess "./mri/filled.mgz" 127 "./mri/norm.mgz" "./mri/filled-pretess127.mgz"
mri_tessellate "./mri/filled-pretess127.mgz" 127 "./surf/rh.orig.nofix"
rm -f "./mri/filled-pretess255.mgz" "./mri/filled-pretess127.mgz"

for hemi in ${hemispheres[@]}; do
    cd surf
    
    echo ' '
    echo ' '
    echo '----------MAIN COMPONENT---------'
    mris_extract_main_component ${hemi}.orig.nofix ${hemi}.orig.nofix

    echo ' '
    echo ' '
    echo '----------SMOOTH---------'
    mris_smooth -nw ${hemi}.orig.nofix ${hemi}.smoothwm.nofix

    echo ' '
    echo ' '
    echo '----------INFLATE---------'
    mris_inflate -no-save-sulc ${hemi}.smoothwm.nofix ${hemi}.inflated.nofix
    mris_sphere -q ${hemi}.inflated.nofix ${hemi}.qsphere.nofix 
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
    rm ${hemi}.inflated

    echo ' '
    echo ' '
    echo '----------MAKE_SURFACE---------'
    mris_make_surfaces -noaseg -whiteonly -noaparc -mgz -T1 brain.finalsurfs ${subj} ${hemi}

    echo ' '
    echo ' '
    echo '----------SMOOTH2---------'
    mris_smooth -n 3 -nw ${hemi}.white ${hemi}.smoothwm

    echo ' '
    echo ' '
    echo '----------INFLATE2---------'
    mris_inflate ${hemi}.smoothwm ${hemi}.inflated

    echo ' '
    echo ' '
    echo '----------CURVS1---------'
    mris_curvature -seed 1234  -w ${hemi}.white

    echo ' '
    echo ' '
    echo '----------CURVS2---------'
    mris_curvature -seed 1234 -thresh .999 -n -a 5 -w -distances 10 10 ${hemi}.inflated

    echo ' '
    echo ' '
    echo '----------CURVS3---------'
    mris_curvature_stats -m --writeCurvatureFiles -G -o '../stats/${hemi}.curv.stats' -F smoothwm ${subj} ${hemi} curv sulc

    echo ' '
    echo ' '
    echo '----------RECONALL3---------'
    mris_sphere -seed 1234  ${hemi}.inflated ${hemi}.sphere
    mris_register -curv ${hemi}.sphere $FREESURFER_HOME/average/${hemi}.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ${hemi}.sphere.reg
    mris_jacobian ${hemi}.white ${hemi}.sphere.reg ${hemi}.jacobian_white
    mrisp_paint -a 5 $FREESURFER_HOME/average/${hemi}.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ${hemi}.sphere.reg ${hemi}.avg_curv
    mris_ca_label -l ../label/${hemi}.cortex.label -aseg ../mri/aseg.presurf.mgz ${subj} ${hemi} ${hemi}.sphere.reg $FREESURFER_HOME/average/${hemi}.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ${hemi}.aparc.annot

    echo ' '
    echo ' '
    echo '----------PIAL SURFACE---------'
    mris_make_surfaces -orig_white ${hemi}.white -orig_pial ${hemi}.white -noaseg -noaparc -mgz -T1 brain.finalsurfs ${subj} ${hemi}

    mris_convert ${hemi}.pial ${hemi}_pial.stl
    mris_convert ${hemi}.white ${hemi}_wm.stl
done

echo ' '
echo ' '
echo '----------Volumetric mask---------'
# only with both hemispheres
mris_volmask --aseg_name brain --save_ribbon ${subj}