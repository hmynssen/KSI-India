#!/bin/bash 
Usage() {
    echo -e ""
    echo -e "Usage: `basename $0` [options] -s <subj> -i <brain_volume.nii.gz> -m <brain_mask.nii.gz> \
    -rh <rh.nii.gz> -lh <lh.nii.gz> -gm <brigthness values> -wm <brigthness values> "
    echo -e ""
    echo -e "Compulsory Arguments"
    echo -e " -s <string> \t\t Subject name "
    echo -e " -i <image.nii.gz> \t Skull stripped image; must be nii or nii.gz file"
    echo -e " -m <mask.nii.gz> \t Binary mask; must be nii or nii.gz file"
    echo -e " -R <mask.nii.gz> \t Right hemisphere; must be nii or nii.gz file"
    echo -e " -L <mask.nii.gz> \t Left hemisphere; must be nii or nii.gz file"
    echo -e " -G <string> \t\t GM or Cortical plate brightness value; use quotes/string \n\t\t\t declaration for possible multple values "
    echo -e " -E <string> \t\t Erase brightness value; use quotes/string declaration for  \n\t\t\t possible multple values.  "
    echo -e ""
    echo -e "Optional Arguments" 
    echo -e " -d <string> \t\t Path to subject parent folder" 
    echo -e " -o <string> \t\t Path to output parent folder (subject child folder will be created)"
    echo -e " -b <string> \t\t Path to binaries"
    echo -e ""
    echo -e "Example:  ./`basename $0` -s FB141 -i FB141_BrainVolume_SkullStripped.nii.gz -m FB141_BrainMask.nii.gz -rh rh.nii.gz -lh lh.nii.gz -gm \"1\" -wm \"2 6 8 11\" -d \"../data\" -o \"../results\" "
    echo -e ""
    exit 1
}

if [ $# -lt 7 ]; then 
    Usage
    exit 0
else
    subj=''
    mgz_brain_file=''
    mgz_mask_file=''
    rh_file=''
    lh_file=''
    declare -a chosen_seg=(1)
    declare -a arr=(2)
    mgz_dir='./'
    out_dir='./'
    KSI=$(pwd)
    while getopts ":s:i:m:R:L:G:E:d:o:b:" opt ; do 
        case $opt in
            s)
                subj=`echo $OPTARG`
                ;;
            i)
                mgz_brain_file=`echo $OPTARG`
                ;;
            m)
                mgz_mask_file=`echo $OPTARG`
                ;;
            R)
                rh_file=`echo $OPTARG`
                ;;
            L)
                lh_file=`echo $OPTARG`
                ;;
            G)
                declare -a chosen_seg=(`echo $OPTARG`)
                ;;
            E)
                declare -a arr=(`echo $OPTARG`)
                ;;
            d) >&2
                mgz_dir=`echo $OPTARG`
                ;;
            o) >&2
                out_dir=`echo $OPTARG`
                if ! [ -d ${out_dir} ];then mkdir ${out_dir} ;fi
                ;;
            b) >&2
                KSI=`echo $OPTARG`
                ;;

            \?)
            echo -e "Invalid option:  -$OPTARG" >&2
                Usage
                exit 1
                ;;
        esac 
    done
fi

##Catching erros
if ! [ -d ${mgz_dir}/${subj} ]; then echo -e " "; echo -e "CHECK SUBJECT NAME OR PATH"; Usage; exit 1; fi
if ! [ -d ${out_dir}/${subj} ]; then mkdir ${out_dir}/${subj}; fi

if ! [ -f ${mgz_dir}/${subj}/${mgz_brain_file} ]; then echo -e "CHECK IMAGE FILE PATH"; Usage; exit 1; fi
if ! ([ "${mgz_brain_file: -4}" == ".nii" ] || [ "${mgz_brain_file: -7}" == ".nii.gz" ]); then echo "CHECK IMAGE FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f ${mgz_dir}/${subj}/${mgz_mask_file} ]; then echo -e " "; echo -e "CHECK MASK FILE PATH"; Usage; exit 1; fi
if ! ([ "${mgz_mask_file: -4}" == ".nii" ] || [ "${mgz_mask_file: -7}" == ".nii.gz" ]); then echo "${mgz_mask_file: -7}"; exit 1 ; fi
if ! ([ "${mgz_mask_file: -4}" == ".nii" ] || [ "${mgz_mask_file: -7}" == ".nii.gz" ]); then echo "CHECK MASK FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f ${mgz_dir}/${subj}/${rh_file} ]; then echo -e " "; echo -e "CHECK RH/LH FILE PATH"; Usage; exit 1; fi
if ! ([ ! "${rh_file: -4}" == ".nii" ] || [ "${rh_file: -7}" == ".nii.gz" ]); then echo "CHECK RH/LH FILE EXTENSION"; Usage; exit 1 ; fi

