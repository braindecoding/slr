load('inds_conds.mat')
load('biei.mat')
load('base_conds.mat')
%[inds_conds{base_conds}] 


merged_conds = [];
 
for v = base_conds(1):1:base_conds(2)
   merged_conds = [merged_conds; inds_conds{v}];
   disp(v)
end

ind_use=ismember(crot,merged_conds);


%%%metode ke 2
merged_conds = [];
merged_conds = [merged_conds; inds_conds{base_conds(1)}; inds_conds{base_conds(2)}];
ind_use=ismember(bi:ei,merged_conds);