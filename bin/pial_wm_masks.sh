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
    -G \"1\" -E \"2 6 8 11\" \
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
    while getopts ":i:m:R:L:G:E:o:h" opt ; do 
        case $opt in
            i) mgz_brain_file=`echo $OPTARG`; base_name=$(basename ${mgz_brain_file});;
            m) mgz_mask_file=`echo $OPTARG`; mask_base_name=$(basename ${mgz_mask_file});;
            R) rh_file=`echo $OPTARG`;;
            L) lh_file=`echo $OPTARG`;;
            G) declare -a chosen_seg=(`echo $OPTARG`);;
            E) declare -a arr=(`echo $OPTARG`);;
            o) out_dir=`echo $OPTARG`
                if ! [ -d "${out_dir}" ]; then mkdir "${out_dir}"; fi;;
            h) Usage; exit 0;;
            \?) echo -e "Invalid option:  -$OPTARG" >&2; Usage; exit 1;;
        esac 
    done
fi

##Catching erros
if [ "${save_name}" = '' ]; then save_name="${base_name}"; fi

if ! [ -f "${mgz_brain_file}" ]; then echo -e "CHECK IMAGE FILE PATH"; Usage; exit 1; fi
if ! ([ "${base_name: -4}" == ".nii" ] || [ "${base_name: -7}" == ".nii.gz" ]); then echo "CHECK IMAGE ${base_name} FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f "${mgz_mask_file}" ]; then echo -e " "; echo -e "CHECK MASK FILE PATH"; Usage; exit 1; fi
if ! ([ "${mask_base_name: -4}" == ".nii" ] || [ "${mask_base_name: -7}" == ".nii.gz" ]); then echo "CHECK MASK ${mask_base_name} FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f "${rh_file}" ]; then echo -e " "; echo -e "CHECK RH/LH FILE PATH"; Usage; exit 1; fi
if ! ([ ! "${rh_file: -4}" == ".nii" ] || [ "${rh_file: -7}" == ".nii.gz" ]); then echo "CHECK RH/LH FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f "${lh_file}" ]; then echo -e " "; echo -e "CHECK RH/LH FILE PATH"; Usage; exit 1; fi
if ! ([ "${lh_file: -4}" == ".nii" ] || [ "${lh_file: -7}" == ".nii.gz" ]); then echo "CHECK RH/LH FILE EXTENSION"; Usage; exit 1 ; fi

## copy original image to results folder
## Makes life easier
if ! [ -f "${out_dir}/${base_name}" ]; then cp "${mgz_brain_file}" "${out_dir}/${base_name}"; fi
if ! [ -f "${out_dir}/${mask_base_name}" ]; then cp "${mgz_mask_file}" "${out_dir}/${mask_base_name}"; fi


## Creates full brain mask
echo -n "Creating whole brain mask.... "
fslmaths "${mgz_brain_file}" -bin "${out_dir}/brain_bin.nii.gz"
echo "Done!"

## 'mgz_mask_file' may contain more ROIs than we need. So we must filter
## the cortical ribbon/pial from all of the segmentations
## inside the mask file. 'chosen_mask' will be either all the 6 layers,
## or some ROI to be reconstructed.
echo -n "Creating mask chosen ROIs with value(s) [${chosen_seg[@]}].... "
fslmaths "${mgz_mask_file}" -uthr 0 ${out_dir}/chosen_mask.nii.gz ## empty mask
for i in "${chosen_seg[@]}"; do
    fslmaths "${mgz_mask_file}" -thr ${i} "${out_dir}/temp_mask.nii.gz"
    fslmaths "${out_dir}/temp_mask.nii.gz" -uthr ${i} "${out_dir}/temp_mask.nii.gz"
    fslmaths "${out_dir}/chosen_mask.nii.gz" -add "${out_dir}/temp_mask.nii.gz" "${out_dir}/chosen_mask.nii.gz"
done
## KEEP THE BINARIZATION! It is possible to have overlays in the segmentation.
## So we must assure that the 'chosen_mask' remains binary
fslmaths "${out_dir}/chosen_mask.nii.gz" -bin "${out_dir}/chosen_mask.nii.gz"


## When all the masks have been perfected, remove the lines below.
## The below comands are ment to artificially improve the quality of faulty segmentation
## but will deform good segmention.
## Uncomment/comment the line bellow to/not to fill holes
fslmaths "${out_dir}/chosen_mask.nii.gz" -fillh26 "${out_dir}/chosen_mask.nii.gz"
## Uncomment/comment the line bellow to/not to expand chosen mask
fslmaths "${out_dir}/chosen_mask.nii.gz" -dilM "${out_dir}/chosen_mask.nii.gz"
## Improve outter border precision of the cortical ribbon
fslmaths "${out_dir}/chosen_mask.nii.gz" -mul "${out_dir}/brain_bin.nii.gz" "${out_dir}/chosen_mask.nii.gz"
echo "Done!"


