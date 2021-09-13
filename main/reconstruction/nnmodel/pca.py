# -*- coding: utf-8 -*-
"""
Created on Fri Aug 27 10:59:28 2021

@author: rolly maulana awangga
"""

from lib import bdtb,ae,plot,citra,loaddata
from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA
from sklearn.model_selection import train_test_split


matlist=[]
matlist.append('../de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V1V2_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_V3VP_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
#matlist.append('../de_s1_AllArea_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')

# In[]: membangun model berdasarkan MLP arsitektur berikut(dalam list) 
archl=[]
archl.append('784_256_128_10')
archl.append('784_256_128_6')
archl.append('784_256_128_5')
archl.append('200_100')
archl.append('1')
matfile=matlist[0]#memilih satu file saja V1

# In[]: data preparasi reduksi dimennsi dengan PCA,karena pca dari shape dan random berbeda cobaan kita gabung saja

randomtrain,randomlabel=bdtb.getdatatrainfrommat(matfile)
scaler = MinMaxScaler()
data_rescaled = scaler.fit_transform(randomtrain)
pca = PCA(n_components = 0.854)
pca.fit(data_rescaled)
reduced = pca.transform(data_rescaled)

# In[]: 
input_train,input_test=train_test_split(reduced, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(randomlabel, test_size=0.1, random_state=42) 

# In[]: train and predict rolly

autoencoder,encoder=ae.trainDenoise(input_train,output_train,input_test,output_test)

# In[]: Encoded Data
encoded_train = encoder.predict(input_train)
encoded_test = encoder.predict(input_test)

# In[]: Reconstructed Data, antara nilai cut off shape dan random berbeda, ini masalah barunya
shapetest,shapelabel=bdtb.getdatatestfrommat(matfile)
scaler = MinMaxScaler()
data_rescaledshape = scaler.fit_transform(shapetest)
pca = PCA(n_components = 0.9905)
pca.fit(data_rescaledshape)
reducedshapedt = pca.transform(data_rescaledshape)

reconstructed = autoencoder.predict(reducedshapedt)

# In[]: buat matrix gambar
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

stimulus=[]
hasilrekonstruksi=[]
hasilrecovery=[]
for impred in range(len(reconstructed)):
    stimulus.append(citra.dariRow(labelm[impred]))
    hasilrekonstruksi.append(citra.dariRow(predm[impred]))
    hasilrecovery.append(citra.dariRow(reconstructed[impred]))
    
# In[]: Plot gambar

plot.tigaKolomGambar('Rekonstruksi PCA','Stimulus',stimulus,'Miyawaki',hasilrekonstruksi,'Rolly',hasilrecovery) 
