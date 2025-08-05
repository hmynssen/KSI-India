'''
Heitor Gessner,
04/08/2025
'''
import argparse
import sys

import numpy as np
import nibabel as nib


if __name__=="__main__":
    if len(sys.argv)>1:
        parser = argparse.ArgumentParser(
                    prog='Add random noise to brain.finalsurfs.mgz - saves as .nii.gz',
                    description=__doc__,
                    formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument('-p', '--pial', default='./pial.nii.gz', help='Cortical ribbon/Gray matter')
        parser.add_argument('-w', '--white', default='./wm.nii.gz', help='White matter')
        parser.add_argument('-o', '--output', default='./', help='Output folder')
        args = parser.parse_args()
        output_dir = args.output
    else:
        exit()
    np.random.seed(1234)
    volume = nib.load(f'{args.pial}')
    pial = volume.get_fdata()
    wm = nib.load(f'{args.white}').get_fdata()
    pial[pial>0] = 1
    wm[wm>0] = 1
    img = np.random.uniform(-5,+5,wm.shape)*wm+wm*110.0 + np.random.uniform(-5,+5,pial.shape)*pial+pial*60.0
    x = nib.Nifti1Image(img, volume.affine, volume.header)
    nib.save(x, f'{output_dir}/brain.finalsurfs.nii.gz')