clc
close all 
clear
warning off
%Préciser le chemin d'accès au répertoire
path='C:\Users\adrig\Desktop\EPEE\S8\IA\marek1604\';
addpath('./fonction')
%% Choix du jeu de données sur lequel entrainer le réseau de neurone

%Choisir le nom du fichier sur lequel travailler (Data_averaged ou Raw_data
%corrected)
%En choissant les compositions gardées après un test de Dixon 
% (Compo_E_wo_outlier et Compo_H_wo_outlier) il faudra réaliser
% l'entrainement sur chacun séparément avant de pouvoir réaliser
% l'affichage des modules de Young et de dureté
Data="Data_averaged.csv";

%Noms des matrices pour sauvegarder les poids des réseaux de neurones
netYoung='bestnetYoungm';
netHardness='bestnetHardnessm';
netXRD='bestnetXRDm';
netEBSD='bestnetEBSDm';

%Nombre d'entrainements à effectuer
nbentrainement=1;

%Entrainement du réseau de neurones
%Choisir le fichier de données à utiliser, la variable sur lequel entrainer
%(Hardness, Young, XRD ou EBSD), le nom de la matrice pour sauvegarder les
%poids et le nombre d'entrainement
entrainement(Data,'Hardness',netHardness,nbentrainement,path)
entrainement(Data,'Young',netYoung,nbentrainement,path)
entrainement(Data,'XRD',netXRD,nbentrainement,path)
entrainement(Data,'EBSD',netEBSD,nbentrainement,path)

%% tracé des RMSE

RMSE_trace(path,'Young','Hardness','XRD','EBSD');
%permet d'afficher les erreurs pour chaque entrainement

%% Comparaison exp vs IA
Filename='prediction_NN_compo_exp.csv';
prediction_exp(Filename,path,netYoung,netHardness,netXRD,netEBSD);
% permet de prédire les valeurs avec les composisitions expérimentales

comparaison_exp_IA(Filename,path)
% permet d'afficher les résultats simulé en fonction des résultats
% expérimentaux (qui viennent du fichier Data_averaged)

%% Choix du pourcentage

pourcentage=10;

%Génération de la matrice de connexion et de la matrice de composition
%Mettre la ligne suivante en commentaire si les matrices ont déjà été
%créées

connectionprediction(pourcentage,path)

%Prédiction des réponses
%A modifier selon le nom que l'on veut donner au fichier contenant les
%prédictions calculées
Filename='prediction_NNm10.csv';

%Pour choisir des poids de réseaux particuliers on peut les repréciser dans
%comme dans les lignes suivantes (par défaut on réalise les prédictions sur
%avec les poids qui sont calculés plus haut dans le script)

% netYoung='bestnetYoungm';
% netHardness='bestnetHardnessm';
% netXRD='bestnetXRDm';
% netEBSD='bestnetEBSDm';

prediction(Filename,pourcentage,netYoung,netHardness,netXRD,netEBSD,path)

%Calcul de l'indice de ductilité avec le modèle de Galanov 
deltaH(Filename,path)

%Calcul des zones du front de Pareto
tolerance=0.01;
OptimisationPareto(Filename,tolerance,path)

%% Représentation données expérimentales
Representationdonneesexp(Data,path)

%% Affichage des modules de dureté et de Young

point_size=100;
Representationpredictions(Filename,pourcentage,point_size,path)

%% Affichage du front de Pareto

Representationpareto(Filename,path)

%% Affichage des phases

RepresentationPhase(Filename,path)