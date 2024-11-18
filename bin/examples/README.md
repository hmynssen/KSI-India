# Creating the masks
Necessary files:
```
- MRI image:                     FB141_BrainVolume_SkullStripped.nii.gz
- Binary mask:                   FB141_BrainMask.nii.gz
- Right hemisphere (RH) mask:    rh_mask.nii.gz
- Left hemisphere (LH) mask:     lh_mask.nii.gz
```

Inside the Binary mask, you should find the color values for the gray matter or cortical plate and use it as input argument for the `-G` flag. 

Also inside binary mask, find the color values of regions that should not be reconstructed such as the cerebellum. Use it as input argument for the `-E` flag.

Any other color value will be treated as white matter, therefore:

$$ Brain = GM + WM - E $$

Also, we desire to reconstruct 3 surfaces from those masks:
- $\text{Pial\ surface} = GM + WM - E$
- $\text{White\ matter\ surface} = WM - E$
<<<<<<< HEAD
- $\text{Exposed\ surface} = rolling\textunderscore ball(\text{Pial\ surface}) \approx convex\textunderscore hull(\text{Pial\ surface})$


# Making the surfaces
## Pial and White Matter Surfaces
This step is the one that needs the most improvements. Isocontouring is very simple but very limited when brains gets gyrified. Opposing sides on the pial sulci start to get fully contained in a single voxel, and that's when the isocontour fails. So for a sulci spacing $\approx$ voxel size, we'll need to improve this approach considerably

FreeSurfer might be enough to fix this but will require further coding. I'll update this example later with a fully working code, but let's try this one for now.

Last modified, 18/11/2024

## Exposed Surface
FreeSurfer used to provide an algorithm for calculating the exposed surface. Unfortunately, they removed this feature, so I reimplemented it in python.

I'm currently calling it the Rolling Ball Method, but originally it had no name. More details can be found in the python script `rolling_ball.py`.

This method is a bit more precise and cerrtainly more generic than simply using the convex hull. Note that the rolling ball exposed area is always greater than the convex hull area and should be considerably smaller than the pial area for gyrified brains.

=======
- $\text{Exposed\ surface} = rolling\textunderscore ball(Pial\ surface) ~= convex\textunderscore hull(Pial\ surface)$
>>>>>>> ec5eedda8797a171eaa816b4fc5cbb3b7a80e30f
