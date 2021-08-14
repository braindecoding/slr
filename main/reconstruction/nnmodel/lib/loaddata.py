# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 09:35:02 2021

@author: RPL 2020
"""

from lib import bdtb

def fromArch(i=0):
    # In[]:
    matlist=[]
    matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
    #matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
    #matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
    #matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
    #matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
    matfile=matlist[0]
    # In[]: membangun model berdasarkan MLP arsitektur berikut(dalam list) 
    archl=[]
    archl.append('784_256_128_10')
    archl.append('784_256_128_6')
    archl.append('784_256_128_5')
    archl.append('200_100')
    archl.append('1')
    matfile=matlist[0]#memilih satu file saja V1
    
    # In[]: train and predict rolly
    arch=archl[i]
    label,pred=bdtb.testModel(matfile,arch)
    allscoreresults=bdtb.simpanScore(label, pred, matfile, arch)
    return label,pred,allscoreresults

def Miyawaki():
    predm,labelm,scorem=bdtb.simpanScoreMiyawaki()
    return labelm,predm,scorem