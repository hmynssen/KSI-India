subj='srr_window'

data_folder="/media/hmynssen/Data/DATA_India/${subj}"
extract_brain="srr_window.nii.gz"
full_label_mask="srr_window-mask-brain_bounti-19.nii.gz"

##Assuming that BOUNTI produces consistent segmentation masks
gray_matter_or_cp_vals_string="3 4"
csf_vals="1 2 7 8 18 19"
non_cortical_vals="1 2 10 11 12 13 19"


lh_BOUNTI="3 5 7 9 14 16 18"
wm_subcort_vals="1 2 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19"
lh_mask_raw="lh_raw.nii.gz"

################
## PROCESSING ##
################

###This tries to create the necessary input files from a BOUNTI segmentation

rh_mask="rh.nii.gz" 
lh_mask="lh.nii.gz"

fslmaths "${data_folder}/${full_label_mask}" -uthr 0 "${data_folder}/${lh_mask_raw}"
fslmaths "${data_folder}/${full_label_mask}" -uthr 0 "${data_folder}/chosen_mask.nii.gz"
for i in ${lh_BOUNTI}; do
    fslmaths "${data_folder}/${full_label_mask}" -thr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/temp_mask.nii.gz" -uthr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/chosen_mask.nii.gz" -add "${data_folder}/temp_mask.nii.gz" "${data_folder}/chosen_mask.nii.gz"
done
fslmaths "${data_folder}/chosen_mask.nii.gz" -bin "${data_folder}/${lh_mask_raw}"

for i in ${wm_subcort_vals}; do
    fslmaths "${data_folder}/${full_label_mask}" -thr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/temp_mask.nii.gz" -uthr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/chosen_mask.nii.gz" -add "${data_folder}/temp_mask.nii.gz" "${data_folder}/chosen_mask.nii.gz"
done

for i in ${gray_matter_or_cp_vals_string}; do
    fslmaths "${data_folder}/${full_label_mask}" -thr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/temp_mask.nii.gz" -uthr ${i} "${data_folder}/temp_mask.nii.gz"
    fslmaths "${data_folder}/chosen_mask.nii.gz" -add "${data_folder}/temp_mask.nii.gz" "${data_folder}/chosen_mask.nii.gz"
done
fslmaths "${data_folder}/chosen_mask.nii.gz" -bin "${data_folder}/${subj}_brain_mask.nii.gz"
rm "${data_folder}/chosen_mask.nii.gz"
fslmaths "${data_folder}/${subj}_brain_mask.nii.gz" -mul "${data_folder}/${lh_mask_raw}" "${data_folder}/${lh_mask}"
fslmaths "${data_folder}/${subj}_brain_mask.nii.gz" -sub "${data_folder}/${lh_mask}" -bin "${data_folder}/${rh_mask}"
fslmaths "${data_folder}/${extract_brain}" -mul "${data_folder}/${subj}_brain_mask.nii.gz" "${data_folder}/${subj}_extracted_brain.nii.gz"

## pial_wm_masks.sh -> creates the binary masks from given selection of values
../bin/pial_wm_masks.sh -i "${data_folder}/${subj}_extracted_brain.nii.gz" \
                    -m "${data_folder}/${full_label_mask}" \
                    -R "${data_folder}/${rh_mask}" \
                    -L "${data_folder}/${lh_mask}" \
                    -G "${gray_matter_or_cp_vals_string}" \
                    -E "${non_cortical_vals}" \
                    -C "${csf_vals}"\
                    -o "${data_folder}"

rm ${data_folder}/brain_bin.nii.gz
rm ${data_folder}/csf_mask.nii.gz
rm ${data_folder}/lh_pial.nii.gz
rm ${data_folder}/lh_raw.nii.gz
rm ${data_folder}/lh_wm.nii.gz
rm ${data_folder}/rh_pial.nii.gz
rm ${data_folder}/rh_wm.nii.gz
rm ${data_folder}/pial_full.nii.gz
rm ${data_folder}/non_cortical.nii.gz
rm ${data_folder}/${subj}_brain_mask.nii.gz