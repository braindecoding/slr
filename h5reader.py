# -*- coding: utf-8 -*-
"""
Created on Sun Sep  1 11:27:25 2019

@author: rolly
"""
import h5py
import numpy as np

filename = "RockPaperScissors.h5"

with h5py.File(filename,'r') as hdf:
    ls=list(hdf.keys())
    print('list of datasets in this file: \n',ls)
    data=hdf.get('dataset1')
    dataset1=np.array(data)
    print('Shape of dataset1:\n',dataset1.shape)

# In[]

f=h5py.File(filename,'r')
ls=list(f.keys())


# In[]

group1 = f['group1']  # VSTOXX futures data
group2 = f['group2']  # VSTOXX call option data

# In[]

print(group1)

# In[]
f.close()