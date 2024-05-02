function []=Representationpredictions(Filename,pourcentage,point_size,path)
% Import des jeux de données contenant les prédictions
%path='C:\Users\braun\Desktop\marek1204\'
%Filename='prediction_NNm10';
addpath('./modules_pp')
addpath('./input')
addpath('./output')
addpath('./matrix_connection')

databaseNN=path+"output\"+Filename;

matrix=['matrice_connection', num2str(pourcentage),'.csv']
%matrix="matrice_connection10.csv";

% Type de tracé
type_plot = {'scatter'};


%%
% Préparation des tables 
predNN=readtable(databaseNN);
predNN.Zr=predNN.Zr/100; 
predNN.Nb=predNN.Nb/100;
predNN.Mo=predNN.Mo/100;
predNN.Ti=predNN.Ti/100;
predNN.Cr=predNN.Cr/100;

% Importation des tables de connexion : contient les indices des compositions voisines
connexions_table=readtable(path+"matrix_connection\"+matrix); % importation de la matrice de connexion

column_E_NN=predNN.NN_YoungModulusPrediction_GPa;
column_H_NN=predNN.NN_HardnessPrediction_GPa;


%%
% Préparer le tracé de l'espace de composition
nb_elements=5;
name_elements=["Zr","Nb","Mo","Ti","Cr"];

x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
F = faceNormal(TR);

%% Hardness non moyenné

values_we_plot= (column_H_NN);
levelsH= min(values_we_plot):(max(values_we_plot)-min(values_we_plot))/25:max(values_we_plot);
coord_iso_cellH={};
for i = 1:size(levelsH,2)
    mask_valueH= (abs(values_we_plot-levelsH(i))<1);
    [selection_coord,compo_iso,coord_iso] = select_interp_compo(predNN,[1:5], values_we_plot, levelsH(i), mask_valueH, connexions_table, "True", x,y,z);

    coord_iso_cellH{end+1}=selection_coord;
end

% Couleurs à utiliser pour le tracé
colorsH = hot(numel(coord_iso_cellH));

% Affichage
Pos=[0.2, 0.5, 0.3, 0.3];
plot_predictions(DT, TR, name_elements, coord_iso_cellH, type_plot, colorsH, {point_size}, {1}, Pos);
sgtitle('Hardness')

%% Young non moyenné
values_we_plot= (column_E_NN);
levelsE= min(values_we_plot):(max(values_we_plot)-min(values_we_plot))/25:max(values_we_plot);
coord_iso_cellE={};
for i = 1:size(levelsE,2)
    mask_valueE= (abs(values_we_plot-levelsE(i))<10);
    [selection_coord,compo_iso,coord_iso] = select_interp_compo(predNN,[1:5], values_we_plot, levelsE(i), mask_valueE, connexions_table, "True", x,y,z);

    coord_iso_cellE{end+1}=selection_coord;
end

% Couleurs à utiliser pour le tracé
colorsE = hot(numel(coord_iso_cellE));

% Affichage
Pos=[0.5, 0.5, 0.3, 0.3];
plot_predictions(DT, TR, name_elements, coord_iso_cellE, type_plot, colorsE, {point_size}, {1}, Pos);
sgtitle('Young Modulus')

end
