# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 08:12:34 2021

@author: RPL 2020
"""

from lib import loaddata,plot,ae,citra
from sklearn.model_selection import train_test_split
from cv2 import resize
import numpy as np

# In[]: Load data rekon dan miyawaki
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

# In[]: 
input_train,input_test=train_test_split(pred, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(label, test_size=0.1, random_state=42) 

# In[]: Encoder pastikan input dan output sama dengan dimenci vector begitu juga
autoencoder,encoder=ae.trainDenoise(input_train, output_train,input_test, output_test)

# In[]: Encoded Data
encoded_train = encoder.predict(input_train)
encoded_test = encoder.predict(input_test)

# In[]: Reconstructed Data
reconstructed = autoencoder.predict(pred)

# In[]: buat matrix gambar
stimulus=[]
hasilrekonstruksi=[]
hasilrecovery=[]
for impred in range(len(reconstructed)):
    stimulus.append(citra.dariRow(label[impred]))
    hasilrekonstruksi.append(citra.dariRow(pred[impred]))
    hasilrecovery.append(citra.dariRow(reconstructed[impred]))
# In[]: Plot gambar
plot.tigaKolomGambar('Autoencoder MLP Denoising','Stimulus',stimulus,'Rekonstruksi',hasilrekonstruksi,'Recovery',hasilrecovery) 
    



# In[]: untuk data cnn, resize ke 28x28
stim=[]
rekon=[]

for label,rek in zip(stimulus,hasilrekonstruksi):
    stim.append(resize(label,(28,28)))
    rekon.append(resize(rek,(28,28)))
# In[]:
input_train,input_test=train_test_split(rekon, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(stim, test_size=0.1, random_state=42) 

# In[]:
cnnautoencoder=ae.trainCNNDenoise(np.array(input_train), np.array(output_train),np.array(input_test), np.array(output_test))
         
# In[]: Reconstructed Data
reconstructedcnn = cnnautoencoder.predict(np.array(rekon))

# In[]: Plot gambar
plot.tigaKolomGambar('Autoencoder CNN Denoising','Stimulus',stimulus,'Rekonstruksi',hasilrekonstruksi,'Recovery',reconstructedcnn) 
                          
 
    
 # In[]: buat matrix gambar
from lib.denoise import recover
K=1
lmda=8
knndenoise=[]

for rekon in reconstructedcnn:
    knndenoise.append(recover(resize(rekon,(10,10)), K, lmda))

# In[]: plot gambar
plot.tigaKolomGambar('KNN Denoising','Stimulus',stimulus,'Rekonstruksi',hasilrekonstruksi,'Recovery',knndenoise)
    
