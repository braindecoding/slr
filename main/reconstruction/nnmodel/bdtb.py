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
    # define the keras model
    model = Sequential()
    model.add(Dense(1024, input_dim=3412, activation='relu'))
    model.add(Dense(512, activation='relu'))
    model.add(Dense(128, activation='relu'))
    model.add(Dense(1, activation='sigmoid'))
    # compile the keras model
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
    model.fit(X, y, epochs=1500, batch_size=10)
    # evaluate the keras model
    _, accuracy = model.evaluate(X, y)
    print('Accuracy: %.2f' % (accuracy*100))
    model.save(str(filename))
    
def generatePixel(pxpath,data):
    model = load_model(pxpath)
    return model.predict_classes(data)

def showFig(az):
    gbr = az.reshape((10,10)).T
    plt.imshow(gbr)
    
def saveFig(az,fname):
    data = az.reshape((10,10)).T
    new_data = np.zeros(np.array(data.shape) * 10)
    for j in range(data.shape[0]):
        for k in range(data.shape[1]):
            new_data[j * 10: (j+1) * 10, k * 10: (k+1) * 10] = data[j, k]
    plt.imsave(str(fname),new_data)
    
def delfirstCol(testlb):
    return np.delete(testlb,0,1)

    