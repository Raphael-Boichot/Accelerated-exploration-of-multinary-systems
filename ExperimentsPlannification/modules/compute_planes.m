function [plane_points,plane_coord] = compute_planes(name_alignment,alignments,nb_type_mixture)
% From the gradients, planes are defines in the composition space made by 3 gradients with common points, encompassing 7 points of the mixtrure design. This means that the plane is centered on one of the point of the mixture design
%
% *eg: Nb-NbTi-Ti, Ti-TiZr-Zr and Nb-NbZr-Zr are forming a plane in a
% compositional space center on the ternary NbTiZr wich is a point of the
% mixture design: the plane is valid*
%
%:param array(str) name_alignment: points through which the gradient go 
%:param array(float) alignments: coordinates of the points through which the gradient go (3x3 columns)
%:param int nb_type_mixture: number of type/order of mixtures to explore
%:return: plane_points: mixture names encompassed by the planes
%:return: plane_coord: coordinates of the mixtures encompassed by the planes (7x3 columns)


global mixture_list
global mixture_name_list
global state


plane_points=[]; % Mixture points in the plane
plane_coord=[]; % Coordinates of the plane summit

% Theoretical number of planes to fill the waitbar
theoretical_number_planes=1/6*(4^nb_type_mixture-3^(nb_type_mixture+1)+3*2^nb_type_mixture-1);
f_planes=waitbar(0,'Compute planes');

nb_tries=0;
for i=1:size(name_alignment,1)
    for j=i+1:size(name_alignment,1)
        if name_alignment(i,3)==name_alignment(j,1) % We look two gradients with a common point : eg Nb-NbTi-Ti and Ti-NbZr-Zr
            for k=1:size(name_alignment,1) 
                pause(0.000001)
                
                if state=="kill"
                    return
                end
                % eg : Now we check that Nb-NbZr-Zr or Zr-NbZr-Nb exists
                if ismember(name_alignment(j,3),name_alignment(k,:))==1 && ismember(name_alignment(i,1),name_alignment(k,:))==1
                    % We now may have three gradients with common points.
                    % We must check that the center of this triangle 
                    % is a point of the mixture design
                    % Calculate the coordinates of the center of the plane
                    % ie intersection of the medians and check that it is in mixture list
                   % disp([name_alignement(i,1:3),name_alignement(j,2:3),name_alignement(k,2)]);
                    coord_begin=[alignments(i,1:3); alignments(i,7:9);alignments(j,7:9)];
                    coord_end=[alignments(j,4:6); alignments(k,4:6);alignments(i,4:6)];
                    grad_centre=lineIntersect3D(coord_begin,coord_end);
                    for l=1:size(mixture_list,1)
                        if abs(grad_centre-mixture_list(l,:))<10^(-10)*ones(1,3)
                            % If it is we save all of the 7 points names by
                            % which the plane passes and the coordinates of the
                            % triangle summits
                            plane_points=[plane_points;name_alignment(i,:),name_alignment(j,2:3),name_alignment(k,2),mixture_name_list(l)];
                            plane_coord=[plane_coord;alignments(i,1:3),alignments(i,7:9),alignments(j,7:9)];
                            waitbar(size(plane_coord,1)/theoretical_number_planes,f_planes,'Compute planes');
                        end
                    end
                 end
            end 
        end
    end
end

end

