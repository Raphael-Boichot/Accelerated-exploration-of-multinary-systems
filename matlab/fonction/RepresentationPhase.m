function []=RepresentationPhase(Filename,path)

%path='C:\Users\adrie\Desktop\EPEE\S8\IA\adrien2004\affichage des phases\';
%addpath('./modules_pp');
databaseNN=path+"output\"+Filename;

%Preparation of the tables (to adapt depending on your dataset)
predNN=readtable(databaseNN);
predNN=predNN(:,1:end); % suppress first column and keep only compositions and outputs
predNN.Zr=predNN.Zr/100; % composition in % and not in percent rate
predNN.Nb=predNN.Nb/100;
predNN.Mo=predNN.Mo/100;
predNN.Ti=predNN.Ti/100;
predNN.Cr=predNN.Cr/100;

%Define the columns that contains the predicted properties
%Phase class is predicted with NN and mechanical properties from RF.

column_EBSD=predNN.NN_PhasePredictionFromEBSDClass;
column_XRD=predNN.NN_PhasePredictionFromXRDClass;

%Prepare composition space plotting
nb_elements=5;
name_elements=["Zr","Nb","Mo","Ti","Cr"];

x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);

%Plot Amorphous domains predicted from EBSD and XRD
mask_amorph_DRX= (column_XRD==0);
mask_amorph_EBSD= (column_EBSD==0);

amorph_XRD=table2array(predNN(mask_amorph_DRX,:));
amorph_EBSD=table2array(predNN(mask_amorph_EBSD,:));

coord_amorph_XRD=amorph_XRD(:,1:5)*[x y z];
coord_amorph_EBSD=amorph_EBSD(:,1:5)*[x y z];

cell_coordinates={coord_amorph_EBSD,coord_amorph_XRD};
% EBSD in blue and XRD in grey.
%it's possible to cho
%it is possible to choose to display only one of the two. to do this, delete the one not to be displayed from cell_coordinates
cell_type_plot={"alphashape","alphashape"};

cell_size={5,5};
cell_colors={[150,150,150]./255,[3,21,151]./255};
cell_alpha={0.5,0.5};
plot_predictions_phase(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size, cell_alpha);
end