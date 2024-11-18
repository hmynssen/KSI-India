export path_subjs='/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/data'
export SUBJECTS_DIR=${path_subjs}

cd "${path_subjs}"
subjs=(*)
start=2
finish=2
echo ${subjs[@]:start:(finish-start+1)}
# exit
for subj in ${subjs[@]:start:(finish-start+1)}; do
    echo ${SUBJECTS_DIR}
    echo ${subj}

    echo '---------Ribbon merge------------'
    cd "${SUBJECTS_DIR}/${subj}/mri"
    # mri_convert lh.ribbon.mgz lh.ribbon.nii
    # mri_convert rh.ribbon.mgz rh.ribbon.nii
    # fslmaths lh.ribbon.nii -add rh.ribbon.nii -bin ribbon.nii
    # fslmaths ribbon.nii -mul 255 ribbon.nii.gz

    mri_convert ribbon-old.mgz rh-s.nii
    fslmaths rh-s.nii -thr 4 -bin rh-s.nii.gz

    mri_convert rh-s.nii.gz rh-s.mgz
    mri_tessellate rh-s.mgz 1 rh-surface

    mris_convert rh-surface rh-surface.stl


   
done