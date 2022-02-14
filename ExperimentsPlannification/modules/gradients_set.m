function [name_alignement_opt,alignement_opt] = gradients_set(name_mixture, mixture,alignments,name_alignement)
% Selection of a gradients set that pass at least once through each point
% of the mixture design and that respect user condition inputs
%
%:param cell(str) name_mixture: name of mixture, cell index being the mixture order 
%:param cell(float) mixture: coordinates of mixtures, cell index being the mixture order *eg:mixtures{2} contains the binaries coordinates* 
%:param cell(float) alignments:coordinates of the points through which the gradient pass (3x3 columns)
%:param cell(str) name_alignement: points through which the gradient pass 
%:return array(str) name_alignement_opt: name of mixture trhough whch the set of gradients pass 
%:return array(float) alignement_opt: coordinates of mixture trhough whch the set of gradients pass 


global do_not_align
global impose_alignments_name
global impose_alignments_index
global not_repeat
global repeat_only 
global repeat_at_least
global mixture_name_list 
global state
global nb_tirages_tot
global nb_tirage
global f_gradient_set 

alignement_opt=[];
name_alignement_opt=["alignments","",""];
nb_mixture=size(mixture_name_list ,1);
nb_overtime=0;
while sum(ismember(mixture_name_list ,name_alignement_opt))<nb_mixture % check that all mixtures are represented at last once in the set of gradients
    
     if nb_overtime>10 % if no set of gradients that respect user condition is found after 10 attempts, it kills the program
        fig5 = figure ;
        set( fig5 , 'position' , [ 600 , 400 , 500 , 100 ])
        uicontrol ( fig5 , 'style' , ' text' , 'position', [100 30 200 50] , 'string' , 'No solution found' );
        return
     end
    
    waitbar(0,f_gradient_set,"Compute gradient set: try number "+num2str(nb_overtime)+1) % indicate the number of tries 
    overtime=0; 
    chrono=0;
    while overtime==0 % timer to restart if needed
        alignement_opt=[];
        name_alignement_opt=["alignments","",""];
   
        
        % Fill the alignement_opt list by imposed alignments
        name_alignement_opt=[name_alignement_opt; impose_alignments_name];
        for i=1:size(impose_alignments_name,1)
            alignement_opt=[alignement_opt;alignments(impose_alignments_index(i),:)];
        end
        
        % Chose preferentially alignments passing by the "repeat at least"
        % mixture to insure the right number of repetition
        for ral=1:size(repeat_at_least,1) 
            
            tic
            while count_occur(repeat_at_least(ral,1),name_alignement_opt)<str2num(repeat_at_least(ral,2))
              
                index=randi(size(alignments,1));
                chrono=toc;
                if chrono>100
                   fig5 = figure ;
                   set( fig5 , 'position' , [ 600 , 400 , 500 , 100 ])
                   uicontrol ( fig5 , 'style' , ' text' , 'position', [100 30 200 50] , 'string' , 'Pas de solution trouvée' );
                   return
                end
                if ismember(repeat_at_least(ral,1),name_alignement(index,:))==1 && ismember(name_alignement(index,:),name_alignement_opt,'rows')==0
                    % 1) Check that the alignement(index) does not pass
                    % by a point of not_repeat list that was already
                    % selected before : check_not_repeat
                    check_nr=check_not_repeat(name_alignement,index,name_alignement_opt,not_repeat);
                    
                    % 2) Check that the alignement(index) does not pass
                    % by a point of repeat_only that was already
                    % selected n time before:  check_repeat_only
                    check_ro=check_repeat_only(name_alignement,index,name_alignement_opt,repeat_only);
                    
                    % 3) Check that the alignement(index) does not pass
                    % by two points that should not be aligned:
                    % check_do_not_align
                    check_dna=check_do_not_align(name_alignement,index,do_not_align);
                    
                    if check_nr=="ok" || check_ro=="ok" ||check_dna=="ok"
                        
                        alignement_opt=[alignement_opt;alignments(index,:)];
                        name_alignement_opt=[name_alignement_opt; name_alignement(index,:)];
                        

                    else
                        index=randi(size(alignments,1));
                    end
                    
                end
            end
        end
        
        
        chrono=0;
        % Choice of other alignments, with test of all conditions
        % We go through the mixture cell structure, from binaries to N-aries.
        % Pure elements will inevitably be selected
        for i=2:size(mixture,2)
            for j=1:size(mixture{i},1)
                already_in_al_opt=0;
                
                %Here we are looking at mixture{i}(j). If it has already been
                %selected previously in alignement_opt, then we can move to
                %another mixture. We can leave this loop and passe to another
                %(i,j) couple thank to already_in_al_opt indicator
                
                % Check that the mixture is not already in align_opt
                if ismember(name_mixture{i}(j),name_alignement_opt)==1
                    already_in_al_opt=1; % we can move to another mixture
                    index=randi(size(alignments,1));
                    
                    % Else : we are looking for an alignement that is passing by
                    % this mixture.
                else
                    tic % timer starts
                    index=randi(size(alignments,1));
                    while already_in_al_opt==0 % while mixture{i}(j) is not in alignement_opt
                        % check randomly an alignement.
                        index=randi(size(alignments,1));
                
                        % Check that the mixture{i}(j) is in the alignement
                        if ismember(name_mixture{i}(j,:),name_alignement(index,:))==1 && ismember(name_alignement(index,:),name_alignement_opt,'rows')==0
                           
                            % Check that this selected alignement is convenient
                            % considering theimposed conditions
                            
                            % 1) Check that the alignement(index) does not pass
                            % by a point of not_repeat list that was already
                            % selected before : check_not_repeat
                            check_nr=check_not_repeat(name_alignement,index,name_alignement_opt,not_repeat);
                            
                            % 2) Check that the alignement(index) does not pass
                            % by a point of repeat_only that was already
                            % selected n time before:  check_repeat_only
                            check_ro=check_repeat_only(name_alignement,index,name_alignement_opt,repeat_only);
                            
                            % 3) Check that the alignement(index) does not pass
                            % by two points that should not be aligned:
                            % check_do_not_align
                            check_dna=check_do_not_align(name_alignement,index,do_not_align);
                            
                            if check_nr=="not ok" || check_ro=="not ok" ||check_dna=="not ok"
                                index=randi(size(alignments,1));
                            else
                                alignement_opt=[alignement_opt;alignments(index,:)];
                                name_alignement_opt=[name_alignement_opt; name_alignement(index,:)]    ;                           
                                already_in_al_opt=1;
                                sum(ismember(mixture_name_list ,name_alignement_opt))
                                waitbar(nb_tirage/nb_tirages_tot + sum(ismember(mixture_name_list ,name_alignement_opt))/(nb_mixture*nb_tirages_tot),f_gradient_set,"Compute gradient set: set number "+num2str(nb_tirage)+", try number "+num2str(nb_overtime+1)); 
                                pause(0.01)
                            end
                        end
                        chrono= toc;
                          pause(0.000001)
                          if state=="kill"
                            return
                         end
                        if chrono>10 || sum(ismember(mixture_name_list ,name_alignement_opt))>=nb_mixture
                            sum(ismember(mixture_name_list ,name_alignement_opt))
                            overtime=1;

                            break;
                        end
                    end
                    
                end
                if chrono>10 || sum(ismember(mixture_name_list ,name_alignement_opt))>=nb_mixture
                    overtime=1;
                    nb_overtime=nb_overtime+1;
                    break;
                end
            end
        end
            
    end
end
end





