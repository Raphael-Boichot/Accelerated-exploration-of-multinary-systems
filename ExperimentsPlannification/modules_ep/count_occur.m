function [count] = count_occur(element,list)
% Count the numer of occurence of an element in a list
%
%:param element: counted number or string 
%:param list list: list in which the element is counted
%:return: count: number of repetition of the element in list 
%:rtype: int


count=0;
for i=1:size(list,1)
    for j=1:size(list,2)
        if list(i,j)==element
            count=count+1;
        end
    end
end

