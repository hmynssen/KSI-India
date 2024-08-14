# KSI-India
 KSI-India

# Mask manipulation
This basic shell script simply implements the routine:

    - binarize the extracted brain
    - overlay the binary brain with the desired ROI ( -> call it pial)
    - remove the structures such as the cerebellum
    - fill the holes with fslmaths -fillh
    - perform the subtraction $((pial - ROI)) to get the inner layer ( -> call it wm)

I've used an extra step to try to keep only one main component:

```bash
    fslmaths *.nii.gz -eroF *.nii.gz
```

The reasoning behind this is because I belive that is what the real brain/ROI should look like.

# Contour making
Basic python script to generate a sequence of contours for each slice. The main algorithm to translate image->contour is the Canny-Edge.

To remove small artifacts, I selected a minimum (arbitrary) number of points that each perimeter should contain. This is an extra step to, again, attempt to keep only the main component.