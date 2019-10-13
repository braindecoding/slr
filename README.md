# visReconRoot
miyawaki dataset 
http://brainliner.jp/data/brainliner/Visual_Image_Reconstruction
## How to use miyawaki dataset
Open matlab command and make sure structure directory like HowToUse.pdf guide and put into Matlab folder,
after that run:
1. setpath
2. createMat (just run once to create mat file)
3. loadMat
4. generateFigures (to generate figure presenting to subject under redording)
4. runrandom
5. runshape

## Running On Matlab 2019a
solution is modifiing slr_learning in SLR1.2.1alpha line 98

change :
```
option = optimset('Gradobj','on','Hessian','on',...
       'MaxIter', WMaxIter, 'Display', WDisplay);
```
add new parameter if running in matlab >= 2018, the code change to:
```
   option = optimset('Gradobj','on','Hessian','on',...
       'MaxIter', WMaxIter, 'Display', WDisplay,'Algorithm','trust-region');
```