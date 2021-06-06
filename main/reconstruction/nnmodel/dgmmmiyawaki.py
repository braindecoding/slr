# -*- coding: utf-8 -*-
"""
Created on Fri Jun  4 13:25:26 2021

@author: rolly maulana awangga
"""

from dgmm import loadtrainandlabel


matlist=[]
matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')

# In[]: train and predict rolly
matfile=matlist[0]
train_data,label=loadtrainandlabel(matfile)


#bdtb.trainModel(matfile)
#label,pred=bdtb.testModel(matfile)
#bdtb.simpanSemuaGambar(label,pred,matfile)
#mse=bdtb.simpanMSE(label,pred,matfile)

# In[1]: data pembanding dari miyawaki
predm,labelm,msem=bdtb.simpanMSEMiyawaki()

# In[1]:
mse=mse.tolist()
msem=msem.tolist()
# In[1]:
n=10
lmse=list(bdtb.divide_chunks(mse, n))
lmsem=list(bdtb.divide_chunks(msem, n))
# In[1]:
lpred=list(bdtb.divide_chunks(pred, n))
lpredm=list(bdtb.divide_chunks(predm, n))
llabel=list(bdtb.divide_chunks(label, n))
# In[1]: disini runnya okay
n=1
for label,pred,predm,mse,msem in zip(llabel,lpred,lpredm,lmse,lmsem):
    bdtb.plotHasil(label, pred, predm, mse,msem,matfile,n)
    n=n+1