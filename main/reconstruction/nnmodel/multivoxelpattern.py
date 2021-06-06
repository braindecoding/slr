# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 04:38:55 2021
file pertama yang dijalankan: 
    berisi load data semua area, training dan predict kemudian save label dan predictnya
@author: rolly
"""
import bdtb


matlist=[]
matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')


archl=[]
archl.append('784_256_128_10')
archl.append('784_256_128_6')
archl.append('784_256_128_5')
archl.append('200_100')
archl.append('1')
matfile=matlist[0]
for arch in archl:
    # In[]: train and predict rolly
    bdtb.trainModel(matfile,arch)
    label,pred=bdtb.testModel(matfile,arch)
    #bdtb.simpanSemuaGambar(label,pred,matfile)
    mse=bdtb.simpanMSE(label,pred,matfile,arch)
    
    # In[1]: data pembanding dari miyawaki
    predm,labelm,msem=bdtb.simpanMSEMiyawaki()
    n=10
    lmse,lmsem,lpred,lpredm,llabel=bdtb.ubahkelistofchunks(mse,msem,pred,predm,label,n)
    
    # In[1]: disini runnya okay
    n=1
    for label,pred,predm,mse,msem in zip(llabel,lpred,lpredm,lmse,lmsem):
        bdtb.plotHasil(label, pred, predm, mse,msem,matfile,n,arch)
        n=n+1