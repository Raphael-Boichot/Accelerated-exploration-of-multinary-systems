function [vector] = vector_coeff(A,B)
% Compute normed vector coefficients between two points.
%
%:param list(float) A,B: coordinates of two points
%:return: coordinates of the normed vector corresponding to (AB) line

vector=[];

for i=1:size(A,1)
    for j=1:size(B,1) 
        if A(i,1)-B(j,1)~=0
            vector=[vector;(A(i,:)-B(j,:))/(A(i,1)-B(j,1))];
        elseif A(i,2)-B(j,2)~=0
            vector=[vector;(A(i,:)-B(j,:))/(A(i,2)-B(j,2))];
        elseif A(i,3)-B(j,3)~=0
            vector=[vector;(A(i,:)-B(j,:))/(A(i,3)-B(j,3))];
        else
            vector=[vector;(A(i,:)-B(j,:))];
        end
    end 
end

