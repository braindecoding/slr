# -*- coding: utf-8 -*-
"""
Created on Fri Jun  4 02:26:49 2021

@author: Rolly Maulana Awangga
"""

import tensorflow as tf
from encoder import Encoder
from decoder import Decoder

class Autoencoder(tf.keras.Model):
  def __init__(self, intermediate_dim, original_dim):
    super(Autoencoder, self).__init__()
    self.encoder = Encoder(intermediate_dim=intermediate_dim)
    self.decoder = Decoder(intermediate_dim=intermediate_dim, original_dim=original_dim)
  
  def call(self, input_features):
    code = self.encoder(input_features)
    reconstructed = self.decoder(code)
    return reconstructed
