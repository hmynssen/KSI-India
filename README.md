# KSI-India
 KSI-India

# Dependencies:

## FreeSurfer
FreeSurfer is a cortical reconstruction software developed indepently from our lab. Check their own instalation guideline for version 7.0.0 or higher.

Please avoid using any version of FreeSurfer lower than 7.0.0 since it cause conflict.

## Python Dependencies
 - numpy
 - scipy
 - pymeshlab
 - nibabel
 - scikit-image
```console
foo@bar:~$ pip install numpy scipy pymeshlab nibabel scikit-image
```

# General Usage


# Creating the Exposed Surface
Adaptation of FreeSurfer's outer_surface in matlab

Inputing a nifti file representing the voxelized pial surface,
it creates the exposed surface by the rolling ball method.

## To dos:
 - allow image size to flexiable; currently only 256x256x256 1mm isovoxel is acceptable
 - improve marching cubes; it creates too many non-manifold faces and holes



## Usage of exposed_surface
This shell creates the Nifti image from the $h.pial surface created with FreeSurfer. The image is binary, with values 0 and 1 only. Inside the rolling ball this will be maped into 0 and 255 respectively.

Simply set the proper SUBJECTSPATH and set the range to loop over the subjects in that folder.

Also, one may choose the blur cutoff value and the diameter of the rolling ball. This first parameter is simply a value of brightness ranging from 0 to 255 used after the gaussian blur (sigma set to 2). The cutoff is the criteria to re-binarize the image.

## Usage of rolling_ball
```console
foo@bar:~$ python rolling_ball.py input_name.nii -b 15 -d 15 -s output.stl
```
With the options:
 - b, --blur        Gaussian blur cutoff (int) based on max 255 brithgness
 - d, --diameter    Diameter (int) of the ball that will roll over the brain
 - s, --save        Name of the output file

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