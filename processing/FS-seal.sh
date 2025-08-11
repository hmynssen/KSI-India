#!/bin/bash 

data_folder="/mnt/d/DATA_Nina/SSLBABY/Heitor"
results_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/results/SSLBABY-Heitor"
subj="SSLBABY"
brain="SSLBABY.nii.gz"
extract_brain="SSLBABY_extracted.nii.gz"
rh_mask="rh.nii.gz"
lh_mask="lh.nii.gz"
pial_file="pial.nii.gz" #This is the outside layer, also known as ribbon
                        #Not to be confused with pial_full, which is the combination
                        #of the ribbon + white matter
wm_file="wm.nii.gz"

../bin/freesurfer_surface.sh -s "${subj}" \
                        -i "${data_folder}/${extract_brain}" \
                        -m "${data_folder}/${full_label_mask}" \
                        -R "${data_folder}/${rh_mask}" \
                        -L "${data_folder}/${lh_mask}" \
                        -P "${data_folder}/${pial_file}" \
                        -W "${data_folder}/${wm_file}" \
                        -o "${results_folder}"