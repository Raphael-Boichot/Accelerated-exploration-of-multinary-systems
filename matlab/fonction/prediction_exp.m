function []=prediction_exp(Filename,path,File1,File2,File3,File4)

% Filename='prediction_NN_compo_exp.csv';
% path='C:\Users\adrig\Desktop\EPEE\S8\IA\marek1604\';
% File1='bestnetYoungm';
% File2='bestnetHardnessm';
% File3='bestnetXRDm';
% File4='bestnetEBSDm';

addpath('./best_net')
addpath('./compo_prediction')
addpath('./output')


Compo='compo_exp.csv';


Data=readtable(path + "compo_prediction\" + Compo);
Compo=table2array(Data);

net=load(path + "best_net\"+ File1);
val_predictionsYoung = predict(net.best_net,Compo);

net=load(path + "best_net\"+ File2);
val_predictionsHardness = predict(net.best_net,Compo);

net=load(path + "best_net\"+ File3);
val_predictionsXRD = predict(net.best_net,Compo);
val_predictionsXRD= round(val_predictionsXRD);

net=load(path + "best_net\"+ File4);
val_predictionsEBSD = predict(net.best_net,Compo);

Res(:,1:5)=Compo;
Res(:,6)=val_predictionsYoung;
Res(:,7)=val_predictionsHardness;
Res(:,8)=val_predictionsXRD;
Res(:,9)=val_predictionsEBSD;
Res_table=array2table(Res,'VariableNames',{'Zr','Nb','Mo','Ti','Cr','NN_YoungModulusPrediction_GPa','NN_HardnessPrediction_GPa','NN_PhasePredictionFromXRDClass','NN_PhasePredictionFromEBSDClass'});

writetable(Res_table,[path 'output\' Filename])
end