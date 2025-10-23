#!/bin/bash 

# These two lines must be added/changed to accept arguments from the Docker wrapper
CONTAINER_DATA_ROOT=$1      # e.g., /data_input
CONTAINER_RESULTS_ROOT=$2   # e.g., /data_output/results
subj=$3
extract_brain=$4 
full_label_mask=$5 
lh_mask_raw=$6 
gray_matter_or_cp_vals_string=$7 
non_cortical_vals=$8 
csf_vals=$9 
intensity=${10}

# NEW: Use the passed-in container root paths
data_folder="${CONTAINER_DATA_ROOT}/${subj}"
results_folder="${CONTAINER_RESULTS_ROOT}/${subj}" 

## These files should exist in the data folder
## With these exact names


rh_mask="rh.nii.gz" #not required. I'm using it as a name only
lh_mask="lh.nii.gz" #not required. I'm using it as a name only

## Please check these values as they are based on our previous choice of anotations/labeling

# fslmaths "${data_folder}/${full_label_mask}" -bin "${results_folder}/${subj}_brain_mask.nii.gz"
# fslmaths "${results_folder}/${subj}_brain_mask.nii.gz" -mul "${data_folder}/${lh_mask_raw}" "${results_folder}/${lh_mask}"
# fslmaths "${results_folder}/${subj}_brain_mask.nii.gz" -sub "${results_folder}/${lh_mask}" -bin "${results_folder}/${rh_mask}"

# ## Enforcing brain_extraction
# fslmaths "${data_folder}/${extract_brain}" -mul "${results_folder}/${subj}_brain_mask.nii.gz" "${results_folder}/${subj}_extracted_brain.nii.gz"

# ## pial_wm_masks.sh (Uses relative path inside /project)
# /project/bin/pial_wm_masks.sh -i "${results_folder}/${subj}_extracted_brain.nii.gz" \
#                     -m "${data_folder}/${full_label_mask}" \
#                     -R "${results_folder}/${rh_mask}" \
#                     -L "${results_folder}/${lh_mask}" \
#                     -G "${gray_matter_or_cp_vals_string}" \
#                     -E "${non_cortical_vals}" \
#                     -C "${csf_vals}"\
#                     -o "${results_folder}"

## freesurfer_surface.sh (Uses relative path inside /project)
/project/bin/freesurfer_surface.sh -s "${subj}" \
                        -i "${results_folder}/${subj}_extracted_brain.nii.gz" \
                        -m "${results_folder}/${full_label_mask}" \
                        -R "${results_folder}/${rh_mask}" \
                        -L "${results_folder}/${lh_mask}" \
                        -P "${results_folder}/pial.nii.gz" \
                        -W "${results_folder}/wm.nii.gz" \
                        -I ${intensity} \
                        -o "${results_folder}"
