figuresfolder=".\main\data\s1_figures\"

if ~exist(figuresfolder, 'dir')
       mkdir(figuresfolder)
end
n=1
while n<1152
    runIDs = D.design(:, ismember(D.design_type, 'block'));
    offsetOfFigureRun = min(find(runIDs == n));
    s = reshape(D.label(offsetOfFigureRun + 10, 2:end),10,10);
    imagesc(s); colormap(gray); axis image;
    saveas(gcf,strcat(figuresfolder,int2str(n),".png"))
    n=n+1
end