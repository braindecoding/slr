# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 08:12:34 2021

@author: RPL 2020
"""

from lib import loaddata,plot,ae
from sklearn.model_selection import train_test_split


# In[]: Target Dimension miyawaki start dari sini karena sudah reshape daro 10x10 menjadi 100 vector
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

# In[]: Plot gambar
plot.tigaKolomGambar('Autoencoder Denoising',label, pred, reconstructed)

    
