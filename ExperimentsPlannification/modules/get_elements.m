function [name_elements] = get_elements(elements, fig1)
% Acquire the components name entered by the user
%
%:param UIcontrol elements: edit boxes in which the user has entered the elements names
%:param figure fig1: interface window 
%:return: name_elements: name of elements 
%:rtype: list(str)

name_elements=[];
for i=1:size(elements,2)
    if isempty(get(elements(i),'String'))==0
        name_elements=[name_elements,string(get(elements(i),'String'))];
    end     
end
uiresume(fig1)
end

