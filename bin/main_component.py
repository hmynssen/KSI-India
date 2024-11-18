"""Main Component Extraction

Identifies main fully connected component in a 
given image and saves it as binary mask.

Heitor Gessner,
16/11/2024
"""
import argparse
import sys

import numpy as np
import nibabel as nib
from skimage.measure import label


def main_component(image):
    img = label(image)
    img = np.array(img)
    numbers, counts = np.unique(img, return_counts=True)
    aux = 0
    for n,c in zip(numbers,counts):
        if c>aux and not n==0:
            chosen = n
            aux = c
    truth = np.array(img[:,:]==chosen,dtype=np.int32)
    main_image = np.multiply(img,truth)
    main_image = main_image/chosen
    return main_image

if __name__=="__main__":
    if len(sys.argv)>1:
        parser = argparse.ArgumentParser(
                    prog='Main Component Extraction',
                    description=__doc__,
                    formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument('filename', help='Input file (include full path)')
        parser.add_argument('-o', '--output', default='./', help='Output Folder')
        parser.add_argument('-s', '--save', default='output.nii.gz', help='Name of the output file')
        args = parser.parse_args()
        mask_volume = nib.load(args.filename)
        arr = mask_volume.get_fdata()
        output_dir = args.output
        output_name = args.save
    else:
        mask_volume = nib.load('./results/FB141/wm.nii.gz')
        arr = mask_volume.get_fdata()
        output_dir = './results/FB141'
        output_name = 'wm_main.nii.gz'
    
    arr = main_component(arr)
    if output_name:
        x = nib.Nifti1Image(arr, mask_volume.affine, mask_volume.header)
        nib.save(x, f'{output_dir}/{output_name}')