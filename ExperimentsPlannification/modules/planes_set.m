function [name_planes_opt,planes_opt] = planes_set(name_mixture, mixture,planes,name_planes)
% Selection of a planes set that encompass at least once  each point of the mixture design and that respect user condition inputs
%
%:param cell(str) name_mixture: name of mixture, cell index being the mixture order 
%:param cell(float) mixture: coordinates of mixtures, cell index being the mixture order *eg:mixtures{2} contains the binaries coordinates* 
%:param cell(float) plane:coordinates of the points through which the planes pass (3x3 columns)
%:param cell(str) name_planes: points through which the planes pass 
%:return: array(str) name_planes_opt: name of mixture trhough whch the set of planes pass 
%:return: array(float) planes_opt: coordinates of mixture trhough whch the set of planes pass 


global not_repeat
global repeat_only 
global repeat_at_least
global impose_plane_name
global impose_plane_index
global mixture_name_list 
global state
global nb_draws_tot
global nb_draw
global f_plane_set

planes_opt=[];
name_planes_opt=["planes","","","","","",""];
nb_mixture=size(mixture_name_list ,1);
nb_overtime=0;
while sum(ismember(mixture_name_list ,name_planes_opt))<nb_mixture
    overtime=0; 
    if nb_overtime>10
       fig5 = figure ;
       set( fig5 , 'position' , [ 600 , 400 , 500 , 100 ])
       uicontrol ( fig5 , 'style' , ' text' , 'position', [100 30 200 50] , 'string' , 'No solution found' );
        return
    end
      waitbar(0,f_plane_set,"Compute plane set: try number "+num2str(nb_overtime)+1)
    while overtime==0 % timer to restart if needed
        planes_opt=[];
        name_planes_opt=["planes","","","","","",""];
   
        
        % Fill the plane_opt list by imposed planes
        name_planes_opt=[name_planes_opt; impose_plane_name];
        for i=1:size(impose_plane_name,1)
            planes_opt=[planes_opt;planes(impose_plane_index(i),:)];
        end
        
        % Chose preferentially alignements passing by the "repeat at least"
        % mixture to insure the right number of repetition
        for ral=1:size(repeat_at_least,1)
            tic
            while count_occur(repeat_at_least(ral,1),name_planes_opt)<str2num(repeat_at_least(ral,2))
                chrono=toc;
                if chrono>10
                    fig5 = figure ;
                   set( fig5 , 'position' , [ 600 , 400 , 500 , 100 ])
                   uicontrol ( fig5 , 'style' , ' text' , 'position', [100 30 200 50] , 'string' , 'Pas de solution trouv�e' );
                    return
                end
                index=randi(size(planes,1));
                if ismember(repeat_at_least(ral,1),name_planes(index,:)) && ismember(name_planes(index,:),name_planes_opt,'rows')==0
                    % 1) Check that the plane(index) does not pass
                    % by a point of not_repeat list that was already
                    % selected before : check_not_repeat
                    check_nr=check_not_repeat(name_planes,index,name_planes_opt,not_repeat);
                    
                    % 2) Check that the plane(index) does not pass
                    % by a point of repeat_only that was already
                    % selected n time before:  check_repeat_only
                    check_ro=check_repeat_only(name_planes,index,name_planes_opt,repeat_only);
                    
                    
                    if check_nr=="ok" || check_ro=="ok" 
                          planes_opt=[planes_opt;planes(index,:)];
                          name_planes_opt=[name_planes_opt; name_planes(index,:)]   ;                   
                        
                    else
                        index=randi(size(alignements,1));
                    end
                    
                end
            end
        end
        chrono=0;
        % Choice of other planes, with test of all conditions
        % We go through the mixture cell structure, from binaries to N-aries.
        % Pure elements will inevitably be selected
        for i=2:size(mixture,2)
            for j=1:size(mixture{i},1)
                already_in_pl_opt=0;
                
                %Here we are looking at mixture{i}(j). If it has already been
                %selected previously in plane_opt, then we can move to
                %another mixture. We can leave this loop and passe to another
                %(i,j) couple thank to already_in_al_opt indicator
                
                % Check that the mixture is not already in align_opt
                if ismember(name_mixture{i}(j),name_planes_opt)==1
                    already_in_pl_opt=1; % we can move to another mixture
                    index=randi(size(planes,1));
                
                  
                    % Else : we are looking for an plane that is passing by
                    % this mixture.
                else
                    tic % timer starts
                    index=randi(size(planes,1));
                    while already_in_pl_opt==0 % while mixture{i}(j) is not in plane_opt
                        % check randomly an plane.
                        index=randi(size(planes,1));
                
                        % Check that the mixture{i}(j) is in the plane
                        if ismember(name_mixture{i}(j,:),name_planes(index,:))==1&& ismember(name_planes(index,:),name_planes_opt,'rows')==0
                            
                            % Check that this selected plane is convenient
                            % considering theimposed conditions
                            
                            % 1) Check that the plane(index) does not pass
                            % by a point of not_repeat list that was already
                            % selected before : check_not_repeat
                            check_nr=check_not_repeat(name_planes,index,name_planes_opt,not_repeat);
                            
                            % 2) Check that the plane(index) does not pass
                            % by a point of repeat_only that was already
                            % selected n time before:  check_repeat_only
                            check_ro=check_repeat_only(name_planes,index,name_planes_opt,repeat_only);
                            
                            
                            if check_nr=="not ok" || check_ro=="not ok"
                                index=randi(size(planes,1));
                            else
                                planes_opt=[planes_opt;planes(index,:)];
                                name_planes_opt=[name_planes_opt; name_planes(index,:)] ;                              
                                already_in_pl_opt=1;
                                sum(ismember(mixture_name_list ,name_planes_opt));
                                waitbar(nb_draw/nb_draws_tot + sum(ismember(mixture_name_list ,name_planes_opt))/(nb_mixture*nb_draws_tot),f_plane_set,"Compute plane set: set number "+num2str(nb_draw)+", try number "+num2str(nb_overtime+1)); 
                                
                                pause(0.01)
                            end
                        end
                        chrono= toc;
                        pause(0.000001)
                        if state=="kill"
                            return
                        end
                        if chrono>10 || sum(ismember(mixture_name_list ,name_planes_opt))>=nb_mixture
                            sum(ismember(mixture_name_list ,name_planes_opt));
                            overtime=1;
                            break;
                        end
                    end
                    
                end
                if chrono>10 || sum(ismember(mixture_name_list ,name_planes_opt))>=nb_mixture
                    overtime=1;
                    nb_overtime=nb_overtime+1;
                    break;
                end
            end
        end
        
        
        
    end
end

end