## Erasing undesired segmentations from the 'mgz_mask_file'
## This will literaly delete certain regions from the final reconstruction
## We are concatenating all of the segmentations to be deleted into
## a single mask called 'remove_mask'. A good example of undesired segmentation
## would be the cerebellum
echo -n "Creating mask to erase ROIs with value(s) [${arr[@]}].... "
fslmaths "${mgz_mask_file}" -uthr 0 "${out_dir}/remove_mask.nii.gz"
for i in "${arr[@]}"; do
    fslmaths "${mgz_mask_file}" -thr ${i} "${out_dir}/temp_mask.nii.gz"
    fslmaths "${out_dir}/temp_mask.nii.gz" -uthr ${i} "${out_dir}/temp_mask.nii.gz"
    fslmaths "${out_dir}/remove_mask.nii.gz" -add "${out_dir}/temp_mask.nii.gz" "${out_dir}/remove_mask.nii.gz"
done

fslmaths "${out_dir}/remove_mask.nii.gz" -bin "${out_dir}/remove_mask.nii.gz"

## Same logic as 'chosen_mask'
## Remove these commands when using good enough segmentations
fslmaths "${out_dir}/remove_mask.nii.gz" -fillh26 "${out_dir}/remove_mask.nii.gz"
fslmaths "${out_dir}/remove_mask.nii.gz" -dilM "${out_dir}/remove_mask.nii.gz"
fslmaths "${out_dir}/remove_mask.nii.gz" -mul "${out_dir}/brain_bin.nii.gz" "${out_dir}/remove_mask.nii.gz"
echo "Done!"

## Finally we make the deletion
echo -n "Erasing the undesired ROIs from the brain mask... "
fslmaths "${out_dir}/brain_bin.nii.gz" -sub "${out_dir}/remove_mask.nii.gz" "${out_dir}/brain_bin.nii.gz"
echo "Done!"

## Now for the pial and wm masks
## The chosen_mask should be entirely contained in 
## the binary brain mask. However, in case the chosen_mask
## contain errors with pixels outside brain, we'll simply add
## those points as part of the pial mask.
## Note that what we call pial surface is the contour of the
## whole brain, including gm and wm. This is the same defenition
## as in FreeSurfer, the Universal Scaling Law and many other approaches.
## So we must keep this definition for comparison (and becasue it makes sense)
echo -n "Creating pial mask (includes both gm/cortical plate and wm).... "
fslmaths "${out_dir}/brain_bin.nii.gz" -add "${out_dir}/chosen_mask.nii.gz" "${out_dir}/pial.nii.gz"
fslmaths "${out_dir}/pial.nii.gz" -bin "${out_dir}/pial.nii.gz"
fslmaths "${out_dir}/pial.nii.gz" -fillh26 "${out_dir}/pial.nii.gz"
fslmaths "${out_dir}/pial.nii.gz" -bin "${out_dir}/pial.nii.gz"

## This step removes any small islands of pial
## Remember that the pial should be made of only one fully connected mask
python "${KSI}/main_component.py" "${out_dir}/pial.nii.gz" -o "${out_dir}" -s "pial.nii.gz"
echo "Done!"


## Creating left and right hemispheres
## I assume the hemispheres masks dont have any holes
## If this is not the case, add an extra -fillh26 after each
## hemisphere
echo -n "Splitting pial into right and left hemispheres.... "
fslmaths "${out_dir}/pial.nii.gz" -mul "${rh_file}" "${out_dir}/rh_pial.nii.gz"
fslmaths "${out_dir}/pial.nii.gz" -mul "${lh_file}" "${out_dir}/lh_pial.nii.gz"
echo "Done!"

## Here we assume that ribbon + wm = pial
## Hence, wm = pial - ribbon
echo -n "Creating wm segmentation mask.... "
fslmaths "${out_dir}/pial.nii.gz" -sub "${out_dir}/chosen_mask.nii.gz" "${out_dir}/wm.nii.gz"
fslmaths "${out_dir}/wm.nii.gz" -bin "${out_dir}/wm.nii.gz"

python "${KSI}/main_component.py" "${out_dir}/wm.nii.gz" -o "${out_dir}" -s "wm.nii.gz"
echo "Done!"


echo -n "Splitting wm into right and left hemispheres.... "
fslmaths "${out_dir}/wm.nii.gz" -mul "${rh_file}" "${out_dir}/rh_wm.nii.gz"
fslmaths "${out_dir}/wm.nii.gz" -mul "${lh_file}" "${out_dir}/lh_wm.nii.gz"
echo "Done!"

cp "${out_dir}/chosen_mask.nii.gz" "${out_dir}/ribbon.nii.gz"
cp "${out_dir}/remove_mask.nii.gz" "${out_dir}/non_cortical.nii.gz"

rm -rf "${out_dir}/temp_mask.nii.gz"
rm -rf "${out_dir}/remove_mask.nii.gz"
rm -rf "${out_dir}/chosen_mask.nii.gz"