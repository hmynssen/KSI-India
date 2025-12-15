data_folder="/media/hmynssen/Data/DATA_India/${subj}"
results_folder="/media/hmynssen/Data/DATA_India/${subj}/KSI-results"
subj='srr_window'
intensity=0.5
noise_level=20


##  Note that the brain has been extracted
##  Compare original with extracted to understand the selection
##or use the BOUNTI-to-KSI.sh
extract_brain="srr_window_extracted_brain.nii.gz"
full_label_mask="srr_window-mask-brain_bounti-19.nii.gz"
rh_mask="rh.nii.gz"
lh_mask="lh.nii.gz"



# freesurfer_surface.sh used the created masks to make surfaces
../bin/freesurfer_surface.sh -s "${subj}" \
                            -i "${data_folder}/${subj}_extracted_brain.nii.gz" \
                            -m "${data_folder}/${full_label_mask}" \
                            -R "${data_folder}/${rh_mask}" \
                            -L "${data_folder}/${lh_mask}" \
                            -P "${data_folder}/pial.nii.gz" \
                            -W "${data_folder}/wm.nii.gz" \
                            -I ${intensity} \
                            -n ${noise_level} \
                            -o "${results_folder}"