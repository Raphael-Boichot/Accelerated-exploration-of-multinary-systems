function [] = plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size, cell_alpha,Pos)
% Function that plot predicted properties of chosen compositions
%
%:param DT,TR: Delaunay Traiangulation object for composition space plot
%:param str name_elements: contains the name of the alloy elements
%:param cell(float) cell_coordinates: contains the coordinates of the compositions to plot. Different groups can be plotted,  these groups are in different cells
%:param cell(str) cell_type_plot: type of plot for the different groups of points. Can be simple scattering, convex hull or alpha shape.
%:param cell cell_colors: contains colors of the poiunts or hull.
%:param cell(float) cell_size: contains the size of the point if type is scatter. If other type, juts wright 0 in the cell
%:return: show plot.

figure('Units', 'normalized', 'Position', Pos)
set(gca,'DefaultTextFontName','Helvetica ','DefaultTextFontSize', 18)
set(gca,'color','w')
hold on
tetramesh(DT,'FaceAlpha',0);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
for i = 1:size(cell_coordinates,2)
    if cell_type_plot{1}=="scatter"
        X=cell_coordinates{i}(:,1);
        Y=cell_coordinates{i}(:,2);
        Z=cell_coordinates{i}(:,3);
       % cell_colors{i};
        s=scatter3(X,Y,Z,cell_size{1},cell_colors(i,:), 'filled');
        s.MarkerEdgeColor='k';
        alpha(s,1)
    end
  
    
    
    hold on
end
view(45,0)




end

