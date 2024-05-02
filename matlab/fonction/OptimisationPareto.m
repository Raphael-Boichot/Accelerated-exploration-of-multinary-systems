function []=OptimisationPareto(FilenameInput,tolerance,path)

%Plot predicted properties evolution in the composition space
%Import the datasets that contain the predictions

addpath('./modules_pp')
addpath('./input')
addpath('./output')
addpath('./matrix_connection')
addpath('./pareto')

if contains(FilenameInput,'.csv')
    FilenameOutput=strrep(FilenameInput, '.csv', '_opt.csv');
else
    FilenameOutput=[FilenameInput '_opt.csv']
end

databaseNN_moy=path+"output\"+FilenameInput;
predNN_moy=readtable(databaseNN_moy);
z=zeros(size(predNN_moy,1),1);
predNN_moy.Type=zeros(size(predNN_moy,1),1);
predNN_moy.Properties.VariableNames{end}='Type';


%% Phases amorphes
predNN_moy=predNN_moy(predNN_moy.NN_PhasePredictionFromXRDClass==0,:);

% Trier les données par ordre croissant de NN_HardnessPrediction_GPa
data_sorted = sortrows(predNN_moy, 'NN_HardnessPrediction_GPa','descend');

% Initialiser le tableau pour stocker les lignes à conserver
selected_rows_amorph = [];

%Type=0 : Optimal
%Type=1 : Transitoire

deltaH = data_sorted.deltaH(1);
NN_HardnessPrediction_GPa = data_sorted.NN_HardnessPrediction_GPa(1);
selected_rows_amorph = [selected_rows_amorph; data_sorted(1, :)];
prev_deltaH = deltaH;
%selected_rows_amorph.Type=0
%selected_rows_amorph.Properties.VariableNames{end}='Type'

% Parcourir les données triées
for i = 2:size(data_sorted, 1)
    % Récupérer le deltaH et la NN_HardnessPrediction_GPa de la ligne courante
    deltaH = data_sorted.deltaH(i);
    NN_HardnessPrediction_GPa = data_sorted.NN_HardnessPrediction_GPa(i);
    
    % Vérifier si le deltaH actuel est supérieur au deltaH précédent
    if deltaH > prev_deltaH
        % Ajouter cette ligne aux lignes sélectionnées
        selected_rows_amorph = [selected_rows_amorph; data_sorted(i, :)];
        selected_rows_amorph.Type(end)=0;
        % Mettre à jour le deltaH précédent
        prev_deltaH = deltaH;
    elseif (deltaH<prev_deltaH) && (abs(deltaH-prev_deltaH))<tolerance
         % Ajouter cette ligne aux lignes sélectionnées
        
        selected_rows_amorph = [selected_rows_amorph; data_sorted(i, :)];
        selected_rows_amorph.Type(end)=1;
        % Mettre à jour le deltaH précédent
    
    end
    
end



predNN_moy=readtable(databaseNN_moy);
z=zeros(size(predNN_moy,1),1);
predNN_moy.Type=zeros(size(predNN_moy,1),1);
predNN_moy.Properties.VariableNames{end}='Type';

%% Phases crystallines
predNN_moy=predNN_moy(predNN_moy.NN_PhasePredictionFromXRDClass==1,:);

% Trier les données par ordre croissant de NN_HardnessPrediction_GPa
data_sorted = sortrows(predNN_moy, 'NN_HardnessPrediction_GPa','descend');

% Initialiser le tableau pour stocker les lignes à conserver
selected_rows_cryst = [];

deltaH = data_sorted.deltaH(1);
NN_HardnessPrediction_GPa = data_sorted.NN_HardnessPrediction_GPa(1);
selected_rows_cryst = [selected_rows_cryst; data_sorted(1, :)];
prev_deltaH = deltaH;
selected_rows_cryst.Type=1;
selected_rows_cryst.Properties.VariableNames{end}='Type';

% Parcourir les données triées
for i = 1:size(data_sorted, 1)
    % Récupérer le deltaH et la NN_HardnessPrediction_GPa de la ligne courante
    deltaH = data_sorted.deltaH(i);
    NN_HardnessPrediction_GPa = data_sorted.NN_HardnessPrediction_GPa(i);
    
    % Vérifier si le deltaH actuel est supérieur au deltaH précédent
    if deltaH > prev_deltaH
        % On ajoute. cette ligne aux lignes sélectionnées
        selected_rows_cryst = [selected_rows_cryst; data_sorted(i, :)];
        selected_rows_cryst.Type(end)=0;
        % Mettre à jour le deltaH précédent
        prev_deltaH = deltaH;
    elseif (deltaH<prev_deltaH) && (abs(deltaH-prev_deltaH))<tolerance
         % Ajouter cette ligne aux lignes sélectionnées
        
        selected_rows_cryst = [selected_rows_cryst; data_sorted(i, :)];
        selected_rows_cryst.Type(end)=1;
        % Mettre à jour le deltaH précédent

    end
end

%On sauvegarde les fronts de pareto calculés pour les deux phases dans le
%même fichier
selected_rows=cat(1,selected_rows_amorph,selected_rows_cryst);

%On écrit avec les données sélectionnées dans un nouveau fichier CSV avec
%le nom FilenameOutput
writetable(selected_rows,[path 'output\' FilenameOutput])
end