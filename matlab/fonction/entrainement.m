function []=entrainement(Database,Type,Outputnet,nbentrainement,path)
%Cette fonction prend en entrée un fichier, le type de module à prédire
%(Young ou Dureté), le nom de du fichier pour sauvegarder les réseaux de
%neurone, ainsi que le chemin d'accès au dossier

addpath('./input');
addpath('./best_net');

%On crée une table à partir du fichier csv
Data=readtable(path+"input\"+Database);

%On cherche les indices correspondant aux colonnes que l'on va utiliser
if any(strcmp(Data.Properties.VariableNames,'E_GPa'));
   indice_Young=find(strcmp(Data.Properties.VariableNames,'E_GPa'));
   Young=table2array(Data(:,indice_Young));
end
if any(strcmp(Data.Properties.VariableNames,'H_GPa'));
    indice_H=find(strcmp(Data.Properties.VariableNames,'H_GPa'));
    Hardness=table2array(Data(:,indice_H));
end

if any(strcmp(Data.Properties.VariableNames,'CI'));
    indice_CI=find(strcmp(Data.Properties.VariableNames,'CI'));
    CI=table2array(Data(:,indice_CI));
end

if any(strcmp(Data.Properties.VariableNames,'XRD'));
    indice_XRD=find(strcmp(Data.Properties.VariableNames,'XRD'));
    XRD=table2array(Data(:,indice_XRD));
end

indice_Zr=find(strcmp(Data.Properties.VariableNames,'Zr_at'));
indice_Nb=find(strcmp(Data.Properties.VariableNames,'Nb_at'));
indice_Mo=find(strcmp(Data.Properties.VariableNames,'Mo_at'));
indice_Ti=find(strcmp(Data.Properties.VariableNames,'Ti_at'));
indice_Cr=find(strcmp(Data.Properties.VariableNames,'Cr_at'));

%on crée une matrice contenant les compositions
Compo=table2array([Data(:,indice_Zr),Data(:,indice_Nb),Data(:,indice_Mo),Data(:,indice_Ti),Data(:,indice_Cr)]);

%On fait prendre à Training le Type que l'on a choisi
if strcmp(Type,'Hardness')
    Training=Hardness; 
elseif strcmp(Type,'Young') %Type=='Young'
    Training=Young;
elseif strcmp(Type,'XRD')
    Training=XRD;
elseif strcmp(Type,'EBSD')
    Training=CI;
end

%Nom du fichier que l'on souhaite utiliser pour enregistrer le réseau
Filename=Outputnet; 

%% creation de layers 
if strcmp(Type, 'Hardness') || strcmp(Type, 'Young')

layers= [ 
        featureInputLayer(5); % nombre de paramètres en entrée, ici 5 compositions
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(1) % nombre de sortie attendu
        regressionLayer()
        ];

elseif strcmp(Type, 'XRD')
    layers=[featureInputLayer(5); % nombre de paramètres en entrée, ici 5 compositions
        fullyConnectedLayer(50)
        reluLayer()
        fullyConnectedLayer(50)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(1) % nombre de sortie attendu
        sigmoidLayer
        regressionLayer()];

elseif strcmp(Type, 'EBSD')
 layers=[featureInputLayer(5); % nombre de paramètres en entrée, ici 5 compositions
        fullyConnectedLayer(50)
        reluLayer()
        fullyConnectedLayer(50)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(100)
        reluLayer()
        fullyConnectedLayer(1) % nombre de sortie attendu
        regressionLayer()];
end
%% Options d'entrainement

% Création d'une structure pour stocker les options
options = struct();

% Description (pas d'équivalent direct dans trainingOptions)
options.Description = 'Comparison of architecture on E';

% Nombre d'époques
options.Epochs = 200;

% Taille de lot (batch size) -> équivalent au nombre d'itérations en python
options.Batch_sizes = 8;

% Graine (seed)
options.Seed = 123;

% Sauvegarde de yytest (à gérer séparément)
options.Save_yytest = true;


rng(options.Seed); %pour garantir la répétabilité des résultats

% Configuration des options de trainNetwork en utilisant la fonction trainingOptions
options = trainingOptions('rmsprop', ...
    'MaxEpochs', options.Epochs, ...
    'MiniBatchSize', options.Batch_sizes, ...
    'Verbose', false);
    % 'Plots', 'training-progress')

% 2 fenetres s'ouvre à l'aide de training-progress : 
% - RMSE, qui represente l'évolution de la racine carré de l'erreur
%  quadratique moyenne 


%% Créer une partition de validation croisée K-fold

% Initialiser les variables pour stocker la RMSE la plus faible et le réseau de neurones correspondant
best_rmse = 10000;
best_net = [];

for i=1:1:nbentrainement
    cvp = cvpartition(size(Compo, 1), 'KFold', 5);


    % Parcourir les folds
    for fold = 1:1
        % Obtenir les index des données d'entraînement et de validation pour ce fold
        train_indices = ~cvp.test(fold); % indice échantillon entrainement (pas une mais toutes les lignes qui vont servir à l'entrainement)
        val_indices = cvp.test(fold); % indice échantillon test (pas une mais toutes les lignes qui vont servir à l'entrainement)

        % Séparer les données d'entraînement et de validation pour ce fold
        train_features = Compo(train_indices, :); % donnees d'entrée pour l'entrainement
        train_responses = Training(train_indices, :);  % donnees de sortie pour l'entrainement
        val_features = Compo(val_indices, :);  % donnees d'entrée pour le test
        val_responses = Training(val_indices, :);  % donnees de sortie pour le test

        % Entraîner le réseau de neurones sur les données d'entraînement pour ce fold
        net = trainNetwork(train_features, train_responses, layers, options);

        % Évaluer le réseau de neurones sur les données de validation pour ce fold
        val_predictions = predict(net, val_features);

        % Determination de la rmse pour les valeurs tests
        % E = rmse(F,A) returns the root-mean-square error (RMSE) between the forecast (predicted) array F and the actual (observed) array A.
        E = rmse(val_predictions,val_responses);
        stockage(i)=E;
        i=i+1;

        if E < best_rmse
            best_rmse = E;
            best_net = net;
        end
    end
end

% Sauvegarder le réseau de neurones avec la RMSE la plus faible
stockage_vector = stockage(:);
save([path 'best_net\' Filename],'best_net');
Sauvegarde=array2table(stockage_vector, 'VariableNames', {'RMSE'});
Filename_stockage=['RMSE_',Type,'.csv'];
writetable(Sauvegarde,[path 'RMSE\' Filename_stockage])
end

