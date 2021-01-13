# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 04:38:55 2021

@author: rolly
"""
import bdtb
import scipy.io

#matfile='../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat'
matfile='../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat'
mat = scipy.io.loadmat(matfile)


# In[]: load data
train_data,label=bdtb.loadtrainandlabel(mat)
# In[]: train and save mmodel
for x in range(1,101):
    labelperpx=bdtb.getlabel(label,x)
    bdtb.createmodel(train_data,labelperpx,'.\\1x1\\label'+str(x))


# In[]: testing aja untuk melihad data
a,b=bdtb.loaddatanorest(mat)

# In[]: load data norest
testdt,testlb=bdtb.loadtestandlabel(mat)

# In[]: predict dari data shape dan simpan dalam matrix piksel

import numpy as np

pixel=1
piksel=bdtb.generatePixel('.\\1x1\\label'+str(pixel),testdt)
for x in range(2,101):
    pikselbr=bdtb.generatePixel('.\\1x1\\label'+str(x),testdt)
    piksel=np.concatenate((piksel,pikselbr),axis=1)
    
# In[]: matrix to image label
    

z=bdtb.delfirstCol(testlb)
n=1
for i in z:
    bdtb.saveFig(i,'.\\fig\\'+str(n)+'.png')
    n=n+1
    
# In[]: matrix to image pembangkitan

n=1
for i in piksel:
    bdtb.saveFig(i,'.\\figrec\\'+str(n)+'.png')
    n=n+1
    
# In[]:

