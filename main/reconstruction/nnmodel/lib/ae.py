# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 01:46:53 2021

@author: RPL 2020
"""

from tensorflow.keras.models import Model,Sequential
from tensorflow.keras.layers import Input, Dense, Conv2DTranspose,Conv2D, MaxPool2D, Reshape
from tensorflow.keras.optimizers import Adam,SGD

# In[]: end of import

def trainCNNDenoise10(input_train, output_train,input_test, output_test):
    # In[]: Encoder
    denoising_encoder = Sequential([
        Reshape([10, 10, 1], input_shape=[10, 10]),
        Conv2D(16, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2),
        Conv2D(32, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2),
        Conv2D(64, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2)
    ])
    #plot_model(denoising_encoder, to_file='denoising_encoder.png', show_shapes=True)
    # In[]: Decoder    
    denoising_decoder = Sequential([
        Conv2DTranspose(32, kernel_size=3, strides=2, padding="VALID", activation="selu",
                                     input_shape=[3, 3, 64]),
        Conv2DTranspose(16, kernel_size=3, strides=2, padding="SAME", activation="selu"),
        Conv2DTranspose(1, kernel_size=3, strides=2, padding="SAME", activation="sigmoid"),
        Reshape([10, 10])
    ])
    
    #plot_model(denoising_decoder, to_file='denoising_decoder.png', show_shapes=True)    
    # In[]: AutoEncoder    
    
    denoising_ae = Sequential([denoising_encoder, denoising_decoder])
    denoising_ae.compile(loss="binary_crossentropy", optimizer=SGD(lr=0.5))
    denoising_ae.fit(input_train, output_train, batch_size=256, epochs=100, verbose=1, shuffle=True,
                          validation_data=(input_test, output_test))
    denoising_ae.save_weights('trainCNNDenoise.h5')
    return denoising_ae

# In[]: 
def trainCNNDenoise(input_train, output_train,input_test, output_test):
    # In[]: Encoder
    denoising_encoder = Sequential([
        Reshape([28, 28, 1], input_shape=[28, 28]),
        Conv2D(16, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2),
        Conv2D(32, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2),
        Conv2D(64, kernel_size=3, padding="SAME", activation="selu"),
        MaxPool2D(pool_size=2)
    ])
    #plot_model(denoising_encoder, to_file='denoising_encoder.png', show_shapes=True)
    # In[]: Decoder    
    denoising_decoder = Sequential([
        Conv2DTranspose(32, kernel_size=3, strides=2, padding="VALID", activation="selu",
                                     input_shape=[3, 3, 64]),
        Conv2DTranspose(16, kernel_size=3, strides=2, padding="SAME", activation="selu"),
        Conv2DTranspose(1, kernel_size=3, strides=2, padding="SAME", activation="sigmoid"),
        Reshape([28, 28])
    ])
    
    #plot_model(denoising_decoder, to_file='denoising_decoder.png', show_shapes=True)    
    # In[]: AutoEncoder    
    
    denoising_ae = Sequential([denoising_encoder, denoising_decoder])
    denoising_ae.compile(loss="binary_crossentropy", optimizer=SGD(lr=0.5))
    denoising_ae.fit(input_train, output_train, batch_size=256, epochs=100, verbose=1, shuffle=True,
                          validation_data=(input_test, output_test))
    denoising_ae.save_weights('trainCNNDenoise.h5')
    return denoising_ae
    
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