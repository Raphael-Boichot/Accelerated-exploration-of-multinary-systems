function [state] = kill_program()
% Kill the programis the user pushed STOP button
%
%:return: display the message "kill" to indicate state 

    drawnow
    pause(0.1)
    state="kill";
    close all
    disp('You killed the program') 
    return
   
end

