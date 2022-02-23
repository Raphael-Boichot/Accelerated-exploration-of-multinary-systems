function [list_target] = listing_targets(name_alignement_opt)
% Lists the targets to use from the selected optimized set of gradients
%
%:param array(str) name_alignement_opt: name of mixtures through which pass the gradients 
%:return: list(str) list_target: list the target compositions to use to deposit these gradients

list_target=[' '];
for i=2:size(name_alignement_opt)
    for j=[1,3]
        if ismember(name_alignement_opt(i,j),list_target)==0
            list_target=[list_target;name_alignement_opt(i,j)];
        end
    end
end


