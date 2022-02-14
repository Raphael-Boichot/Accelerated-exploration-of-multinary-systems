function [indicator] = check_repeat_only(name_alignments,index,name_alignement_opt,repeat_only)
% Check user condition to not repeat certain mixtures in gradients set
% 
%:param array(str) name_alignments: name of points through which the gradients passes 
%:param int index: index of alignments in the list of all alignments
%:param array(str) name_alignement_opt: gradients set that are allready selected.
%:param array(str,int) repeat_only: name of mixtures that must be repeated a limited number of time and this limited number of time
%:return: indicator: "ok" if alignement respects the user condition; else return "not ok". 
%:rtype: str

if isempty(repeat_only)==0 % if user condition is not empty
    for point=1:3 % for each mixture point of the gradients
        for r=1:size(repeat_only,1)% for each user selected mixture
            % The alignement we study is name_alignments(index,:)
            % If the mixture point is already n times in the gradient set , we don't respect the user  conditions 
            if (ismember(name_alignments(index,point),repeat_only(r,1))==1 && count_occur(repeat_only(r,1),name_alignement_opt)>=str2num(repeat_only(r,2)))
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

