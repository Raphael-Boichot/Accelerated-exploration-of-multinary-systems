
function []=deltaH(Filename,path)
%Filename='prediction_NNm10.csv';

%Plot predicted properties evolution in the composition space
%Import the datasets that contain the predictions
addpath('./modules_pp')
addpath('./input')
addpath('./output')
addpath('./matrix_connection')
addpath('./pareto')
%path='C:\Users\braun\Desktop\marek1204\'

data=readtable(path+"output\"+ Filename );
E_s=table2array(data(:,6));
H_s=table2array(data(:,7));

nu_i=0.07;
nu_s=0.3;
E_i=1141;

Ei_star = E_i / (1 - nu_i^2);
Ks = E_s / (3 * (1 - 2 * nu_s));
alpha_s = 2 * (1 - 2 * nu_s) / (3 * (1 - nu_s));
beta_s = E_s / (6 * (1 - nu_s) * H_s);
cot_gamma_i = (pi^2 / 27)^(1/4) * 1 / tan(65/180 * pi);
theta_s = H_s / Ks;
H_s_Ei_star = H_s / Ei_star;
z = cot_gamma_i - 2 * H_s_Ei_star;

eps_p = -log(sqrt(1 + z.^2));
eps_l = -(1 + nu_s) * (1 - 2 * nu_s) * H_s ./ E_s;
delta_H = eps_p ./ (eps_p + eps_l);

%Changer le 23 en 9
data.deltaH=delta_H;
data.Properties.VariableNames{end}='deltaH';
writetable(data,[path 'output\' Filename])
end