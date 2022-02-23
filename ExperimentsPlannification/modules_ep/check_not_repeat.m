function [indicator] = check_not_repeat(name_alignments,index,name_alignement_opt,not_repeat)
% Check user condition to not repeat certain mixtures in gradients set
% 
%:param array(str) name_alignments: name of points through which the gradients passes 
%:param int index: index of alignments in the list of all alignments
%:param array(str) name_alignement_opt: gradients set that are already selected.
%:param array(str) not_repeat: mixtures to no repeat in the gradients set
%:return: indicator: "ok" if alignement respects the user condition; else return "not ok". 
%:rtype: str


if isempty(not_repeat)==0 % if user condition is not empty
    for point=1:3 % for each mixture point of the gradient
        % The alignement we study is name_alignments(index,:)
        % If the mixture point is already in the gradient set and if the
        % mixture poiunt must not be repeated, we don't respect the user
        % conditions
        if (ismember(name_alignments(index,point),name_alignement_opt)==1 && ismember(name_alignments(index,point),not_repeat)==1)
            indicator="not ok";
            break
        else
            indicator="ok";
        end
    end
else
    indicator="ok";
end

