# -*- coding: utf-8 -*-


import matplotlib.pyplot as plt
import matplotlib.cm as cm



def tigaKolomGambar(judul,sub1,gbr1,sub2,gbr2,sub3,gbr3): 
    for i in range(len(gbr3)):
        fig, axs = plt.subplots(nrows=1, ncols=3, figsize=(12,4))
        plt.sca(axs[0])
        plt.imshow(gbr1[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub1)
        plt.sca(axs[1])
        plt.imshow(gbr2[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub2)
        plt.sca(axs[2])
        plt.imshow(gbr3[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub3)
        plt.suptitle(judul)
        plt.show()
        
        
def duaKolomGambar(judul,sub1,gbr1,sub2,gbr2,sub3,gbr3): 
    for i in range(len(gbr3)):
        fig, axs = plt.subplots(nrows=1, ncols=3, figsize=(12,4))
        plt.sca(axs[0])
        plt.imshow(gbr1[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub1)
        plt.sca(axs[1])
        plt.imshow(gbr2[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub2)
        plt.sca(axs[2])
        plt.imshow(gbr3[i], cmap=cm.gray)
        plt.axis('off')
        plt.title(sub3)
        plt.suptitle(judul)
        plt.show()
