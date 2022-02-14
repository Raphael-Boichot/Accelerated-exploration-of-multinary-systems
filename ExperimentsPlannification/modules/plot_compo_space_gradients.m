function [fig] = plot_compo_space_gradients(nb_elements,mixture, name_mixture,name_elements, gradients, gradients_color )
% Plot the composition space with all the simplexe centroid points and linear gradients
%
%:param int nb_elements: number of components
%:param cell(float) mixture: mixture points coordinates
%:param cell(str) name_mixture: mixture names
%:param list(str) name_elements:name of the components 
%:param array(str) gradients : coordinates of the gradients points
%:param str/list(float) gradients_color: color of the gradients for plot
%:return: fig: plot the compositions space dans gradients


% To plot gradients you need an array where each lines are the coordinates
% of the gradient [x_begin, y_begin, z_begin, x_end, y_end, z_end]
x=mixture{1,1}(:,1);
y=mixture{1,1}(:,2);
z=mixture{1,1}(:,3);
fig=figure;

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

if isempty(gradients)==0
    for i=1:size(gradients,1)
    plot3([gradients(i,1),gradients(i,7)],[gradients(i,2),gradients(i,8)],[gradients(i,3),gradients(i,9)],gradients_color);
    end
end

hold off
end

