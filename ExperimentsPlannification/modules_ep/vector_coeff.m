function [vector] = vector_coeff(A,B)
% Compute normed vector coefficients between two points.
%
%:param list(float) A,B: coordinates of two points
%:return: coordinates of the normed vector corresponding to (AB) line

vector=[];

for i=1:size(A,1)
    for j=1:size(B,1) 
            vector=[vector;(A(i,:)-B(j,:))/(sqrt((A(i,1)-B(j,1))^2+(A(i,2)-B(j,2))^2+(A(i,3)-B(j,3))^2))];
    end 
end

