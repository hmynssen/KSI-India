# KSI-India
 KSI-India

# Dependencies:

## FreeSurfer
FreeSurfer is a cortical reconstruction software developed indepently from our lab. Check their own [instalation guideline](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) for version 7.0.0 or higher.

Please avoid using any version of FreeSurfer lower than 7.0.0 since it cause conflict.

## FSL
FSL is an analysis tool commonly used in neuroscience. Check their own [instalation guideline](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/install/index).

This tool is necessary for the reconstruction using FreeSurfer.

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
***
# General Usage
Inside the `./bin` folder, you'll find several scripts for creating binary masks and surfaces. However, the pipeline I designed should not require going through all of those scripts, instead one may simply copy the shell script example inside `./bin/example` and modify accordingly.

The pipeline itself consists of:
1. Concatenating the provided masks into:
    1. Gray matter/Cortical ribbon - will be transformed and used to reconstruct the pial surface
    2. Non cortical regions - to remove undesired regions from the reconstruction
    3. White matter - to reconstruct the white matter surface
    3. CSF - Possibly needed to improve FreeSurfer's reconstruction
2. Extract the main component of each of those three masks
3. Split them into right and left hemispheres
4. Reconstruct the pial and white matter surfaces per hemisphere
5. (Optional) Compute the exposed surface of the pial surface

To perform those 5 steps, you should e looking for the following scripts/commands
* Without FreeSurfer
```console
foo@bar:~$ ./bin/pial_wm_masks.sh
foo@bar:~$ python ./bin/isocontour_surface.py
foo@bar:~$ ./bin/exposed_surface.sh
```
* With FreeSurfer
```console
foo@bar:~$ ./bin/pial_wm_masks.sh
foo@bar:~$ ./bin/freesurfer_surface.sh
```

Please check the documentation in `./bin` and inside each script for more details. Also, the example it self might provide further insights. 

## Required Data
For any given subject, you're going to need:
1. One brain extracted image
2. One brain segmentation mask (with all the segmentation tissues in a single file)
2.1. At least 2 tissue types are required in the maks: *gray matter (cortical plate)* and CSF. Note that some tissues, such as the *amygdala* and *hippocampus*, should be considered gray matter for this pipeline.
2.2. Other tissue types that are not the white matter should all be consired *non-cortical*, such as the *cerebellum* and *thalamus*.
2.3. Any tissue that is not marked as gray matter or non-cortical will be considered white matter. Do note that tissues fully surround by white matter should be considered white matter it self, such as the *corpus callosum*
3. One binary brain mask (which is simply the segmentation mask binarized, i.e., every tissue transformed to be 1 and the rest is 0)
4. Right and left hemispheres binary mask

For example, inside a folder:
``` 
.
└── Data/
    ├── Subject-0001/
    │   ├── Subj-0001-brain_extract.nii.gz
    │   ├── Subj-0001-segmentation.nii.gz
    │   ├── Subj-0001-brain_mask.nii.gz
    │   ├── Subj-0001-lh.nii.gz
    │   └── Subj-0001-rh.nii.gz
    └── Subject-0002/
        ├── Subj-0002-brain_extract.nii.gz
        ├── Subj-0002-segmentation.nii.gz
        ├── Subj-0002-brain_mask.nii.gz
        ├── Subj-0002-lh.nii.gz
        └── Subj-0002-rh.nii.gz
```
## Our Processing

Inside the processing folder in this repository, you will found some of the scripts that we used to process the data for the paper (INCLUDE PAPER HERE). Additionally, we used [**FSLMATHS**](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/install/index) for some processing to create some of the masks.

For example, we used to generate the whole brain mask the following:
```console
foo@bar:~$ fslmaths Subj-0002-segmentation.nii.gz -bin Subj-0002-brain_mask.nii.gz
```

Also, it important that the right and left hemisphere masks do not over lap. For one of the masks, it is also nice to have a perfect fit such that brain_mask == left + right. For both purposes, we can use the follwoing:
```console
foo@bar:~$ fslmaths Subj-0002-lh_raw.nii.gz -mul Subj-0002-brain_mask.nii.gz Subj-0002-lh.nii.gz
foo@bar:~$ fslmaths Subj-0002-brain_mask.nii.gz -sub Subj-0002-lh.nii.gz -bin Subj-0002-rh.nii.gz
```

***

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