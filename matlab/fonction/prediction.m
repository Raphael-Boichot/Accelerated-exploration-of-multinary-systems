function []=prediction(Filename,pourcentage,File1,File2,File3,File4,path)

addpath('./best_net')
addpath('./compo_prediction')
addpath('./output')

%A modifier selon la précision en pourcentage que l'on veut

Compo=['composition_predicition', num2str(pourcentage),'.csv']

Data=readtable(path + "compo_prediction\" + Compo);
Compo=table2array(Data);
Compo=Compo.*100;

net=load(path + "best_net\"+File1);
val_predictionsYoung = predict(net.best_net,Compo);

net=load(path + "best_net\"+File2);
val_predictionsHardness = predict(net.best_net,Compo);

net=load(path + "best_net\"+File3);
val_predictionsphase = predict(net.best_net,Compo);
val_predictionsphase= round(val_predictionsphase);

net=load(path + "best_net\"+File4);
val_predictionsCI = predict(net.best_net,Compo);

a=length(val_predictionsCI);

for  i=1:1:a
    if val_predictionsCI(i)>0.2
        val_predictionsCI(i)=1;

    else
        val_predictionsCI(i)=0;
    end
end


Res(:,1:5)=Compo;
Res(:,6)=val_predictionsYoung;
Res(:,7)=val_predictionsHardness;
Res(:,8)=val_predictionsphase;
Res(:,9)=val_predictionsCI;
Res_table=array2table(Res,'VariableNames',{'Zr','Nb','Mo','Ti','Cr','NN_YoungModulusPrediction_GPa','NN_HardnessPrediction_GPa','NN_PhasePredictionFromXRDClass','NN_PhasePredictionFromEBSDClass'});

writetable(Res_table,[path 'output\' Filename])
end