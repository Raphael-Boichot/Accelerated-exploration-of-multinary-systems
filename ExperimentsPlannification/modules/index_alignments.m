function [indice_cell,indice_list] = index_alignments(cell_coeff_dir)
% Called in `compute_alignments`_: we get cell structure with vector coefficient between one reference mixture and all the mixtures with the same or higher orders .
% This function compares all the coefficients one by one to find equal ones
%:param cell cell_coeff_dir: contains director coefficient of vectors between one reference mixtures and all the others with same or higher order.  
%:return: cell indice_cell, indice_list: indices of the cell and list where two coefficients are equals. Allow to identify pair of equal coefficient to identify aligned points.  


% Reference is cell{i}(coeff_j) for i evolving bewteen 1 and  the cell
% structure size, and j evolving between 1 and the size of cell{i}
% Reference is compared to each coefficient cell{p}(coeff_q) for p=1 to the
% size of the cell structure, and q evolving between j+1 and the size of cell{q}
% If coefficient are less than 10^(-5) different, then they are considered
% as equals and we record the coordinates (i,j) and (p,q) of these equals
% coefficients. 
% This coordinates correspond to the coordinates of the mixtures in the
% cell structure "mixtures" 

indice_cell=[];
indice_list=[];

for i=1:size(cell_coeff_dir,2)
    for j=1:size(cell_coeff_dir{i},1)
        for p=i+1:size(cell_coeff_dir,2)
            for q=1:size(cell_coeff_dir{p},1)
                if abs(cell_coeff_dir{i}(j,:)-cell_coeff_dir{p}(q,:))<10^(-5) 
                    indice_cell=[indice_cell;i,p]; % coordinates couple of equals vector coefficients 
                    indice_list=[indice_list;j,q]; % (cell and list position)
                end
            end
        end
    end
end


