function[]=Representationdonneesexp(Filename_exp,path)

addpath('./modules_pp')
addpath('./input')
addpath('./output')

databaseExp=path+"input\"+Filename_exp;
Data=readtable(databaseExp);

if any(strcmp(Data.Properties.VariableNames,'E_GPa'));
   indice_Young=find(strcmp(Data.Properties.VariableNames,'E_GPa'));
   E=table2array(Data(:,indice_Young));
end
if any(strcmp(Data.Properties.VariableNames,'H_GPa'));
    indice_H=find(strcmp(Data.Properties.VariableNames,'H_GPa'));
    H=table2array(Data(:,indice_H));
end

indice_Zr=find(strcmp(Data.Properties.VariableNames,'Zr_at'));
indice_Nb=find(strcmp(Data.Properties.VariableNames,'Nb_at'));
indice_Mo=find(strcmp(Data.Properties.VariableNames,'Mo_at'));
indice_Ti=find(strcmp(Data.Properties.VariableNames,'Ti_at'));
indice_Cr=find(strcmp(Data.Properties.VariableNames,'Cr_at'));

compo_m=table2array([Data(:,indice_Zr),Data(:,indice_Nb),Data(:,indice_Mo),Data(:,indice_Ti),Data(:,indice_Cr)]./100);

nb_elements=5;
name_elements=["Zr","Nb","Mo","Ti","Cr"];

x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
F = faceNormal(TR);

coord_m=compo_m*[x y z];
mixtures={[x,y,z]};
name_mixture={transpose(name_elements)};
nb_mixtures=nb_elements;
combinatorial_basis=[1:nb_elements]; 

for k=2:nb_elements
    combinatorial_mixture=nchoosek(combinatorial_basis,k); % liste des éléments des mélanges à k élements
    x_mixture=[];
    y_mixture=[];
    z_mixture=[];
    name=[];
    for i=1:size(combinatorial_mixture,1)
        x_mixture=[x_mixture;1/k*sum(x(combinatorial_mixture(i,:)))]; % coordonnées des mélanges à k éléments
        y_mixture= [y_mixture;1/k*sum(y(combinatorial_mixture(i,:)))];
        z_mixture= [z_mixture;1/k*sum(z(combinatorial_mixture(i,:)))];
        name=[name;strjoin(name_elements(combinatorial_mixture(i,:)),'')];
    end
    
    mixtures{end+1}=[x_mixture,y_mixture,z_mixture];
    nb_mixtures=nb_mixtures + size(x_mixture,1);
    name_mixture{end+1}="  "+name;
   
    
end
coord_m=compo_m*[x y z];
color=hot;

E_scaled=(E-min(E))/(max(E)-min(E));
color_index_E=(round(E_scaled.*255)+1);
H_scaled=(H-min(H))/(max(H)-min(H));
color_index_H=(round(H_scaled.*255)+1);
% color_index_XRD=255-class_XRD.*255+1;


figure('Units', 'normalized','position', [0.2, 0.2, 0.3, 0.3])
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
sgtitle('Hardness')

for i=2:nb_elements
    plot3(mixtures{i}(:,1),mixtures{i}(:,2),mixtures{i}(:,3),'dk','MarkerFaceColor','k','MarkerSize',10)
    text(mixtures{i}(:,1),mixtures{i}(:,2),mixtures{i}(:,3),name_mixture{i})
end

for i=1:size(E,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_E(i),:),'MarkerSize',E(i)./25)
end


hold off

figure('Units', 'normalized','position', [0.5, 0.2, 0.3, 0.3])
set(gca,'DefaultTextFontName','Helvetica','DefaultTextFontSize', 16)
set(gca,'color','w')
hold on
tetramesh(DT,'FaceAlpha',0.05);
text(TR.Points(:,1),TR.Points(:,2),TR.Points(:,3),name_elements)
sgtitle('YoungModulus')
for i=2:nb_elements
    plot3(mixtures{i}(:,1),mixtures{i}(:,2),mixtures{i}(:,3),'dk','MarkerFaceColor','k','MarkerSize',10)
    text(mixtures{i}(:,1),mixtures{i}(:,2),mixtures{i}(:,3),name_mixture{i})
end
hold on

for i=1:size(H,1)
    plot3(coord_m(i,1),coord_m(i,2),coord_m(i,3),'ok-','MarkerFaceColor',color(color_index_H(i),:),'MarkerSize',H(i))
end
hold off

end