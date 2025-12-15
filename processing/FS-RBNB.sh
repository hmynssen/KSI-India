subj='SubantarticFurSeal'

data_folder="/media/hmynssen/Data/DATA_Kamilla/${subj}"
results_folder="/media/hmynssen/Data/DATA_Kamilla/${subj}/KSI/results"
extract_brain='SubantarticFurSeal.nii.gz'
full_label_mask='SubantarticFurSeal_tissue.nii.gz'
lh_mask_raw='lh_raw.nii.gz'
gray_matter_or_cp_vals_string='1'
non_cortical_vals='0'
csf_vals='0'

intensity=10


################
## Processing ##
################

rh_mask="rh.nii.gz" 
lh_mask="lh.nii.gz" 

fslmaths "${data_folder}/${full_label_mask}" -bin "${data_folder}/${subj}_brain_mask.nii.gz"
fslmaths "${data_folder}/${subj}_brain_mask.nii.gz" -mul "${data_folder}/${lh_mask_raw}" "${data_folder}/${lh_mask}"
fslmaths "${data_folder}/${subj}_brain_mask.nii.gz" -sub "${data_folder}/${lh_mask}" -bin "${data_folder}/${rh_mask}"

## Enforcing brain_extraction
fslmaths "${data_folder}/${extract_brain}" -mul "${data_folder}/${subj}_brain_mask.nii.gz" "${data_folder}/${subj}_extracted_brain.nii.gz"

## pial_wm_masks.sh -> creates the binary masks from given selection of values
../bin/pial_wm_masks.sh -i "${data_folder}/${subj}_extracted_brain.nii.gz" \
                    -m "${data_folder}/${full_label_mask}" \
                    -R "${data_folder}/${rh_mask}" \
                    -L "${data_folder}/${lh_mask}" \
                    -G "${gray_matter_or_cp_vals_string}" \
                    -E "${non_cortical_vals}" \
                    -C "${csf_vals}"\
                    -o "${results_folder}"

## freesurfer_surface.sh used the created masks to make surfaces
../bin/freesurfer_surface.sh -s "${subj}" \
                        -i "${data_folder}/${subj}_extracted_brain.nii.gz" \
                        -m "${data_folder}/${full_label_mask}" \
                        -R "${data_folder}/${rh_mask}" \
                        -L "${data_folder}/${lh_mask}" \
                        -P "${results_folder}/pial.nii.gz" \
                        -W "${results_folder}/wm.nii.gz" \
                        -o "${results_folder}"