# -*- coding: utf-8 -*-
"""
Created on Fri Aug 13 11:27:30 2021

@author: rolly
"""

import bdtb
from lib.denoise import recover
import matplotlib.pyplot as plt
import matplotlib.cm as cm

# In[]:
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
K=1
lmda=8
for impred in range(len(pred)):
    stimulus=bdtb.rowtoimagematrix(label[impred])
    hasilrekonstruksi=bdtb.rowtoimagematrix(pred[impred])
    hasilrecovery=recover(hasilrekonstruksi, K, lmda)
    fig, axs = plt.subplots(nrows=1, ncols=3, figsize=(12,4))
    plt.sca(axs[0])
    plt.imshow(stimulus, cmap=cm.gray)
    plt.axis('off')
    plt.title('Stimulus')
    plt.sca(axs[1])
    plt.imshow(hasilrekonstruksi, cmap=cm.gray)
    plt.axis('off')
    plt.title('hasilrekonstruksi')
    plt.sca(axs[2])
    plt.imshow(hasilrecovery, cmap=cm.gray)
    plt.axis('off')
    plt.title('hasilrecovery')
    #plt.tight_layout()
    plt.suptitle('Overall Title')
    plt.show()
    
