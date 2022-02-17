function [fig] = plot_compo_space_planes(nb_elements,mixture, name_mixture,name_elements, plane_coord, plane_color)
% Plot the composition space with all the simplexe centroid points and planar gradients
%
%:param int nb_elements: number of components
%:param cell(float) mixture: mixture points coordinates
%:param cell(str) name_mixture: mixture names
%:param list(str) name_elements:name of the components 
%:param array(str) plane_coord : coordinates of the planes points
%:param str/list(float) plane_color: color of the plane for plot
%:return: fig: plot the compositions space dans gradients


% To plot gradients you need an array where each lines are the coordinates
% of the gradient [x_begin, y_begin, z_begin, x_end, y_end, z_end]


x=mixture{1,1}(:,1);
y=mixture{1,1}(:,2);
z=mixture{1,1}(:,3);
fig=figure;
%set( fig(fignumber) , 'position' , position)

hold on
switch nb_elements
    case 3
        T = delaunay(x,y);
        trimesh(T,x,y);

    otherwise 4
        DT = delaunayn([x,y,z]);
        tetramesh(DT,[x,y,z],'FaceAlpha',0.3);
   
end
text(x,y,z,name_elements);
for i=2:nb_elements
    plot3(mixture{i}(:,1),mixture{i}(:,2),mixture{i}(:,3),'dk');
    text(mixture{i}(:,1),mixture{i}(:,2),mixture{i}(:,3),name_mixture{i});
end

if isempty(plane_coord)==0
    for i=1:size(plane_coord,1)
    fill3([plane_coord(i,1),plane_coord(i,4),plane_coord(i,7)],[plane_coord(i,2),plane_coord(i,5),plane_coord(i,8)],[plane_coord(i,3),plane_coord(i,6),plane_coord(i,9)],plane_color,'facealpha',.3);
    end
end

hold off
end


