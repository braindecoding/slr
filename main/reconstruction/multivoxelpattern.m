load('de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat')
% s = reshape(D.label(2, 2:end),10,10);
% imagesc(s); colormap(gray); axis image;


figuresfolder='.\s1_figures\'

if ~exist(figuresfolder, 'dir')
       mkdir(figuresfolder)
end
n=1
while n<=1152
    %runIDs = D.design(:, ismember(D.design_type, 'block'));
    %offsetOfFigureRun = min(find(runIDs == n));
    %s = reshape(D.label(offsetOfFigureRun + 10, 2:end),10,10);
    s = reshape(D.label(n, 2:end),10,10);
    imagesc(s); colormap(gray); axis image;
    saveas(gcf,strcat(figuresfolder,int2str(n),'.png'))
    n=n+1
end