# -*- coding: utf-8 -*-
"""
Created on Fri Aug 13 13:02:30 2021

@author: RPL 2020
"""
import cv2
import random
import numpy as np
import igraph

def corrupt_image(image,p=0.15):
    corrupted = image.copy()
    rows, cols = corrupted.shape
    for r in range(rows):
        for c in range(cols):
            if random.random() <= p :
                corrupted[r][c] = 1 - corrupted[r][c] #flip pixel
    return corrupted
 
def corrupt_image_fast(image,p=0.15):
    corrupted = image.copy()
    rows, cols = corrupted.shape
    prob = np.random.rand(rows,cols)
    corrupted = np.multiply(corrupted, prob>p) + np.multiply(1-corrupted, prob<=p)
    return corrupted

def recover(noisy, K=1, lmbda=3.5):
    edge_list, weights, s, t = create_graph(noisy, K,lmbda)
    g = igraph.Graph(edge_list)
    output = g.maxflow(s, t, weights)
    recovered = np.array(output.membership[:-2]).reshape(noisy.shape)
    inverted=np.invert(recovered)
    return inverted

def create_graph(img, K=1, lmbda=3.5):
    max_num = len(img)*len(img[0])
    s,t = max_num, max_num + 1
    edge_list = []
    weights = []
    for r_idx, row in enumerate(img):
        for idx, pixel in enumerate(row):
            px_id = (r_idx*len(row)) + idx
            #add edge to cell to the left
            if px_id!= 0:
                edge_list.append((px_id -1, px_id))
                weights.append( K )
             #add edge to cell to the right
            if px_id != len(row) -1:
                edge_list.append((px_id +1, px_id))
                weights.append( K )
            #add edge to cell to the above
            if r_idx!= 0:
               edge_list.append((px_id - len(row), px_id))
               weights.append( K )
            #add edge to cell to the below
            if r_idx != len(img) -1:
               edge_list.append((px_id + len(row), px_id))
               weights.append( K )
            #add an edge to either s (source) or t (sink)
            if pixel == 1:
               edge_list.append((s,px_id))
               weights.append( lmbda )
            else:
               edge_list.append((px_id, t))
               weights.append( lmbda )
    return edge_list, weights, s, t


        