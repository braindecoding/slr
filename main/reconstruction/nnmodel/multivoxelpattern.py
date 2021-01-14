# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 04:38:55 2021

@author: rolly
"""
import bdtb
import scipy.io

matlist=[]
matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')

#matfile='../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat'
matfile='../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat'
for matfile in matlist:
    mat = scipy.io.loadmat(matfile)
    
    # In[]: load data random and train save model
    train_data,label=bdtb.loadtrainandlabel(mat)
    
    for x in range(1,101):
        labelperpx=bdtb.getlabel(label,x)
        path=bdtb.modelfolderpath(matfile)+str(x)
        bdtb.createmodel(train_data,labelperpx,path)
    
    # In[]: load data shape and predict dari data shape dan simpan dalam matrix piksel
    testdt,testlb=bdtb.loadtestandlabel(mat)
    
    import numpy as np
    
    pixel=1
    path=bdtb.modelfolderpath(matfile)+str(pixel)
    piksel=bdtb.generatePixel(path,testdt)
    for x in range(2,101):
        path=bdtb.modelfolderpath(matfile)+str(x)
        pikselbr=bdtb.generatePixel(path,testdt)
        piksel=np.concatenate((piksel,pikselbr),axis=1)
        
    # In[]: matrix to image label
        
    
    z=bdtb.delfirstCol(testlb)
    n=1
    for i in z:
        bdtb.saveFig(i,bdtb.figfile(matfile,n))
        n=n+1
        
    # In[]: matrix to image pembangkitan
    
    n=1
    for i in piksel:
        bdtb.saveFig(i,bdtb.figrecfile(matfile,n))
        n=n+1



