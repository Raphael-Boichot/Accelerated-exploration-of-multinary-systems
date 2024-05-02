function []=Representationpareto(Filename,path)

%Plot predicted properties evolution in the composition space
%Import the datasets that contain the predictions
%path='C:\Users\braunm\Desktop\marek1104\'
addpath('./modules_pp')
addpath('./input')
addpath('./output')
addpath('./matrix_connection')
addpath('./pareto')

%Plot Pareto front
databaseNN=path+"output\"+Filename;
opt=strrep(Filename, '.csv', '_opt.csv');
databaseNN_opt=path+"output\"+opt;


%Données 
predNN=readtable(databaseNN);
%Optimum de pareto 
predNN_opt=readtable(databaseNN_opt);


%On récupère les indices des colonnes de deltaH et de H dans les tables 
indice_deltaH=find(strcmp(predNN.Properties.VariableNames,'deltaH'));
indice_H=find(strcmp(predNN.Properties.VariableNames,'NN_HardnessPrediction_GPa'));

pareto_amorph=predNN(predNN.NN_PhasePredictionFromXRDClass==0,:);
pareto_cryst=predNN(predNN.NN_PhasePredictionFromXRDClass==1,:);


pareto_amorph_opt=predNN_opt((predNN_opt.NN_PhasePredictionFromXRDClass==0) & (predNN_opt.Type==0),:);
pareto_cryst_opt=predNN_opt((predNN_opt.NN_PhasePredictionFromXRDClass==1) & (predNN_opt.Type==0),:);
pareto_amorph_trans=predNN_opt((predNN_opt.NN_PhasePredictionFromXRDClass==0) & (predNN_opt.Type==1),:);
pareto_cryst_trans=predNN_opt((predNN_opt.NN_PhasePredictionFromXRDClass==1) & (predNN_opt.Type==1),:);

figure()
%% Pareto NN non moyennées amorphes
H_pareto_amorph=table2array(pareto_amorph(:,indice_H));
deltaH_pareto_amorph=table2array(pareto_amorph(:,indice_deltaH));

subplot(2,1,1)
%Valeurs
scatter(deltaH_pareto_amorph,H_pareto_amorph,5,"filled")
title('Phases amorphes')

hold on
%Valeurs transitoires
H_pareto_amorph_trans=table2array(pareto_amorph_trans(:,indice_H));
deltaH_pareto_amorph_trans=table2array(pareto_amorph_trans(:,indice_deltaH));
scatter(deltaH_pareto_amorph_trans,H_pareto_amorph_trans,5,[255,160,100]/255,"filled")

hold on
%Valeurs optimales
H_pareto_amorph_opt=table2array(pareto_amorph_opt(:,indice_H));
deltaH_pareto_amorph_opt=table2array(pareto_amorph_opt(:,indice_deltaH));
scatter(deltaH_pareto_amorph_opt,H_pareto_amorph_opt,5,[255,0,0]/255,"filled")


%% Pareto NN non moyennées crystallines
H_pareto_cryst=table2array(pareto_cryst(:,indice_H));
deltaH_pareto_cryst=table2array(pareto_cryst(:,indice_deltaH));

subplot(2,1,2)
scatter(deltaH_pareto_cryst,H_pareto_cryst,5,"filled")
title('Phases crystallines')

hold on
%Valeurs transitoires
H_pareto_cryst_trans=table2array(pareto_cryst_trans(:,indice_H));
deltaH_pareto_cryst_trans=table2array(pareto_cryst_trans(:,indice_deltaH));
scatter(deltaH_pareto_cryst_trans,H_pareto_cryst_trans,5,[255,160,100]/255,"filled")

hold on
%Valeurs optimales
H_pareto_cryst_opt=table2array(pareto_cryst_opt(:,indice_H));
deltaH_pareto_cryst_opt=table2array(pareto_cryst_opt(:,indice_deltaH));
scatter(deltaH_pareto_cryst_opt,H_pareto_cryst_opt,5,[255,0,0]/255,"filled")

end






