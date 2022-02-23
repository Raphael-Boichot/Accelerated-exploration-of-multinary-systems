function [alignments,name_alignments] = compute_alignments(mixture,name_mixture, nb_type_mixture)
% For a reference mixture, the function calculates the vector coefficient between this reference mixture and all the other mixtures with same or higher order. Then it looks for  equals vector coefficients for segments with a common point to determine which two other mixture points are aligned with the reference mixture
%
%:param cell{array} mixture: coordinates of mixtures, cell index being the mixture order *eg:mixtures{2} contains the binaries coordinates* 
%:param cell{str} name_mixture: name of mixture, cell index being the mixture order 
%:param int nb_type_mixture: number of type/order of mixtures to explore 
%:return: - alignments : coordinates of the mixtures through which the gradient pass (3x3 columns)
%         - name_alignments: mixture names through which the gradient pass 
%:rtype: array(float),array(str)

global state

% Theoretical number of alignment to fill the waitbar
theoretical_number_alignments=1/2*(3^nb_type_mixture-2^(nb_type_mixture+1)+1);
f=waitbar(0,'Compute alignments');
    

alignments=[];
name_alignments=[];
for i=1:nb_type_mixture-1 % for each mixture order
    for j=1:size(mixture{i},1) 
         pause(0.0001)
         
         if state=="kill"
            return
         end
            % We chose the reference mixture : mixture{i}(j) is our reference
            % ==> the j-mixture of order i.
            % It calculates the vector coefficient for all segments
            % between the reference mixture and the following mixture and write 
            % it in list_coeff_dir.

            list_coeff_dir={};

            % We start with mixture of same order i
            % Filling with zeros the begining of list_coeff_dir is just to keep
            % up with indices as we are not calculating the vector coefficients
            % between mixture{i}(j)and mixture{i}(1 to j-1) 
            % Fill in all previous columns with zeros
             list_coeff_dir{end+1}=[zeros(j,3);vector_coeff(mixture{i}(j,:),mixture{i}(j+1:end,:))];

            % Then we continue with mixtures of higher degree : i+1 to total
            % number of mixtures

            for k=i+1:nb_type_mixture 
                    list_coeff_dir{end+1}=vector_coeff(mixture{i}(j,:),mixture{k});
            end

            % Now comparing the vectors coefficients, we find the potentially
            % aligned mixtures. index alignments return the cell and list
            % coordinates of the aligned mixtures. 
            [indice_cell,indice_list]=index_alignments(list_coeff_dir);

            % If we found alignments ie indice_cell is not empty
            if isempty(indice_cell)==0 
                for q=1:size(indice_cell,1)
                    % mixture{i}(j), the reference, is aligned with the
                    % mixtures at the corrdinates given by indice_cell and
                    % indice_list (see scheme in documentation for index)
                    alignments=[alignments; mixture{i}(j,:),mixture{indice_cell(q,2)+i-1}(indice_list(q,2),:),mixture{indice_cell(q,1)+i-1}(indice_list(q,1),:)];
                    name_alignments=[name_alignments;name_mixture{i}(j,:),name_mixture{indice_cell(q,2)+i-1}(indice_list(q,2)),name_mixture{indice_cell(q,1)+i-1}(indice_list(q,1))];    
                    waitbar(size(alignments,1)/theoretical_number_alignments,f,'Compute alignments');
                end
            end

    end
end
end



