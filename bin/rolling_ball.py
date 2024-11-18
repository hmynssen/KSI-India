"""Adaptation of FreeSurfer's outer_surface in matlab

Inputing a nifti file representing the voxelized pial surface,
it creates the exposed surface by the rolling ball method.

To dos:
    - allow image size to flexiable; currently only 256x256x256 1mm isovoxel is acceptable
    - improve marching cubes; it creates too many holes and non-manifold faces


Heitor Mynssen,
24/10/2024
"""

import os
import sys
import argparse

import numpy as np
import scipy.ndimage
import scipy.io
import nibabel as nib
import pymeshlab as ml
from skimage.measure import marching_cubes

def rolling_ball(filled_volume, blur_cutoff = 15, ball_diameter = 15, output_surface = ''):

    sys.stdout.write('Reading nifti volume\n')
    vol = nib.load(filled_volume)
    volume = np.array(vol.dataobj)
    volume[volume >= 1] = 255
    sys.stderr.write('Done\n')


    sys.stderr.write('Bluring and colpasing sulci\n')
    gaussian = scipy.ndimage.gaussian_filter(np.ones((2, 2)), sigma=1)
    image_f = np.zeros((256, 256, 256))
    for slice in range(256):
        temp = volume[:, :, slice].astype(float)
        image_f[:, :, slice] = scipy.ndimage.convolve(temp, gaussian, mode='constant')

    image2 = np.zeros_like(image_f)
    image2[image_f <= blur_cutoff] = 0
    image2[image_f > blur_cutoff] = 255

    rolling_ball = scipy.ndimage.generate_binary_structure(3, ball_diameter)
    BW2 = scipy.ndimage.binary_closing(image2, structure=rolling_ball)
    thresh = np.max(BW2) / 2
    BW2[BW2 <= thresh] = 0
    BW2[BW2 > thresh] = 255
    sys.stderr.write('Done\n')

    if not output_surface:
        output_name = 'result.stl'
    else:
        output_name = output_surface
    if not '.stl'==output_surface[-4:]:
        output_name = f'{output_surface}.stl'

    sys.stderr.write(f'Saving to {output_name}\n')
    verts, faces, _, _ = marching_cubes(BW2, 0)
    #reorient to FS standard
    v2 = np.column_stack((128 - verts[:, 0], verts[:, 2] - 128, 128 - verts[:, 1]))
    verts = v2
    ms = ml.MeshSet()
    ms.add_mesh(
        ml.Mesh(
            verts,
            faces,
        )
    )
    ms.generate_splitting_by_connected_components()
    ms.set_current_mesh(1)
    ms.save_current_mesh(output_name)
    sys.stderr.write('Done\n\n')


if __name__=="__main__":
    if len(sys.argv)>1:
        parser = argparse.ArgumentParser(
                    prog='Rolling Ball Method',
                    description=__doc__,
                    formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument('filename', help='Input file')
        parser.add_argument('-b', '--blur', default=15, type=int, help='Gaussian blur cutoff based on max 255 brithgness')
        parser.add_argument('-d', '--diameter', default=15, type=int, help='Diameter of the ball that will roll over the brain')
        parser.add_argument('-s', '--save', default='output.stl', help='Name of the output file')
        parser.usage = parser.format_help()
        args = parser.parse_args()
        filled_volume = args.filename
        blur_cutoff = args.blur
        diameter = args.diameter ## usually in mm since the .nii image from FS is 256x256x256 isovoxel 1mm
        output_name = args.save
    else:
        path = 'D:/freesurfer/Subjects/sub-0000/surf'
        os.chdir(path)
        filled_volume = 'rh.pial.filled.nii'
        output_name = 'rh-exposed.stl'
        blur_cutoff = 15
        diameter = 15 ## usually in mm since the .nii image from FS is 256x256x256 isovoxel 1mm
    rolling_ball(filled_volume, 
                 blur_cutoff = blur_cutoff,
                 ball_diameter = diameter, 
                 output_surface = output_name)