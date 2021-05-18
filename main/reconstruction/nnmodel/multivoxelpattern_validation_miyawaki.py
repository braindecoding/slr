# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 04:38:55 2021
file ketiga yang dijalankan untuk menghitung mse miyawaki sebagai pembanding 
@author: rolly
"""
#import bdtb
#import scipy.io
from scipy import io
from numpy import savetxt

# In[]: dev
#matfile='../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat'
#mat = io.loadmat(matfile)
#train_data,label=bdtb.loadtrainandlabel(mat)
# In[]: start

directory='../imgRecon/result/s1/V1/smlr/'
matfilename='s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_figRecon_linComb-no_opt_1x1_maxProbLabel_dimNorm.mat'
matfile=directory+matfilename

mat = io.loadmat(matfile)

# In[]: load data shape and predict dari data shape dan simpan dalam matrix piksel
pred,label=mat['stimFigTestAllPre'],mat['stimFigTestAll']


# In[]: matrix to image label
mse = ((pred - label)**2).mean(axis=1)
savetxt('miyawaki.csv',mse,delimiter=',')

