# -*- coding: utf-8 -*-
"""
Created on Fri Jan  8 17:15:32 2021

@author: rolly
"""
from tensorflow.keras.models import Sequential,load_model
from tensorflow.keras.layers import Dense
import numpy as np
import matplotlib.pyplot as plt
from tensorflow import device
from tensorflow.python.client.device_lib import list_local_devices
import scipy.io

def trainModel(matfile):
    mat = scipy.io.loadmat(matfile)
    train_data,label=loadtrainandlabel(mat)
    for x in range(1,101):#pembentukan model dari pixel 1-100
            labelperpx=getlabel(label,x)#mendapatkan label per pixel
            path=modelfolderpath(matfile)+str(x)#melakukan set path model
            createmodel(train_data,labelperpx,path)#membuat dan menyimpan model

def testModel(matfile):
    mat = scipy.io.loadmat(matfile)
    testdt,testlb=loadtestandlabel(mat)
    pixel=1
    path=modelfolderpath(matfile)+str(pixel)
    piksel=generatePixel(path,testdt)
    for x in range(2,101):
        path=modelfolderpath(matfile)+str(x)
        pikselbr=generatePixel(path,testdt)
        piksel=np.concatenate((piksel,pikselbr),axis=1)
    pxlb=delfirstCol(testlb)
    return pxlb,piksel

def simpanSemuaGambar(pxlb,piksel,matfile):
    n=1
    for stim,recon in zip(pxlb,piksel):
        simpanGambar(stim,recon,getfigpath(matfile,'reconstruct',n))
        n=n+1

def simpanMSE(pxlb,piksel,matfile):
    #mse sendiri
    mse = ((pxlb - piksel)**2).mean(axis=1)
    np.savetxt(msefilename(matfile),mse,delimiter=',')
    # mse miyawaki
    
def simpanMSEMiyawaki():
    directory='../imgRecon/result/s1/V1/smlr/'
    matfilename='s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_figRecon_linComb-no_opt_1x1_maxProbLabel_dimNorm.mat'
    matfile=directory+matfilename
    mat = scipy.io.loadmat(matfile)
    pred,label=mat['stimFigTestAllPre'],mat['stimFigTestAll']
    mse = ((pred - label)**2).mean(axis=1)
    np.savetxt('miyawaki.csv',mse,delimiter=',')

def testingGPUSupport():
    local_device_protos = list_local_devices()
    print(local_device_protos)

def runOnGPU(model):
    with device('/gpu:0'):
        model.fit()

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
    print('feature leength : ')#967
    print(featurelength)
    # define the keras model
    model = Sequential()
    model.add(Dense(784, input_dim=featurelength, activation='relu'))
    model.add(Dense(256, activation='relu'))
    model.add(Dense(128, activation='relu'))
    model.add(Dense(10, activation='relu'))
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
    return fullpath.split('\\')[-2]
    
def createfolder(foldername):
    import os
    if not os.path.exists(foldername):
        print('membuat folder baru : '+foldername)
        os.makedirs(foldername)
    
def saveFig(az,fname):
    createfolder(getfoldernamefrompath(fname))
    data = az.reshape((10,10)).T
    new_data = np.zeros(np.array(data.shape) * 10)
    for j in range(data.shape[0]):
        for k in range(data.shape[1]):
            new_data[j * 10: (j+1) * 10, k * 10: (k+1) * 10] = data[j, k]
    print('menyimpan gambar : '+fname)
    plt.imsave(str(fname),new_data)

def simpanGambar(stim,recon,fname):
    createfolder(getfoldernamefrompath(fname))
    plt.figure()
    sp1 = plt.subplot(131)
    sp1.axis('off')
    plt.title('Stimulus')
    sp2 = plt.subplot(132)
    sp2.axis('off')
    plt.title('Reconstruction')
    sp3 = plt.subplot(133)
    sp3.axis('off')
    plt.title('Binarized')
    sp1.imshow(stim.reshape((10,10)).T, cmap=plt.cm.gray,
               interpolation='nearest'),
    sp2.imshow(recon.reshape((10,10)).T, cmap=plt.cm.gray,
               interpolation='nearest'),
    sp3.imshow(np.reshape(recon > .5, (10, 10)).T, cmap=plt.cm.gray,
               interpolation='nearest')
    plt.savefig(fname)
#np.reshape(recon > .5, (10, 10))
#np.reshape(y_pred[j], (10, 10))    
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

def getfigpath(matfile,suffix,n):
    import pathlib
    scriptDirectory = pathlib.Path().absolute()
    figfolderpath=str(scriptDirectory)+'\\'+matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'_'+suffix+'\\'+str(n)+'.png'
    print('generate path gambar : '+figfolderpath)
    return figfolderpath

def msefilename(matfile):
    figfolderpath=matfile.split('_')[2]+'_'+matfile.split('_')[-2]+'_mse.csv'
    return figfolderpath
