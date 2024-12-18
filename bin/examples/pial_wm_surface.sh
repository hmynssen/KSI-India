#!/bin/bash 

data_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/data/FB141"
results_folder="/mnt/c/Users/Heitor Gessner/Documents/Metabio-Personal/KSI-India/results/FB141"

## Creating the masks for Subject FB141
## Necessary files:
##      -MRI image:                     FB141_BrainVolume_SkullStripped.nii.gz
##      -Binary mask:                   FB141_BrainMask.nii.gz
##      -Right hemisphere (RH) mask:    rh_mask.nii.gz
##      -Left hemisphere (LH) mask:     lh_mask.nii.gz
##
## Inside the Binary mask, you should find the color values for the gray matter or
## cortical plate and use it as input argument for the -G flag. 
## Also inside binary mask, find the color values of regions that should not be
## reconstructed such as the cerebellum. Use it as input argument for the -E flag.
## Any other color value will be treated as white matter, therefore:
##      Brain = GM + WM - E
## Also, we desire to reconstruct 3 surfaces from those masks:
##      - Pial surface = GM + WM - E
##      - White matter surface = WM - E
##      - Exposed surface = rolling_ball(Pial surface) ~= convex_hull(Pial surface)

../pial_wm_masks.sh -i "${data_folder}/FB141_BrainVolume_SkullStripped.nii.gz" \
                    -m "${data_folder}/FB141_BrainMask.nii.gz" \
                    -R "${data_folder}/rh_mask.nii.gz" \
                    -L "${data_folder}/lh_mask.nii.gz" \
                    -G "5" \
                    -E "2 6 8 11" \
                    -o "${results_folder}"

## Making the surfaces
## This step is the one that need the most improvements
## Isocontouring is very simple but very limited when brains gets
## gyrified. Opposing sides on the pial sulci start to get fully contained
## in a single voxel, and that's when the isocontour fails. 
## So for a sulci spacing ~=  voxel size, we'll need to improve this approach considerably
##
## FreeSurfer might be enough to fix this but will require further coding. I'll update this
## example later with a fully working code, but let's try this one for now.
##
## Last modified, 18/11/2024

python ../isocontour_surface.py "${results_folder}/rh_pial.nii.gz" -s "rh_pial.stl" -o "${results_folder}"
python ../isocontour_surface.py "${results_folder}/lh_pial.nii.gz" -s "lh_pial.stl" -o "${results_folder}"
python ../isocontour_surface.py "${results_folder}/rh_wm.nii.gz" -s "rh_wm.stl" -o "${results_folder}"
python ../isocontour_surface.py "${results_folder}/lh_wm.nii.gz" -s "lh_wm.stl" -o "${results_folder}"



## The exposed surface can be defined in many different fashions.
## For now, I recommend using the same algorithm.
## However, if necessary, it is possible to use the convex hull of the pial hemisphere

../exposed_surface.sh -i "${results_folder}/rh_pial.stl" -o "${results_folder}" -s rh_exposed -S
../exposed_surface.sh -i "${results_folder}/lh_pial.stl" -o "${results_folder}" -s lh_exposed -S


## FreeSurfer attempt to reconstruct the surfaces
../freesurfer_surface.sh -s "FB141" \
                        -i "${data_folder}/FB141_BrainVolume_SkullStripped.nii.gz" \
                        -m "${data_folder}/FB141_BrainMask.nii.gz" \
                        -R "${data_folder}/rh_mask.nii.gz" \
                        -L "${data_folder}/lh_mask.nii.gz" \
                        -P "${results_folder}/pial.nii.gz" \
                        -W "${results_folder}/wm.nii.gz" \
                        -o "${results_folder}"