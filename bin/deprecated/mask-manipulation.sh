export mgz_dir='./data'
export mgz_mask_file='FB141_BrainMask.nii.gz'
export mgz_brain_file='FB141_BrainVolume_SkullStripped.nii.gz'
export subj='FB141'
export chosen_seg=5
declare -a arr=(2 6 8 11)

echo ${mgz_brain_file}
cd ${mgz_dir}/${subj}
ls

fslmaths "${mgz_brain_file}" -bin brain_bin.nii.gz
fslmaths "${mgz_mask_file}" -thr ${chosen_seg} chosen_mask.nii.gz
fslmaths chosen_mask.nii.gz -uthr ${chosen_seg} chosen_mask.nii.gz
fslmaths chosen_mask.nii.gz -bin chosen_mask.nii.gz

fslmaths "${mgz_mask_file}" -uthr 0 remove_mask.nii.gz
for i in "${arr[@]}"; do
    fslmaths "${mgz_mask_file}" -thr ${i} temp_mask.nii.gz
    fslmaths "temp_mask.nii.gz" -uthr ${i} temp_mask.nii.gz
    fslmaths remove_mask.nii.gz -add temp_mask.nii.gz remove_mask.nii.gz
done
fslmaths remove_mask.nii.gz -bin remove_mask.nii.gz
fslmaths remove_mask.nii.gz -fillh26 remove_mask.nii.gz

fslmaths brain_bin.nii.gz -sub remove_mask.nii.gz brain_bin.nii.gz

fslmaths brain_bin.nii.gz -add chosen_mask.nii.gz pial.nii.gz
fslmaths pial.nii.gz -bin pial.nii.gz
fslmaths pial.nii.gz -fillh26 pial.nii.gz
fslmaths pial.nii.gz -bin pial.nii.gz
fslmaths pial.nii.gz -eroF pial.nii.gz

fslmaths pial.nii.gz -sub chosen_mask.nii.gz wm.nii.gz
fslmaths wm.nii.gz -fillh26 wm.nii.gz
fslmaths wm.nii.gz -bin wm.nii.gz
fslmaths wm.nii.gz -eroF wm.nii.gz

