# -*- coding: utf-8 -*-
"""
Created on Sat Aug 14 08:12:34 2021

@author: RPL 2020
"""

import matplotlib.pyplot as plt
import matplotlib.cm as cm
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.optimizers import Adam
from lib import loaddata,bdtb
from sklearn.model_selection import train_test_split


# In[]: Target Dimension miyawaki start dari sini karena sudah reshape daro 10x10 menjadi 100 vector
label,pred,allscoreresults=loaddata.fromArch(0)
labelm,predm,allscoreresultsm=loaddata.Miyawaki()

# In[]: 
input_train,input_test=train_test_split(pred, test_size=0.1, random_state=42)
output_train,output_test=train_test_split(label, test_size=0.1, random_state=42) 

TARGET_DIM = 16
INPUT_OUTPUT = 100 #100 untuk data miyawaki
# In[]: Encoder pastikan input dan output sama dengan dimenci vector begitu juga
inputs = Input(shape=(INPUT_OUTPUT,))
#h_encode = Dense(256, activation='relu')(inputs)
#h_encode = Dense(128, activation='relu')(h_encode)
h_encode = Dense(64, activation='relu')(inputs)
h_encode = Dense(32, activation='relu')(h_encode)

# In[]: Coded
encoded = Dense(TARGET_DIM, activation='relu')(h_encode)

# In[]: Decoder
h_decode = Dense(32, activation='relu')(encoded)
h_decode = Dense(64, activation='relu')(h_decode)
#h_decode = Dense(128, activation='relu')(h_decode)
#h_decode = Dense(256, activation='relu')(h_decode)
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
autoencoder.save_weights('weights.h5')

# In[]: Encoded Data
encoded_train = encoder.predict(input_train)
encoded_test = encoder.predict(input_test)

# In[]: Reconstructed Data
reconstructed = autoencoder.predict(pred)

# In[]: Plot gambar

for impred in range(len(reconstructed)):
    stimulus=bdtb.rowtoimagematrix(label[impred])
    hasilrekonstruksi=bdtb.rowtoimagematrix(pred[impred])
    hasilrecovery=bdtb.rowtoimagematrix(reconstructed[impred])
    fig, axs = plt.subplots(nrows=1, ncols=3, figsize=(12,4))
    plt.sca(axs[0])
    plt.imshow(stimulus, cmap=cm.gray)
    plt.axis('off')
    plt.title('Stimulus')
    plt.sca(axs[1])
    plt.imshow(hasilrekonstruksi, cmap=cm.gray)
    plt.axis('off')
    plt.title('hasilrekonstruksi')
    plt.sca(axs[2])
    plt.imshow(hasilrecovery, cmap=cm.gray)
    plt.axis('off')
    plt.title('hasilrecovery')
    #plt.tight_layout()
    plt.suptitle('Overall Title')
    plt.show()
    