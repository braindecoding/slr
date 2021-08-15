# -*- coding: utf-8 -*-
"""
Created on Fri Aug 13 11:27:30 2021

@author: rolly
"""

from lib import citra,loaddata,plot
from lib.denoise import recover


# In[]: Load data rekon dan miyawaki
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

# In[]: buat matrix gambar

K=1
lmda=8
stimulus=[]
hasilrekonstruksi=[]
hasilrecovery=[]
for impred in range(len(pred)):
    stimulus.append(citra.dariRow(label[impred]))
    rekon=citra.dariRow(pred[impred])
    hasilrekonstruksi.append(rekon)
    hasilrecovery.append(recover(rekon, K, lmda))

# In[]: plot gambar
plot.tigaKolomGambar('KNN Denoising','Stimulus',stimulus,'Rekonstruksi',hasilrekonstruksi,'Recovery',hasilrecovery)

    
