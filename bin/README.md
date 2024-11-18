# Creating the masks
~~

# Creating Pial and White Matter Surfaces
~~


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
