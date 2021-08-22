# -*- coding: utf-8 -*-
"""
Created on Sat Aug 21 17:55:02 2021

@author: RPL 2020
"""

from lib import citra,loaddata,plot
from lib.denoise import recover
from sklearn.decomposition import PCA
from sklearn.preprocessing import MinMaxScaler
from sklearn.cluster import KMeans

import numpy as np

# In[]: Load data rekon dan miyawaki
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

# In[]:pca untuk menentukan jumlah layer
# kalau klasifikasi biner ambil cutoff sekitar 40%, kalau multi kelas 60-70%.kalau regresi ambil di atas 80%.
scaler = MinMaxScaler()
data_rescaled = scaler.fit_transform(label)
pca = PCA(n_components = 0.4)
pca.fit(data_rescaled)
reduced = pca.transform(data_rescaled)
print(pca.explained_variance_)

# In[]:kmeans untuk menentukan jumlah neuron

scaler = MinMaxScaler()
x_array=np.array(reduced)
x_scaled = scaler.fit_transform(x_array)
# In[]:
kmeans = KMeans(n_clusters = 5, random_state=123)
kmeans.fit(x_scaled)
print(kmeans.cluster_centers_)