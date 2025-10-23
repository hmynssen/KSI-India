#!/bin/bash
# This script is run on the host (your local machine)

# --- Configuration ---
# You define the Docker Image to use
DOCKER_IMAGE="my-oxcin-pipeline:1.0"
LICENSE_PATH="${HOME}/fs_docker/license.txt"
PROJECT_PATH="${HOME}/Documents/MetaBio/KSI-India"

# --- Dynamic Input/Output (Assuming you pass these as arguments to the wrapper) ---
DATA_ROOT_HOST='/media/hmynssen/Data/DATA_Nina/spotted/KSI'
OUTPUT_ROOT_HOST='/media/hmynssen/Data/DATA_Nina/spotted/KSI/results'
subj='spotted'
extract_brain='spotted.nii.gz'
full_label_mask='spotted_tissue.nii.gz'
lh_mask_raw='lh_raw.nii.gz'
gray_matter_or_cp_vals_string='1'
non_cortical_vals='0'
csf_vals='0'
intensity=5.0

# Define container internal mount points
CONTAINER_DATA_ROOT="/data_input"
CONTAINER_OUTPUT_ROOT="/data_output/results"

# --- Execute Docker ---
echo "Starting pipeline with Docker Image: ${DOCKER_IMAGE}"

FULL_PIPELINE_CMD='source /etc/profile && /bin/bash Docker-base-FS.sh \
    "'"${CONTAINER_DATA_ROOT}"'" \
    "'"${CONTAINER_OUTPUT_ROOT}"'" \
    "'"${subj}"'" \
    "'"${extract_brain}"'" \
    "'"${full_label_mask}"'" \
    "'"${lh_mask_raw}"'" \
    "'"${gray_matter_or_cp_vals_string}"'" \
    "'"${non_cortical_vals}"'" \
    "'"${csf_vals}"'" \
    "'"${intensity}"'"'

docker run --rm -it -v "${LICENSE_PATH}":/opt/freesurfer-7.4.1/license.txt:ro -e FS_LICENSE=/opt/freesurfer-7.4.1/license.txt -v "${PROJECT_PATH}":/project -v "${DATA_ROOT_HOST}":"${CONTAINER_DATA_ROOT}" -v "${OUTPUT_ROOT_HOST}":"${CONTAINER_OUTPUT_ROOT}" -w /project/processing "${DOCKER_IMAGE}" /bin/bash -c "${FULL_PIPELINE_CMD}"