load('de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
s = reshape(D.label(2, 2:end),10,10);
imagesc(s); colormap(gray); axis image;