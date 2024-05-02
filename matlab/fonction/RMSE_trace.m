function []=RMSE_trace(path,Young,Hardness,XRD,EBSD)
% Young='Young';
% Hardness='Hardness';
% XRD='XRD';
% EBSD='EBSD';

addpath('./RMSE')

RMSE_Young=['RMSE_',Young,'.csv'];
RMSE_Hardness=['RMSE_',Hardness,'.csv'];
RMSE_XRD=['RMSE_',XRD,'.csv'];
RMSE_EBSD=['RMSE_',EBSD,'.csv'];

Data_Young=readtable(path + "RMSE\" + RMSE_Young);
RMSE_Young=table2array(Data_Young);

Data_Hardness=readtable(path + "RMSE\" + RMSE_Hardness);
RMSE_Hardness=table2array(Data_Hardness);

Data_XRD=readtable(path + "RMSE\" + RMSE_XRD);
RMSE_XRD=table2array(Data_XRD);

Data_EBSD=readtable(path + "RMSE\" + RMSE_EBSD);
RMSE_EBSD=table2array(Data_EBSD);


subplot(2,2,1)
hist(RMSE_Young)

subplot(2,2,2)
hist(RMSE_Hardness,10)

subplot(2,2,3)
hist(RMSE_XRD)

subplot(2,2,4)
hist(RMSE_EBSD)

end