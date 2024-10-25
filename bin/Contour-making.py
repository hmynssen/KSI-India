import os
import json

import nibabel
import numpy as np
import skimage
import matplotlib.pyplot as plt

def toyz(voxels):
    return np.swapaxes(voxels, 0, 1)

def toxz(voxels):
    return np.swapaxes(voxels, 0, 2)

def toxy(voxels):
    return np.swapaxes(voxels, 1, 2)

def makejsonPoints(x,y,z,number,island,mgz_data,dir):
    name = f"f{number}i{island}"
    coord = []
    center = [mgz_data.header['qoffset_x'],mgz_data.header['qoffset_y'],mgz_data.header['qoffset_z']]
    v_dim = mgz_data.header['pixdim']
    for i in range(x.shape[0]):
        coord.append(f"[{x[i]*v_dim[1]+center[0]},{y[i]*v_dim[1]+center[1]},{z*v_dim[1]+center[2]}]")
    text = {"ROI3DPoints" : []}
    text["ROI3DPoints"] = coord
    with open(f'{dir}/{name}.json',"w") as file:
        json.dump(text,file,indent=4)
    
save_dir = './results'
subj = 'FB141'
mgz_dir = './data'
pial_file = 'pial.nii.gz'
wm_file = 'wm.nii.gz'
files =  [pial_file,wm_file]
im_index = 0



for f in files:
    data = nibabel.load(f"{mgz_dir}/{subj}/{f}")
    img = toxz(data.get_fdata())
    img = toyz(img)
    vals = np.unique(img)
    type = f.split('.')[0]
    cwd = f"{save_dir}/{type}/{subj}" #folder to save contours
    if not os.path.isdir(cwd):
        os.makedirs(cwd)
    img_counter = 0
    for i in range(img.shape[0]):
        contours = skimage.measure.find_contours(img[img_counter],fully_connected='low')
        ## contours is a list (python) of arrays (np)
        if len(contours)<1:
            img_counter+=1
            continue

        for iindex,c in enumerate(contours): #if contours is empty, no loop
            if c.shape[0]<=10:
                continue
            makejsonPoints(c[:,1],c[:,0],img_counter+1,
                        img_counter+1,
                        iindex+1,
                        data,
                        cwd)
        img_counter+=1
