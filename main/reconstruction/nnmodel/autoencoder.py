# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 08:12:34 2021

@author: RPL 2020
"""

import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.datasets import mnist
from lib import loaddata,ae
from sklearn.model_selection import train_test_split


# In[]:# Target Dimension miyawaki start dari sini karena sudah reshape daro 10x10 menjadi 100 vector
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()
# In[]:#
input_train,input_test=train_test_split(pred, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(label, test_size=0.1, random_state=42) 

TARGET_DIM = 16
INPUT_OUTPUT = 100 #100 untuk data miyawaki
# In[]:# Encoder pastikan input dan output sama dengan dimenci vector begitu juga
inputs = Input(shape=(INPUT_OUTPUT,))
#h_encode = Dense(256, activation='relu')(inputs)
#h_encode = Dense(128, activation='relu')(h_encode)
h_encode = Dense(64, activation='relu')(inputs)
h_encode = Dense(32, activation='relu')(h_encode)

# In[]:# Coded
encoded = Dense(TARGET_DIM, activation='relu')(h_encode)

# In[]:# Decoder
h_decode = Dense(32, activation='relu')(encoded)
h_decode = Dense(64, activation='relu')(h_decode)
#h_decode = Dense(128, activation='relu')(h_decode)
#h_decode = Dense(256, activation='relu')(h_decode)
outputs = Dense(INPUT_OUTPUT, activation='sigmoid')(h_decode)

# In[]:# Autoencoder Model
autoencoder = Model(inputs=inputs, outputs=outputs)

# In[]:# Encoder Model
encoder = Model(inputs=inputs, outputs=encoded)

# In[]:# Optimizer / Update Rule
adam = Adam(learning_rate=0.001)

# In[]:# Compile the model Binary Crossentropy
autoencoder.compile(optimizer=adam, loss='binary_crossentropy')
print(autoencoder.summary())

# In[]:# Train and Save weight
autoencoder.fit(input_train, output_train, batch_size=256, epochs=100, verbose=1, shuffle=True, validation_data=(input_test, output_test))
autoencoder.save_weights('weights.h5')

# In[]:# Encoded Data
encoded_train = encoder.predict(input_train)
encoded_test = encoder.predict(input_test)

# In[]:# Reconstructed Data
reconstructed = autoencoder.predict(input_train)

# In[]:# Plot gambar
# n = 10
# plt.figure(figsize=(20, 4))

# for i in range(n):
# 	count = 0
# 	while True:
# 		if i == test_y[count]:
# 			# Original
# 			ax = plt.subplot(2, n, i + 1)
# 			plt.imshow(test_x[count].reshape(10, 10))
# 			plt.gray()
# 			ax.get_xaxis().set_visible(False)
# 			ax.get_yaxis().set_visible(False)

# 			# Reconstructed
# 			ax = plt.subplot(2, n, i + 1 + n)
# 			plt.imshow(reconstructed[count].reshape(10, 10))
# 			plt.gray()
# 			ax.get_xaxis().set_visible(False)
# 			ax.get_yaxis().set_visible(False)
# 			break;

# 		count += 1
# plt.show()