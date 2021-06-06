# -*- coding: utf-8 -*-
"""
Created on Fri Jun  4 02:23:38 2021

@author: Rolly Maulana Awangga
"""

import tensorflow as tf

class Encoder(tf.keras.layers.Layer):
  def __init__(self, intermediate_dim):
    super(Encoder, self).__init__()
    self.hidden_layer = tf.keras.layers.Dense(
      units=intermediate_dim,
      activation=tf.nn.relu,
      kernel_initializer='he_uniform'
    )
    self.output_layer = tf.keras.layers.Dense(
      units=intermediate_dim,
      activation=tf.nn.sigmoid
    )
    
  def call(self, input_features):
    activation = self.hidden_layer(input_features)
    return self.output_layer(activation)