if ! [ -f ${mgz_dir}/${subj}/${lh_file} ]; then echo -e " "; echo -e "CHECK RH/LH FILE PATH"; Usage; exit 1; fi
if ! ([ "${lh_file: -4}" == ".nii" ] || [ "${lh_file: -7}" == ".nii.gz" ]); then echo "CHECK RH/LH FILE EXTENSION"; Usage; exit 1 ; fi

## copy original image to results folder
## Makes life easier
if ! [ -f ${out_dir}/${subj}/${mgz_brain_file} ]; then cp "${mgz_dir}/${subj}/${mgz_brain_file}" "${out_dir}/${subj}/${mgz_brain_file}"; fi


## Creates full brain mask
fslmaths "${mgz_dir}/${subj}/${mgz_brain_file}" -bin "${out_dir}/${subj}/brain_bin.nii.gz"

## 'mgz_mask_file' may contain more ROIs than we need. So we must filter
## the cortical ribbon/pial from all of the segmentations
## inside the mask file. 'chosen_mask' will be either all the 6 layers,
## or some ROI to be reconstructed.
fslmaths "${mgz_dir}/${subj}/${mgz_mask_file}" -uthr 0 ${out_dir}/${subj}/chosen_mask.nii.gz ## empty mask
for i in "${chosen_seg[@]}"; do
    fslmaths "${mgz_dir}/${subj}/${mgz_mask_file}" -thr ${i} "${out_dir}/${subj}/temp_mask.nii.gz"
    fslmaths "${out_dir}/${subj}/temp_mask.nii.gz" -uthr ${i} "${out_dir}/${subj}/temp_mask.nii.gz"
    fslmaths "${out_dir}/${subj}/chosen_mask.nii.gz" -add "${out_dir}/${subj}/temp_mask.nii.gz" "${out_dir}/${subj}/chosen_mask.nii.gz"
done
## KEEP THE BINARIZATION! It is possible to have overlays in the segmentation.
## So we must assure that the 'chosen_mask' remains binary
fslmaths "${out_dir}/${subj}/chosen_mask.nii.gz" -bin "${out_dir}/${subj}/chosen_mask.nii.gz"


## When all the masks have been perfected, remove the lines below.
## The below comands are ment to artificially improve the quality of faulty segmentation
## but will deform good segmention.
## Uncomment/comment the line bellow to/not to fill holes
fslmaths "${out_dir}/${subj}/chosen_mask.nii.gz" -fillh26 "${out_dir}/${subj}/chosen_mask.nii.gz"
## Uncomment/comment the line bellow to/not to expand chosen mask
fslmaths "${out_dir}/${subj}/chosen_mask.nii.gz" -dilM "${out_dir}/${subj}/chosen_mask.nii.gz"
## Improve outter border precision of the cortical ribbon
fslmaths "${out_dir}/${subj}/chosen_mask.nii.gz" -mul "${out_dir}/${subj}/brain_bin.nii.gz" "${out_dir}/${subj}/chosen_mask.nii.gz"



## Erasing undesired segmentations from the 'mgz_mask_file'
## This will literaly delete certain regions from the final reconstruction
## We are concatenating all of the segmentations to be deleted into
## a single mask called 'remove_mask'. A good example of undesired segmentation
## would be the cerebellum
fslmaths "${mgz_dir}/${subj}/${mgz_mask_file}" -uthr 0 "${out_dir}/${subj}/remove_mask.nii.gz"
for i in "${arr[@]}"; do
    fslmaths "${mgz_dir}/${subj}/${mgz_mask_file}" -thr ${i} "${out_dir}/${subj}/temp_mask.nii.gz"
    fslmaths "${out_dir}/${subj}/temp_mask.nii.gz" -uthr ${i} "${out_dir}/${subj}/temp_mask.nii.gz"
    fslmaths "${out_dir}/${subj}/remove_mask.nii.gz" -add "${out_dir}/${subj}/temp_mask.nii.gz" "${out_dir}/${subj}/remove_mask.nii.gz"
