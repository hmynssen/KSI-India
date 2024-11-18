#!/bin/bash 

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

./pial_wm_masks.sh -i FB141_BrainVolume_SkullStripped.nii.gz \
                    -m FB141_BrainMask.nii.gz \
                    -R rh_mask.nii.gz \
                    -L lh_mask.nii.gz \
                    -G "5" \
                    -E "2 6 8 11" \
                    -d "../data" \
                    -o "../results"

python isocontour_surface.py -