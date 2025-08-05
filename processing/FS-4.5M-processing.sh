#!/bin/bash 

data_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/data/45M"
results_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/results/45M"
subj="45M"
extract_brain="4.5M_vol_masked.nii.gz"
full_label_mask="4.5M_tissuelables.nii.gz"
rh_mask="4.5M_rh.nii.gz"
lh_mask="4.5M_lh.nii.gz"
gray_matter_or_cp_vals_string="2 9"
non_cortical_vals="1 4 6 8"
csf_vals="1" #repeat csf here. But it is non_cortical anyway

../bin/pial_wm_masks.sh -i "${data_folder}/${extract_brain}" \
                    -m "${data_folder}/${full_label_mask}" \
                    -R "${data_folder}/${rh_mask}" \
                    -L "${data_folder}/${lh_mask}" \
                    -G "${gray_matter_or_cp_vals_string}" \
                    -E "${non_cortical_vals}" \
                    -C "${csf_vals}"\
                    -o "${results_folder}"

../bin/freesurfer_surface.sh -s "${subj}" \
                        -i "${data_folder}/${extract_brain}" \
                        -m "${data_folder}/${full_label_mask}" \
                        -R "${data_folder}/${rh_mask}" \
                        -L "${data_folder}/${lh_mask}" \
                        -P "${results_folder}/pial.nii.gz" \
                        -W "${results_folder}/wm.nii.gz" \
                        -o "${results_folder}"