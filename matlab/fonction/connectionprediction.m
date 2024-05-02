function []=connectionprediction(pourcentage,path)
addpath('./compo_prediction')
addpath('./matrix_connection')
compo_table=table(0,0,0,0,0,'VariableNames',{'Zr','Nb','Mo','Ti','Cr'});
num_compo=1;
for zr =0:pourcentage:100
    for nb=0:pourcentage:100-zr
        for mo=0:pourcentage:100-zr-nb
            for ti=0:pourcentage:100-zr-nb-mo
                compo_table(num_compo,:)=cell2table({zr/100,nb/100,mo/100,ti/100,(100-zr-nb-mo-ti)/100});
                num_compo=num_compo+1;
            end
        end
    end
end

compo=table2array(compo_table);

k=6;
Idx=zeros(size(compo,1),k);

parfor i=1:size(compo,1)
    Idx(i,:)=knnsearch(compo,compo(i,1:5), 'K',k) ;
end


Filename_compo=['composition_predicition', num2str(pourcentage),'.csv']

writetable(compo_table,[path 'compo_prediction\' Filename_compo])

Idx_table=table(Idx(:,1),Idx(:,2),Idx(:,3),Idx(:,4),Idx(:,5),Idx(:,6));

Filename_matrix=['matrice_connection', num2str(pourcentage),'.csv']

writetable(Idx_table,[path 'matrix_connection\' Filename_matrix])

end