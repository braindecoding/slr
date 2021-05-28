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

# In[]: train and predict rolly
for matfile in matlist:
    #bdtb.trainModel(matfile)
    label,pred=bdtb.testModel(matfile)
    bdtb.simpanSemuaGambar(label,pred,matfile)
    mse=bdtb.simpanMSE(label,pred,matfile)

# In[1]: data pembanding dari miyawaki
predm,labelm,msem=bdtb.simpanMSEMiyawaki()

# In[1]:
bdtb.plotHasil(label, pred, predm, mse,msem,'coba')