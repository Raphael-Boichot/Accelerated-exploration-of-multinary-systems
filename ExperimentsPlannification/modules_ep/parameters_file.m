function [] = parameters_file()
% Write the users inputs and chosen parameters for one run of the interface in text file.


global path
global nb_cath
global name_elements
global do_not_align
global optimize_price_box
global impose_alignements_name
global not_repeat
global repeat_only 
global repeat_at_least
global subfolder

subfolder="/"+num2str(nb_cath)+"_cathodes_";
subfolder=subfolder+strjoin(name_elements,'_');

subfolder=subfolder+"_"+ replace(datestr(datetime)," ","_");
subfolder=replace(subfolder,":","-");
mkdir(path+subfolder);

parameters_file = fopen(path+subfolder+"/Parameters.txt",'w');
fprintf(parameters_file,"Elements: "+ strjoin(name_elements,',')+" \n");
fprintf(parameters_file,"Number of cathodes: "+ nb_cath+" \n");
if get(optimize_price_box,'Value')==1
    fprintf(parameters_file,"Optimize price and number of experiments: Yes  \n");
else
    fprintf(parameters_file,"Optimize price and number of experiments: No  \n");
end
fprintf(parameters_file,"Imposed alignements:  \n");
if isempty(impose_alignements_name)==1
    fprintf(parameters_file,"      None\n");
else
    for i=1:size(impose_alignements_name,1)
        fprintf(parameters_file,"      "+strjoin(impose_alignements_name(i,:),'-')+"\n");
    end
     fprintf(parameters_file,"\n");
end

fprintf(parameters_file,"Compositions that are not repeated:  \n");
if isempty(not_repeat)==1
    fprintf(parameters_file,"      None\n");
else
    fprintf(parameters_file,"      "+strjoin(not_repeat,', '));
    fprintf(parameters_file,"\n");
end

fprintf(parameters_file,"Repeat composition only X times:  \n");
if isempty(repeat_only)==1
    fprintf(parameters_file,"      None\n");
else
    for i=1:size(repeat_only,1)
        fprintf(parameters_file,"      "+strjoin(repeat_only(i,:)," : ")+"\n");
    end
     fprintf(parameters_file,"\n");
end

fprintf(parameters_file,"Repeat composition at least X times :  \n");
if isempty(repeat_at_least)==1
    fprintf(parameters_file,"      None\n");
else
    for i=1:size(repeat_at_least,1)
        fprintf(parameters_file,"      "+strjoin(repeat_at_least(i,:)," : ")+"\n");
    end
    fprintf(parameters_file,"\n");
end

if nb_cath==2
    fprintf(parameters_file,"Do not align these mixtures together:\n");
    if isempty(do_not_align)==1
        fprintf(parameters_file,"       None");
    else
        for i=1:size(do_not_align,1)
            fprintf(parameters_file,"      "+strjoin(do_not_align{i},', ')+"\n");
        end
    end
end

fclose(parameters_file);

end

