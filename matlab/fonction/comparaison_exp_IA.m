function []=comparaison_exp_IA(File1,path)
% File1='prediction_NN_compo_exp.csv';
% path='C:\Users\adrig\Desktop\EPEE\S8\IA\marek1604\';

addpath('./input')
addpath('./output')

%A modifier selon la précision en pourcentage que l'on veut
Voyante=File1;
Experience='Data_averaged.csv';

Data=readtable(path + "output\" + Voyante);
Voyante=table2array(Data);

compo=(Voyante(:,1:5)); %On prend les compositions atomiques
Young=(Voyante(:,6));
Hardness=(Voyante(:,7));
XRD=(Voyante(:,8));
EBSD=(Voyante(:,9));

Data2=readtable(path + "input\" + Experience);
Experience=table2array(Data2(:,3:end));

compo_exp=(Experience(:,1:5)); %On prend les compositions atomiques
Young_exp=(Experience(:,11));
Hardness_exp=(Experience(:,12));
XRD_exp=(Experience(:,17));
EBSD_exp=(Experience(:,15));

subplot(2,2,1)%Young
x1=Young;
y1=Young_exp;
plot(x1,y1,'+y')

subplot(2,2,2)%Hardness
x2=Hardness;
y2=Hardness_exp;
plot(x2,y2,'+g')


subplot(2,2,3)%XRD
x3=XRD;
y3=XRD_exp;
plot(x3,y3,'+r')

% Compte le nombre de points pour chaque combinaison de valeurs XRD
count_00 = sum(x3 == 0 & y3 == 0);
count_01 = sum(x3 == 0 & y3 == 1);
count_10 = sum(x3 == 1 & y3 == 0);
count_11 = sum(x3 == 1 & y3 == 1);

% Affichez les comptages à des emplacements fixes après le plot
text(0.1, 0.8, sprintf('count_00: %d', count_00), 'VerticalAlignment', 'bottom');
text(0.2, 0.6, sprintf('count_01: %d', count_01), 'VerticalAlignment', 'bottom');
text(0.3, 0.4, sprintf('count_10: %d', count_10), 'VerticalAlignment', 'bottom');
text(0.4, 0.2, sprintf('count_11: %d', count_11), 'VerticalAlignment', 'bottom');

subplot(2,2,4)%EBSD
x4=EBSD;
y4=EBSD_exp;
plot(x4,y4,'+b')

end