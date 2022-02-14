function [P_intersect,distances] = lineIntersect3D(PA,PB)
% Find intersection point of lines in 3D space, in the least squares sense.
%
% :param PA: Nx3-matrix containing starting point of N lines
% :param PB: Nx3-matrix containing end point of N lines
% :return: P_Intersect: Best intersection point of the N lines, in least squares sense.
% :return: distances: Distances from intersection point to the input lines
% Anders Eikenes (2022). Intersection point of lines in 3D space 
% (https://www.mathworks.com/matlabcentral/fileexchange/37192-intersection-point-of-lines-in-3d-space), MATLAB Central File Exchange. Retrieved February 10, 2022. 


Si = PB - PA; %N lines described as vectors
ni = Si ./ (sqrt(sum(Si.^2,2))*ones(1,3)); %Normalize vectors
nx = ni(:,1); ny = ni(:,2); nz = ni(:,3);
SXX = sum(nx.^2-1);
SYY = sum(ny.^2-1);
SZZ = sum(nz.^2-1);
SXY = sum(nx.*ny);
SXZ = sum(nx.*nz);
SYZ = sum(ny.*nz);
S = [SXX SXY SXZ;SXY SYY SYZ;SXZ SYZ SZZ];
CX  = sum(PA(:,1).*(nx.^2-1) + PA(:,2).*(nx.*ny)  + PA(:,3).*(nx.*nz));
CY  = sum(PA(:,1).*(nx.*ny)  + PA(:,2).*(ny.^2-1) + PA(:,3).*(ny.*nz));
CZ  = sum(PA(:,1).*(nx.*nz)  + PA(:,2).*(ny.*nz)  + PA(:,3).*(nz.^2-1));
C   = [CX;CY;CZ];
P_intersect = (S\C)';
if nargout>1
    N = size(PA,1);
    distances=zeros(N,1);
    for i=1:N %This is faster:
        ui=(P_intersect-PA(i,:))*Si(i,:)'/(Si(i,:)*Si(i,:)');
        distances(i)=norm(P_intersect-PA(i,:)-ui*Si(i,:));
    end
    %for i=1:N %http://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html:
    %    distances(i) = norm(cross(P_intersect-PA(i,:),P_intersect-PB(i,:))) / norm(Si(i,:));
    %end
end
end