precon_fill_segpriors_parent_folder='/media/hmynssen/Data/DATA_Nina/ssl3'
subject='ssl3'
output_folder='/media/hmynssen/Data/DATA_Nina/ssl3'
### It is expected to have the following:
## .
## └──subject
##     ├── subject_brain.nii.gz
##     ├── fill
##     │   ├── left_hem.nii.gz
##     │   ├── non_cort.nii.gz
##     │   ├── right_hem.nii.gz
##     │   └── sub_cort.nii.gz
##     └── seg_priors
##         ├── csf.nii.gz
##         ├── gm.nii.gz
##         └── wm.nii.gz


if ! [ -d "${output_folder}" ]; then mkdir "${output_folder}"; fi
cd "${precon_fill_segpriors_parent_folder}/${subject}"

## Whole brain mask
cd seg_priors
fslmaths csf.nii.gz -add gm.nii.gz -add wm.nii.gz -bin brain_mask.nii.gz
mv brain_mask.nii.gz ../
cd ../
fslmaths brain_mask.nii.gz -sub fill/non_cort.nii.gz -bin brain_mask.nii.gz
mv brain_mask.nii.gz "${output_folder}"

## Making tissues mask
fslmaths seg_priors/wm.nii.gz -add fill/sub_cort.nii.gz -bin -mul 2 -add seg_priors/gm.nii.gz -mul "${output_folder}/brain_mask.nii.gz" "${subject}_tissue.nii.gz"
mv "${subject}_tissue.nii.gz" "${output_folder}"

## Extracted brain
fslmaths "${subject}_brain.nii.gz" -mul "${output_folder}/brain_mask.nii.gz" "${output_folder}/${subject}.nii.gz"

## Mask lh raw
fslmaths fill/left_hem.nii.gz -mul "${output_folder}/brain_mask.nii.gz" "${output_folder}/lh_raw.nii.gz"
