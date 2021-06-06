# -*- coding: utf-8 -*-
"""
Created on Fri Jun  4 02:25:52 2021

@author: Rolly Maulana Awangga
"""

import tensorflow as tf

class Decoder(tf.keras.layers.Layer):
  def __init__(self, intermediate_dim, original_dim):
    super(Decoder, self).__init__()
    self.hidden_layer = tf.keras.layers.Dense(
      units=intermediate_dim,
      activation=tf.nn.relu,
      kernel_initializer='he_uniform'
    )
    self.output_layer = tf.keras.layers.Dense(
      units=original_dim,
      activation=tf.nn.sigmoid
    )
  
  def call(self, code):
    activation = self.hidden_layer(code)
    return self.output_layer(activation) 