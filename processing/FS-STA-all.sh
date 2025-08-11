#!/bin/bash 

declare -a subjects=(
"STA21"
"STA25"
"STA30"
"STA32"
"STA34"
"STA36"
)


for subj in "${subjects[@]}"; do
    data_folder="/mnt/d/DATA_India/${subj}"
    results_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/results/${subj}"
    extract_brain="${subj}.nii.gz" #REQUIRED
    full_label_mask="${subj}_tissue.nii.gz" #REQUIRED
    lh_mask_raw="lh_raw.nii.gz" #REQUIRED
    rh_mask="rh.nii.gz" #not required. I'm using it as a name only
    lh_mask="lh.nii.gz" #not required. I'm using it as a name only
    gray_matter_or_cp_vals_string="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 81 82 83 84 85 86 87 88 89 90 112 113"
    non_cortical_vals="94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 111 124"
    csf_vals="124" #repeat csf here. But it is non_cortical anyway

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
done