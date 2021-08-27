# -*- coding: utf-8 -*-

import os
import numpy as np
import nibabel as nib
import matplotlib.pyplot as plt
from bids import BIDSLayout, BIDSValidator
from nilearn.plotting import view_img, plot_glass_brain, plot_anat, plot_epi
from skimage.util import montage



# In[]: BIDS
data_path='C:\\Users\\RPL 2020\\Documents\\fMRIMiyawaki'

layout = BIDSLayout(data_path, derivatives=True)
print(layout)

subjek=layout.get(target='subject', return_type='id', scope='raw')
files=layout.get(target='subject', scope='raw', suffix='bold', return_type='file')

jenispercobaan=layout.get_task()
filerunrandom=layout.get(task='viewRandom', suffix='bold', scope='raw')

summary=layout.to_df()

# In[]:
data = nib.load(layout.get(subject='01', scope='raw', suffix='T1w', return_type='file', extension='nii.gz')[0])

func = nib.load(layout.get(subject='01', scope='raw', suffix='bold', return_type='file', extension='nii.gz')[0])

# In[]:

plt.imshow(data.get_fdata()[:,:,59])
# In[]:
plt.imshow(func.get_fdata()[:,:,19,11])

# In[]:
fmri = func.get_fdata()[:,:,:,0]#ambil data fmri detik pertama

lst=montage(fmri)

fig, ax1 = plt.subplots(1, 1, figsize = (64, 64))
ax1.imshow(lst)
fig.savefig('ct_scan.png')
# In[]:
plot_anat(data)
plot_anat(data, draw_cross=False, display_mode='z')
plot_epi(data)
plot_glass_brain(data)
data.mean().plot()
# In[]: 
mask_path='C:\\Users\\RPL 2020\\Documents\\fMRIMiyawaki\\sub-01\\ses-01\\func'
anatpath='C:\\Users\\RPL 2020\\Documents\\fMRIMiyawaki\\sub-01\\ses-01\\anat'
anatfile='sub-01_ses-01_inplaneT2.nii.gz'
mask1='sub-01_ses-01_task-viewRandom_run-01_bold.nii.gz'
anatomi = os.path.join(anatpath, anatfile)
masking1 = os.path.join(mask_path, mask1)
# In[]: 

anat = nib.load(anatomi).get_fdata()
msk1 = nib.load(masking1).get_fdata()


# In[]: iterasi gambar satu per satu
#urutanarray=anat.shape[0]//2
#granat=anat[13]
for granat in anat:
    fig, ax1 = plt.subplots(1, 1, figsize = (20, 20))
    ax1.imshow(granat)
    
# In[]: gambar langsung di gabung jadi satu dengan montase
from skimage.util import montage
lst=montage(anat)
fig, ax1 = plt.subplots(1, 1, figsize = (200, 200))
ax1.imshow(montage(anat), cmap ='bone')
fig.savefig('ct_scan.png')
# In[]: 
fig, (ax1, ax2) = plt.subplots(1,2, figsize = (12, 6))
ax1.imshow(anat[anat.shape[0]//2])
ax1.set_title('Image')
ax2.imshow(msk1[msk1.shape[0]//2])
ax2.set_title('Mask')