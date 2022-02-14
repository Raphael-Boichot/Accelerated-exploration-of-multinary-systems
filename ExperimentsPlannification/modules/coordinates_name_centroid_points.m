function [mixture,name_mixture] = coordinates_name_centroid_points(nb_elements,name_elements)
% From the number and the name of the system elements, the function
% calculates the coordinates of the pure elements (standard uniform
% distribution in space) and of the equiolar mixtures of the Simplex
% Centroide mixture Design (all binaries, ternairies...). 
% 
% :param int nb_elements: number of components
% :name_element list(str): namer of components
% :return: mixture: cell coordinates of all equimolar mixture
% :rtype: cell
% :return: name_mixture: containing the names of the equimolar mixtures.
% :rtype: cell


% Pure elements coordinates
if nb_elements==3
    x=[-1/4;1/4;0];
    y=[-sqrt(3)/2;-sqrt(3)/2;sqrt(3)/2];
    z=[0;0;0];
end

if nb_elements==4
    x=[-1/(2*sqrt(2));1/(2*sqrt(2));0;0];
    y=[-1/(2*sqrt(2));-1/(2*sqrt(2));1/(2*sqrt(2));0];
    z=[0;0;0;1/(2*sqrt(2))];
end

if nb_elements>=5
    x = gallery('uniformdata',[nb_elements 1],0);
    y = gallery('uniformdata',[nb_elements 1],1);
    z = gallery('uniformdata',[nb_elements 1],2);
    
end


mixture={[x,y,z]};
name_mixture={transpose(name_elements)};
% Equimolar mixtures coordinates 
nb_mixture=nb_elements;
combinatorial_base=[1:nb_elements]; % combinaison of elements

for k=2:nb_elements
    combinatoire_mixture=nchoosek(combinatorial_base,k); % list of elements in the k-element mixture 
    x_mixture=[];
    y_mixture=[];
    z_mixture=[];
    name=[];
    for i=1:size(combinatoire_mixture,1)
        x_mixture=[x_mixture;1/k*sum(x(combinatoire_mixture(i,:)))]; % coordinates of k-elements mixtures
        y_mixture= [y_mixture;1/k*sum(y(combinatoire_mixture(i,:)))];
        z_mixture= [z_mixture;1/k*sum(z(combinatoire_mixture(i,:)))];
        name=[name;strjoin(name_elements(combinatoire_mixture(i,:)),'')];
    end
    
    mixture{end+1}=[x_mixture,y_mixture,z_mixture];
    nb_mixture=nb_mixture + size(x_mixture,1);
    name_mixture{end+1}=name;
    
end

end

