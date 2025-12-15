#!/bin/bash 

# These two lines must be added/changed to accept arguments from the Docker wrapper
CONTAINER_DATA_ROOT=$1      # e.g., /data_input
CONTAINER_RESULTS_ROOT=$2   # e.g., /data_output/results
subj=$3
extract_brain=$4 
full_label_mask=$5 
intensity=${6}
noise_level=${7}

data_folder="${CONTAINER_DATA_ROOT}"
results_folder="${CONTAINER_RESULTS_ROOT}" 

## These files should exist in the data folder
## With these exact names
rh_mask="rh.nii.gz"
lh_mask="lh.nii.gz"


## freesurfer_surface.sh (Uses relative path inside /project)
/project/bin/freesurfer_surface.sh -s "${subj}" \
                        -i "${data_folder}/${extract_brain}" \
                        -m "${data_folder}/${full_label_mask}" \
                        -R "${data_folder}/${rh_mask}" \
                        -L "${data_folder}/${lh_mask}" \
                        -P "${data_folder}/pial.nii.gz" \
                        -W "${data_folder}/wm.nii.gz" \
                        -I ${intensity} \
                        -n ${noise_level} \
                        -o "${results_folder}"
