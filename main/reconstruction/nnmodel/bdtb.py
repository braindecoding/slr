# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 17:15:32 2021

@author: rolly
"""
from tensorflow.keras.models import Sequential,load_model
from tensorflow.keras.layers import Dense
import numpy as np
import matplotlib.pyplot as plt

def loaddatanorest(mat):
    mdata =mat['D']
    mdtype = mdata .dtype 
    ndata = {n: mdata[n][0, 0] for n in mdtype.names}
    label = ndata['label']
    data = ndata['data']
    nl=[]
    nd=[]
    for l,d in zip(label,data):
        if l[1] < 2:
            nl.append(l)
            nd.append(d)
    return nl,nd

def loadtestandlabel(mat):
    nl,nd=loaddatanorest(mat)
    label=nl[440:]
    data=nd[440:]
    return np.asarray(data, dtype=np.float64),np.asarray(label, dtype=np.float64)
    
def loadtrainandlabel(mat):
    nl,nd=loaddatanorest(mat)
    alllabel=nl[:440]
    rdata=nd[:440]
    return np.asarray(rdata, dtype=np.float64),np.asarray(alllabel, dtype=np.float64)

def getlabel(alllabel,x):
    px1=[]
    for i in alllabel:
        px1.append(i[x])        
    label_data=np.asarray(px1, dtype=np.float64)
    return label_data

#https://machinelearningmastery.com/tutorial-first-neural-network-python-keras/
def createmodel(train_data,label_data,filename):
    X = train_data
    y = label_data
    featurelength=len(train_data[0])
    # define the keras model
    model = Sequential()
    model.add(Dense(12, input_dim=featurelength, activation='relu'))
    model.add(Dense(8, activation='relu'))
    #model.add(Dense(128, activation='relu'))
    model.add(Dense(1, activation='sigmoid'))
    # compile the keras model
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
    model.fit(X, y, epochs=1500, batch_size=100)
    # evaluate the keras model
    _, accuracy = model.evaluate(X, y)
    print('Accuracy: %.2f' % (accuracy*100))
    model.save(str(filename))
    
def generatePixel(pxpath,data):
    model = load_model(pxpath)
    #return model.predict_classes(data)
    res = model.predict(data)
    #print(res)
    return res

def showFig(az):
    gbr = az.reshape((10,10)).T
    plt.imshow(gbr)

def getfoldernamefrompath(fullpath):
    return fullpath.split('\\')[1]
    
def createfolder(foldername):
    import os
    if not os.path.exists(foldername):
        os.makedirs(foldername)
    
def saveFig(az,fname):
    createfolder(getfoldernamefrompath(fname))
    data = az.reshape((10,10)).T
    new_data = np.zeros(np.array(data.shape) * 10)
    for j in range(data.shape[0]):
        for k in range(data.shape[1]):
            new_data[j * 10: (j+1) * 10, k * 10: (k+1) * 10] = data[j, k]
    plt.imsave(str(fname),new_data)
    
def delfirstCol(testlb):
    return np.delete(testlb,0,1)

def modelfolderpath(matfile):
    mpath='.\\'+matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'\\'
    return mpath

def figfile(matfile,n):
    figfolderpath='.\\'+matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'_fig'+'\\'+str(n)+'.png'
    return figfolderpath

def figrecfile(matfile,n):
    figfolderpath='.\\'+matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'_figrec'+'\\'+str(n)+'.png'
    return figfolderpath

def msefilename(matfile):
    figfolderpath=matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'_mse.csv'
    return figfolderpath
