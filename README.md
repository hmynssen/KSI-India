# KSI-India
 KSI-India

# Dependencies:

## FreeSurfer
FreeSurfer is a cortical reconstruction software developed indepently from our lab. Check their own [instalation guideline](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) for version 7.0.0 or higher.

Please avoid using any version of FreeSurfer lower than 7.0.0 since it cause conflict.

## Python Dependencies
Below, all the python libraries necessary for this project:
- numpy
- scipy
- pymeshlab
- nibabel
- scikit-image
```python
pip install numpy scipy pymeshlab nibabel scikit-image
```

# General Usage
Inside the `./bin` folder, you'll find several scripts for creating binary masks and surfaces. However, the pipeline I designed should not require going through all of those scripts, instead one may simply copy the shell script example inside `./bin/example` and modify accordingly.

The pipeline itself consists of:
1. Concatenating the provided masks into:
    1. Gray matter/Cortical ribbon - will be transformed and used to reconstruct the pial surface
    2. Non cortical regions - to remove undesired regions from the reconstruction
    3. White matter - to reconstruct the white matter surface
2. Extract the main component of each of those three masks
3. Split them into right and left hemispheres
4. Reconstruct the pial and white matter surfaces per hemisphere
5. Compute the exposed surface of the pial surface

To perform those 5 steps, the user should e looking for the following scripts/commands

```console
foo@bar:~$ ./bin/pial_wm_masks.sh
foo@bar:~$ python ./bin/isocontour_surface.py
foo@bar:~$ ./bin/exposed_surface.sh
```




# Deprecated
## Mask manipulation
This basic shell script simply implements the routine:
 - binarize the extracted brain
 - overlay the binary brain with the desired ROI ( -> call it pial)
 - remove the structures such as the cerebellum
 - fill the holes with fslmaths -fillh
 - perform the subtraction $((pial - ROI)) to get the inner layer ( -> call it wm)
I've used an extra step to try to keep only one main component:

```console
foo@bar:~$ fslmaths *.nii.gz -eroF *.nii.gz
```

The reasoning behind this is because I belive that is what the real brain/ROI should look like.

## Contour making
Basic python script to generate a sequence of contours for each slice. The main algorithm to translate image->contour is the Canny-Edge.

To remove small artifacts, I selected a minimum (arbitrary) number of points that each perimeter should contain. This is an extra step to, again, attempt to keep only the main component.