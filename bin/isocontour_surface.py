"""
Simple isocontouring for surface generation using marching cubes.

Same procedure as done in ITK-snap, 3D Slicer, Osirix, Horos and many others.

However this is not as robust as FreeSurfer or Stitcher methods which are capable
of reconstructing the surfaces with the sulci in their full depth.


Heitor Gessner,
17/11/2024
"""
import os
import sys
import argparse

import numpy as np
import nibabel as nib
import pymeshlab as ml
from skimage.measure import marching_cubes

def isocontour(image,dimensions,output_dir,output_surface):
    if not output_surface:
        output_name = 'result.stl'
    else:
        output_name = output_surface
    if not '.stl'==output_surface[-4:]:
        output_name = f'{output_surface}.stl'
    sys.stderr.write(f'Saving surface {output_name}\n in {output_dir}')
    verts, faces, _, _ = marching_cubes(image, 0)
    verts = np.multiply(verts,dimensions)
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
    pwd = os.getcwd()
    os.chdir(output_dir)
    ms.save_current_mesh(output_surface)
    sys.stderr.write('Done\n\n')
    os.chdir(pwd)


if __name__=="__main__":
    if len(sys.argv)>1:
        parser = argparse.ArgumentParser(
                    prog='Main Component Extraction',
                    description=__doc__,
                    formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument('filename', help='Input file (include full path)')
        parser.add_argument('-s', '--save', default='output.stl', help='Name of the output file')
        parser.add_argument('-o', '--output', default='./', help='Output Folder')
        parser.usage = parser.format_help()
        args = parser.parse_args()
        mask_volume = nib.load(args.filename)
        img = mask_volume.get_fdata()
        dim = mask_volume.header["pixdim"][1:4]
        output_name = args.save
        output_dir = args.output
    else:
        mask_volume = nib.load('./results/FB141/wm.nii.gz')
        img = mask_volume.get_fdata()
        dim = mask_volume.header["pixdim"][1:4]
        output_name = 'wm.stl'
        output_dir = './results/FB141'
    isocontour(img,dimensions=dim,output_dir=output_dir,output_surface=output_name)