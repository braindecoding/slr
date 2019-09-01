runIDs = D.design(:, ismember(D.design_type, 'run'));
offsetOfFigureRun = min(find(runIDs == 25));
s = reshape(D.label(offsetOfFigureRun + 10, 2:end),10,10);
imagesc(s); colormap(gray); axis image;