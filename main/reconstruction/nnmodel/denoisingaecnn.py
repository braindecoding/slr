# -*- coding: utf-8 -*-
"""
Created on Mon Aug 16 06:42:45 2021

@author: RPL 2020
"""


from lib import loaddata,plot,ae,citra
from sklearn.model_selection import train_test_split
from cv2 import resize
import numpy as np

# In[]: Load data rekon dan miyawaki
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

# In[]: ubah ke matrix dan untuk data cnn, resize ke 28x28
stim=[]
rekon=[]

for li,pi in zip(label,pred):
    # stim.append(resize(citra.dariRow(li),(28,28)))
    # rekon.append(resize(citra.dariRow(pi),(28,28)))
    stim.append(citra.dariRow(li))
    rekon.append(citra.dariRow(pi))
# In[]:
input_train,input_test=train_test_split(rekon, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(stim, test_size=0.1, random_state=42) 

# In[]:
cnnautoencoder=ae.trainCNNDenoise10(np.array(input_train), np.array(output_train),np.array(input_test), np.array(output_test))
         
# In[]: Reconstructed Data
reconstructedcnn = cnnautoencoder.predict(np.array(rekon))

# In[]: Plot gambar
plot.tigaKolomGambar('Autoencoder CNN Denoising','Stimulus',stim,'Rekonstruksi',rekon,'Recovery',reconstructedcnn) 
                          
 