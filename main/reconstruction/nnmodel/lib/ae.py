# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 01:46:53 2021

@author: RPL 2020
"""
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.datasets import mnist
from lib import loaddata
from sklearn.model_selection import train_test_split


def trainDenoise(input_train, output_train,input_test, output_test):
    TARGET_DIM = 10
    INPUT_OUTPUT = 100 #100 untuk data miyawaki
    # In[]: Encoder pastikan input dan output sama dengan dimenci vector begitu juga
    inputs = Input(shape=(INPUT_OUTPUT,))
    h_encode = Dense(85, activation='relu')(inputs)
    h_encode = Dense(65, activation='relu')(h_encode)
    h_encode = Dense(35, activation='relu')(h_encode)
    h_encode = Dense(15, activation='relu')(h_encode)
    
    # In[]: Coded
    encoded = Dense(TARGET_DIM, activation='relu')(h_encode)
    
    # In[]: Decoder
    h_decode = Dense(15, activation='relu')(encoded)
    h_decode = Dense(35, activation='relu')(h_decode)
    h_decode = Dense(65, activation='relu')(h_decode)
    h_decode = Dense(85, activation='relu')(h_decode)
    outputs = Dense(INPUT_OUTPUT, activation='sigmoid')(h_decode)
    
    # In[]: Autoencoder Model
    autoencoder = Model(inputs=inputs, outputs=outputs)
    
    # In[]: Encoder Model
    encoder = Model(inputs=inputs, outputs=encoded)
    
    # In[]: Optimizer / Update Rule
    adam = Adam(learning_rate=0.001)
    
    # In[]: Compile the model Binary Crossentropy
    autoencoder.compile(optimizer=adam, loss='binary_crossentropy')
    print(autoencoder.summary())
    
    # In[]: Train and Save weight
    autoencoder.fit(input_train, output_train, batch_size=256, epochs=100, verbose=1, shuffle=True, validation_data=(input_test, output_test))
    autoencoder.save_weights('autoencoder.h5')
    
    # In[]: Encoded Data
    encoder.save_weights('encoder.h5')
    #encoded_train = encoder.predict(input_train)
    #encoded_test = encoder.predict(input_test)
    return autoencoder,encoder


def trainModel(input_train, output_train,input_test, output_test):
    TARGET_DIM = 16
    INPUT_OUTPUT = 784 #100 untuk data miyawaki
    # In[]:# Encoder pastikan input dan output sama dengan dimenci vector begitu juga
    inputs = Input(shape=(INPUT_OUTPUT,))
    h_encode = Dense(256, activation='relu')(inputs)
    h_encode = Dense(128, activation='relu')(h_encode)
    h_encode = Dense(64, activation='relu')(h_encode)
    h_encode = Dense(32, activation='relu')(h_encode)
    
    # In[]:# Coded
    encoded = Dense(TARGET_DIM, activation='relu')(h_encode)
    
    # In[]:# Decoder
    h_decode = Dense(32, activation='relu')(encoded)
    h_decode = Dense(64, activation='relu')(h_decode)
    h_decode = Dense(128, activation='relu')(h_decode)
    h_decode = Dense(256, activation='relu')(h_decode)
    outputs = Dense(INPUT_OUTPUT, activation='sigmoid')(h_decode)
    
    # In[]:# Autoencoder Model
    autoencoder = Model(inputs=inputs, outputs=outputs)
    
    # In[]:# Encoder Model
    encoder = Model(inputs=inputs, outputs=encoded)
    
    # In[]:# Optimizer / Update Rule
    adam = Adam(lr=0.001)
    
    # In[]:# Compile the model Binary Crossentropy
    autoencoder.compile(optimizer=adam, loss='binary_crossentropy')
    print(autoencoder.summary())
    
    # In[]:# Train and Save weight
    autoencoder.fit(train_x, train_x, batch_size=256, epochs=100, verbose=1, shuffle=True, validation_data=(test_x, test_x))
    autoencoder.save_weights('weights.h5')
    
    # In[]:# Encoded Data
    encoded_train = encoder.predict(train_x)
    encoded_test = encoder.predict(test_x)
    
    # In[]:# Reconstructed Data
    reconstructed = autoencoder.predict(test_x)
    return autoencoder,encoder