done

fslmaths "${out_dir}/${subj}/remove_mask.nii.gz" -bin "${out_dir}/${subj}/remove_mask.nii.gz"

## Same logic as 'chosen_mask'
## Remove these commands when using good enough segmentations
fslmaths "${out_dir}/${subj}/remove_mask.nii.gz" -fillh26 "${out_dir}/${subj}/remove_mask.nii.gz"
fslmaths "${out_dir}/${subj}/remove_mask.nii.gz" -dilM "${out_dir}/${subj}/remove_mask.nii.gz"
fslmaths "${out_dir}/${subj}/remove_mask.nii.gz" -mul "${out_dir}/${subj}/brain_bin.nii.gz" "${out_dir}/${subj}/remove_mask.nii.gz"


## Finally we make the deletion
fslmaths "${out_dir}/${subj}/brain_bin.nii.gz" -sub "${out_dir}/${subj}/remove_mask.nii.gz" "${out_dir}/${subj}/brain_bin.nii.gz"


## Now for the pial and wm masks
## The chosen_mask should be entirely contained in 
## the binary brain mask. However, in case the chosen_mask
## contain errors with pixels outside brain, we'll simply add
## those points as part of the pial mask.
## Note that what we call pial surface is the contour of the
## whole brain, including gm and wm. This is the same defenition
## as in FreeSurfer, the Universal Scaling Law and many other approaches.
## So we must keep this definition for comparison (and becasue it makes sense)
fslmaths "${out_dir}/${subj}/brain_bin.nii.gz" -add "${out_dir}/${subj}/chosen_mask.nii.gz" "${out_dir}/${subj}/pial.nii.gz"
fslmaths "${out_dir}/${subj}/pial.nii.gz" -bin "${out_dir}/${subj}/pial.nii.gz"
fslmaths "${out_dir}/${subj}/pial.nii.gz" -fillh26 "${out_dir}/${subj}/pial.nii.gz"
fslmaths "${out_dir}/${subj}/pial.nii.gz" -bin "${out_dir}/${subj}/pial.nii.gz"

python "${KSI}/main_component.py" "${out_dir}/${subj}/pial.nii.gz" -o "${out_dir}/${subj}" -s "pial.nii.gz"

## Creating left and right hemispheres
## I assume the hemispheres masks dont have any holes
## If this is not the case, add an extra -fillh26 after each
## hemisphere
fslmaths "${out_dir}/${subj}/pial.nii.gz" -mul "${mgz_dir}/${subj}/${rh_file}" "${out_dir}/${subj}/rh_pial.nii.gz"
fslmaths "${out_dir}/${subj}/pial.nii.gz" -mul "${mgz_dir}/${subj}/${lh_file}" "${out_dir}/${subj}/lh_pial.nii.gz"


## Here we assume that ribbon + wm = pial
## Hence, wm = pial - ribbon
fslmaths "${out_dir}/${subj}/pial.nii.gz" -sub "${out_dir}/${subj}/chosen_mask.nii.gz" "${out_dir}/${subj}/wm.nii.gz"
fslmaths "${out_dir}/${subj}/wm.nii.gz" -bin "${out_dir}/${subj}/wm.nii.gz"

python "${KSI}/main_component.py" "${out_dir}/${subj}/wm.nii.gz" -o "${out_dir}/${subj}" -s "wm.nii.gz"

fslmaths "${out_dir}/${subj}/wm.nii.gz" -mul "${mgz_dir}/${subj}/${rh_file}" "${out_dir}/${subj}/rh_wm.nii.gz"
fslmaths "${out_dir}/${subj}/wm.nii.gz" -mul "${mgz_dir}/${subj}/${lh_file}" "${out_dir}/${subj}/lh_wm.nii.gz"

rm -rf "${out_dir}/${subj}/temp_mask.nii.gz"
rm -rf "${out_dir}/${subj}/remove_mask.nii.gz"
rm -rf "${out_dir}/${subj}/chosen_mask.nii.gz"