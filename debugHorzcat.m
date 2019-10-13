load('inds_conds.mat')
load('biei.mat')
load('base_conds.mat')
%[inds_conds{base_conds}] 


merged_conds = [];
 
for v = base_conds
   merged_conds = [merged_conds; inds_conds{v}];
   disp(v)
end

ind_use=ismember(crot,merged_conds);
