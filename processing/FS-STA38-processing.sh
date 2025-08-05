#!/bin/bash 

data_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/data/STA38"
results_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/results/STA38"
subj="STA38"
extract_brain="STA38exp_brain.nii.gz"
full_label_mask="STA38exp_tissue.nii.gz"
rh_mask="rh.nii.gz"
lh_mask="lh.nii.gz"
gray_matter_or_cp_vals_string="37 38 41 42 112 113"
non_cortical_vals="94 100 101 124"
csf_vals="124" #repeat csf here. But it is non_cortical anyway

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