function [list_target] = listing_targets_3cath(name_planes_opt)
% Lists the targets to use from the selected optimized set of planar
% gradients
%
%:param array(str) name_planes_opt: name of mixtures encompassed by planar gradients
%:return: list(str) list_target: list the target compositions to use to deposit these gradients


list_target=[' '];
for i=2:size(name_planes_opt)
    for j=[1,3,5]
        if ismember(name_planes_opt(i,j),list_target)==0
            list_target=[list_target;name_planes_opt(i,j)];
        end
    end
end


