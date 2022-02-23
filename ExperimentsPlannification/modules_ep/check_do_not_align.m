function [indicator] = check_do_not_align(name_alignments,index,do_not_align)
% Check user condition to not align certain mixtures in the same gradient
% 
%:param array(str) name_alignments: name of points through which the gradients passes 
%:param int index: index of alignments in the list of all alignments
%:param cell(list(str)) do_not_align: list of mixtures that must not be aligned
%:return: indicator: "ok" if alignement respects the user condition; else return "not ok". 
%:rtype: str


if isempty(do_not_align)==0 % if the list of condition is not empty
    for point=1:3 % for each mixture point of the gradient
        for d=1:size(do_not_align,1) % cell index in do_no_align
        
        % the alignement we study is name_alignments(index,:)
        % if in the alignement their are two mixtured of do_not_align{d} we
        % should reject it, as the mixtures of do_not_align{d} should not
        % be aligned.
        if sum(ismember(name_alignments(index,:),do_not_align{d}))>1 
            indicator="not ok";
            break
        else
           indicator= "ok";
        end
        end
    end
else
    indicator= "ok";
end

