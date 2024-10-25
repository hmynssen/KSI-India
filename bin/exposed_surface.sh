export KSI=$(pwd)
export path_subjs='/mnt/d/freesurfer/Subjects/'
export SUBJECTS_DIR=${path_subjs}
start=0
finish=0
hemi='rh'



cd "${path_subjs}"
subjs=(*)
echo 'Processing subjects:'
echo ${subjs[@]:start:(finish-start+1)}
echo ' '
echo ' '
for subj in ${subjs[@]:start:(finish-start+1)}; do
    echo ${subj}
    echo '---------Converting to Nifti Format------------'
    cd "${SUBJECTS_DIR}/${subj}/surf"
    mris_fill -c -r 1 ${hemi}.pial ${hemi}.pial.filled.mgz
    mri_convert ${hemi}.pial.filled.mgz ${hemi}.pial.filled.nii
    rm -rf ${hemi}.pial.filled.mgz
    
    python "${KSI}/rolling_ball.py" ${hemi}.pial.filled.nii -b 15 -d 15 -s ${subj}_${hemi}_exposed_surface.stl

    mris_smooth ${subj}_${hemi}_exposed_surface.stl ${subj}_${hemi}_exposed_surface_smooth.stl

   
done