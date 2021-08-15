# -*- coding: utf-8 -*-


import matplotlib.pyplot as plt
import matplotlib.cm as cm
from lib import bdtb

def tigaKolomGambar(judul,label,pred,reconstructed): 
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
        plt.suptitle(judul)
        plt.show()
    
