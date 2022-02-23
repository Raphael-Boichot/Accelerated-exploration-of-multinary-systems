function [nb_repet] = fix_nb_repetition(repeat_list,fig, position)
% This function is a callbacks of push buttons associated to listboxes
% When the buttons are pushed, the function identifies which mixture should be repeated 
% Then it display in the interface the names of the mixtures that should be
% repeated and an edit box in which the user can enter the number of repetitions. 
%
%:param UIcontrol repeat_list: contains the mixture that should be repeated
%:param figure fig: working interface / window  
%:param list(float) position: position features of repeated list
%:return: nb_repet: edit boxes in which the user will enter the number of repetition of each mixture


index_align_to_repeat=get(repeat_list,'Value');
align_to_repeat=get(repeat_list,'string');
for i=1:size(index_align_to_repeat,2)
    uicontrol ( fig , 'style' , ' text' , 'position', position-[0 i*20 0 0] , 'string' , align_to_repeat{index_align_to_repeat(i)} );
    nb_repet(i) = uicontrol ( fig , 'style' , ' edit' , 'position', position-[-50 i*20 0 0], 'Max' , 1 , 'string' , '' );
end

end

