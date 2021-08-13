# -*- coding: utf-8 -*-
"""
Created on Fri Aug 13 11:27:30 2021

@author: rolly
"""

import bdtb
import numpy as np
from lib.denoise import corrupt_image_fast,recover


matlist=[]
matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')

# In[]: membangun model berdasarkan MLP arsitektur berikut(dalam list) 
archl=[]
archl.append('784_256_128_10')
archl.append('784_256_128_6')
archl.append('784_256_128_5')
archl.append('200_100')
archl.append('1')
matfile=matlist[0]#memilih satu file saja V1

# In[]: train and predict rolly
arch=archl[0]
label,pred=bdtb.testModel(matfile,arch)
# In[]: 
import matplotlib.pyplot as plt
import matplotlib.cm as cm
image_t=bdtb.rowtoimagematrix(label[1])
 
plt.imshow(image_t,cmap=cm.gray)
plt.axis('off')
    
# In[]: 
plt.figure(1)
index = 1
p=0.15
gambarjelek=corrupt_image_fast(image_t,p)
for p in np.linspace(0,1,21):
    plt.subplot(3,7,index)
    plt.title(repr("{:1.2f}".format(p)))
    plt.imshow( corrupt_image_fast(image_t,p), cmap=cm.gray)
    plt.axis('off')
    index+=1
    
# In[]: 
plt.imshow(recover(gambarjelek, 1, 3.5),cmap=cm.gray)
    
# In[]: 
    
    
# In[]: 
    
    
# In[]: 
        
# In[]: 