
%%
path=getenv('DATASETS_DIR');
databaseNN=path+"Predictions_NN_mechanical_model.csv";
databaseRF=path+"Predictions_RF_mechanical_model.csv";
pareto_amorph=path+"Pareto_opt_amorph.csv";
pareto_cryst=path+"Pareto_opt_cryst.csv";

predNN=readtable(databaseNN);
predNN=predNN(:,2:end); % suppress first column and keep only compositions and outputs
predNN.Zr=predNN.Zr/100;
predNN.Nb=predNN.Nb/100;
predNN.Mo=predNN.Mo/100;
predNN.Ti=predNN.Ti/100;
predNN.Cr=predNN.Cr/100;

predRF=readtable(databaseRF);
predRF=predRF(:,2:end); % suppress first column and keep only compositions and outputs
predRF.Zr=predRF.Zr/100;
predRF.Nb=predRF.Nb/100;
predRF.Mo=predRF.Mo/100;
predRF.Ti=predRF.Ti/100;
predRF.Cr=predRF.Cr/100;

pareto_amorph_base=readtable(pareto_amorph);
pareto_amorph_base=pareto_amorph_base(:,3:end); % suppress first column and keep only compositions and outputs
pareto_amorph_base.Zr=pareto_amorph_base.Zr/100;
pareto_amorph_base.Nb=pareto_amorph_base.Nb/100;
pareto_amorph_base.Mo=pareto_amorph_base.Mo/100;
pareto_amorph_base.Ti=pareto_amorph_base.Ti/100;
pareto_amorph_base.Cr=pareto_amorph_base.Cr/100;

pareto_cryst_base=readtable(pareto_cryst);
pareto_cryst_base=pareto_cryst_base(:,3:end); % suppress first column and keep only compositions and outputs
pareto_cryst_base.Zr=pareto_cryst_base.Zr/100;
pareto_cryst_base.Nb=pareto_cryst_base.Nb/100;
pareto_cryst_base.Mo=pareto_cryst_base.Mo/100;
pareto_cryst_base.Ti=pareto_cryst_base.Ti/100;
pareto_cryst_base.Cr=pareto_cryst_base.Cr/100;

connexions_table=readtable('./matrice_connection.csv'); % import connexion matrix

column_EBSD=predNN.NN_PhasePredictionFromEBSDClass;
column_XRD=predNN.NN_PhasePredictionFromXRDClass;
column_H=predRF.RF_HardnessPrediction_GPa_;
column_deltaH=predRF.deltaH ;

nb_elements=5;
name_elements=["Zr","Nb","Mo","Ti","Cr"];

x = gallery('uniformdata',[nb_elements 1],0);
y = gallery('uniformdata',[nb_elements 1],1);
z = gallery('uniformdata',[nb_elements 1],2);
DT = delaunayTriangulation(x,y,z);
[T,Xb] = freeBoundary(DT);
TR = triangulation(T,Xb);
F = faceNormal(TR);

%%
phase_cryst=[];
phase_amorph=[];
phase_trans=[];
for i = 1:size(connexions_table,1)
    index_point=table2array(connexions_table(i,1));
    phase=[table2array(predNN(index_point,6)),table2array(predNN(index_point,7))];
    index_neigh=connexions_table(i,2:end);
    phases_neigh=[table2array(predNN(table2array(index_neigh),6)),table2array(predNN(table2array(index_neigh),7))];
    
    if sum(phase)>=1
        if sum(sum(phases_neigh))>=5
            phase_cryst=[phase_cryst,index_point];
        else
            phase_trans=[phase_trans,index_point];
            
        end
    end
    
    if sum(sum(phase))==0
        if sum(phases_neigh)==0
            phase_amorph=[phase_amorph,index_point];
        else 
           phase_trans=[phase_trans,index_point];
        end
    end
end
%%

phase_amorph_XRD=predRF(predNN.NN_PhasePredictionFromXRDClass==0,:);
phase_amorph_EBSD=predRF(predNN.NN_PhasePredictionFromEBSDClass==0,:);

coord_amorph_XRD=table2array(phase_amorph_XRD(:,1:5))*[x y z];
coord_amorph_EBSD=table2array(phase_amorph_EBSD(:,1:5))*[x y z];

cell_coordinates={coord_amorph_XRD,coord_amorph_EBSD}
cell_type_plot={"alphashape","alphashape"}
cell_size={20,20}
cell_colors={[0,104,222]./255,[130,130,130]./255}
    
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)
%%
coord_amorphe=table2array(predNN(predNN.NN_PhasePredictionFromXRDClass==0 & predNN.NN_PhasePredictionFromEBSDClass==0,1:5))*[x y z];
coord_cryst=table2array(predNN(predNN.NN_PhasePredictionFromXRDClass==1 | predNN.NN_PhasePredictionFromEBSDClass==1,1:5))*[x y z];


plot_predictions(DT, TR, name_elements, {coord_amorphe,coord_cryst},{'scatter','scatter'}, {'b','r'}, {5,5})

%%
voisin316251=predNN(table2array(connexions_table(316251,:)),1:5);
voisin5=predNN(table2array(connexions_table(5,:)),1:5);
coord316251=table2array(voisin316251)*[x y z]
coord5=table2array(voisin5)*[x y z]
plot_predictions(DT, TR, name_elements, {coord316251,coord5},{'scatter','scatter'}, {'b','r'}, {10,10})


%%
compo_amorph=predRF(phase_amorph,:);
compo_trans=predRF(phase_trans,:);
compo_cryst=predRF(phase_cryst,:);

coord_amorph=table2array(compo_amorph(:,1:5))*[x y z];
coord_trans=table2array(compo_trans(:,1:5))*[x y z];
coord_cryst=table2array(compo_cryst(:,1:5))*[x y z];


cell_coordinates={coord_amorph,coord_trans,coord_cryst}
cell_type_plot={"alphashape","alphashape","alphashape"}
cell_size={20,20,20}
cell_colors={[0,104,222]./255,[130,68,192]./255, [222,8,85]./255}

coord_test=[10.99	0.0	29.24	0.0	59.77]/100*[x y z];

plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)
plot_predictions(DT, TR, name_elements, cell_coordinates,{"scatter","scatter","scatter"}, cell_colors, {3,3,3})


%%

mask_amorphous= column_EBSD==0 & column_XRD==0;
mask_cryst= column_EBSD==1 | column_XRD==1;

max_value_H_cryst_domain= 21;
max_value_deltaH_cryst_domain=0.84;

max_value_H_amorphous_domain= 18;
max_value_deltaH_amorphous_domain=0.74;
%%
% mask_H1= (abs(column_H-max_value_H_amorphous_domain)<1 & column_EBSD==0 & column_XRD==0);
% mask_H2=(abs(column_H-(max_value_H_amorphous_domain-1))<1 & column_EBSD==0 & column_XRD==0);
% mask_H3=(abs(column_H-(max_value_H_amorphous_domain-2))<1 & column_EBSD==0 & column_XRD==0) ;
% 
% mask_deltaH1=(abs(column_deltaH-max_value_deltaH_amorphous_domain)<0.05  & column_EBSD==0 & column_XRD==0 );
% mask_deltaH2=(abs(column_deltaH-(max_value_deltaH_amorphous_domain-0.02))<0.05 & column_EBSD==0 & column_XRD==0);
% mask_deltaH3=(abs(column_deltaH-(max_value_deltaH_amorphous_domain-0.04))<0.05 & column_EBSD==0 & column_XRD==0);
% 
% mask_H1_cryst= (abs(column_H-max_value_H_cryst_domain)<1 & (column_EBSD==1 | column_XRD==1));
% mask_H2_cryst=(abs(column_H-(max_value_H_cryst_domain-1))<1 & (column_EBSD==1 | column_XRD==1));
% mask_H3_cryst=(abs(column_H-(max_value_H_cryst_domain-2))<1 & (column_EBSD==1 | column_XRD==1)) ;

mask_deltaH1_cryst=abs(column_deltaH-max_value_deltaH_cryst_domain)<0.1 &(column_EBSD==1 | column_XRD==1);
mask_deltaH2_cryst=abs(column_deltaH-(max_value_deltaH_cryst_domain-0.02))<0.1 & (column_EBSD==1 | column_XRD==1);
mask_deltaH3_cryst=abs(column_deltaH-(max_value_deltaH_cryst_domain-0.04))<0.1 & (column_EBSD==1 | column_XRD==1);

% [selection_coord_amorph,compo_iso_list_amorph,coord_iso_list_amorph] = select_interp_compo(predNN,[1:5], column_XRD, 0, mask_amorphous, connexions_table, "False", x,y,z);
% % 
% [selection_coord_H1_amorph,compo_iso_list_H1_amorph,coord_iso_list_H1_amorph] = select_interp_compo(predRF,[1:5], column_H, max_value_H_amorphous_domain, mask_H1, connexions_table, "True", x,y,z);
% [selection_coord_H2_amorph,compo_iso_list_H2_amorph,coord_iso_list_H2_amorph] = select_interp_compo(predRF,[1:5], column_H, max_value_H_amorphous_domain-1, mask_H2, connexions_table, "True", x,y,z);
% [selection_coord_H3_amorph,compo_iso_list_H3_amorph,coord_iso_list_H3_amorph] = select_interp_compo(predRF,[1:5], column_H, max_value_H_amorphous_domain-2, mask_H3, connexions_table, "True", x,y,z);
% 
% [selection_coord_H1_cryst,compo_iso_list_H1_cryst,coord_iso_list_H1_cryst] = select_interp_compo(predRF,[1:5], column_H, max_value_H_cryst_domain, mask_H1_cryst, connexions_table, "True", x,y,z);
% [selection_coord_H2_cryst,compo_iso_list_H2_cryst,coord_iso_list_H2_cryst] = select_interp_compo(predRF,[1:5], column_H, max_value_H_cryst_domain-1, mask_H2_cryst, connexions_table, "True", x,y,z);
% [selection_coord_H3_cryst,compo_iso_list_H3_cryst,coord_iso_list_H3_cryst] = select_interp_compo(predRF,[1:5], column_H, max_value_H_cryst_domain-2, mask_H3_cryst, connexions_table, "True", x,y,z);

% [selection_coord_deltaH1_amorph,compo_iso_list_deltaH1_amorph,coord_iso_list_deltaH1_amorph] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_amorphous_domain, mask_deltaH1, connexions_table, "True", x,y,z);
% [selection_coord_deltaH2_amorph,compo_iso_list_deltaH2_amorph,coord_iso_list_deltaH2_amorph] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_amorphous_domain-0.05, mask_deltaH2, connexions_table, "True", x,y,z);
% [selection_coord_deltaH3_amorph,compo_iso_list_deltaH3_amorph,coord_iso_list_deltaH3_amorph] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_amorphous_domain-0.1, mask_deltaH3, connexions_table, "True", x,y,z);
%%
[selection_coord_deltaH1_cryst,compo_iso_list_deltaH1_cryst,coord_iso_list_deltaH1_cryst] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_cryst_domain, mask_deltaH1_cryst, connexions_table, "True", x,y,z);
[selection_coord_deltaH2_cryst,compo_iso_list_deltaH2_cryst,coord_iso_list_deltaH2_cryst] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_cryst_domain-0.05, mask_deltaH2_cryst, connexions_table, "True", x,y,z);
[selection_coord_deltaH3_cryst,compo_iso_list_deltaH3_cryst,coord_iso_list_deltaH3_cryst] = select_interp_compo(predRF,[1:5], column_deltaH, max_value_deltaH_cryst_domain-0.1, mask_deltaH3_cryst, connexions_table, "True", x,y,z);
%%

cell_coordinates={coord_amorph, coord_iso_list_H1_amorph,coord_iso_list_H2_amorph,coord_iso_list_H3_amorph}
cell_type_plot={"alphashape","scatter","scatter","scatter"};
cell_size={0, 21,21,21};
color=autumn;
cell_colors={[0,104,222]./255,color(1,:), color(floor(255/2),:), color(255,:)};
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)

%%
cell_coordinates={coord_amorph, coord_iso_list_deltaH1_amorph,coord_iso_list_deltaH2_amorph,coord_iso_list_deltaH3_amorph}
cell_type_plot={"alphashape","scatter","scatter","scatter"};
cell_size={0,21,21,21};
color=autumn;
cell_colors={[0,104,222]./255,color(1,:), color(floor(255/2),:), color(255,:)};
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)

%%

cell_coordinates={coord_cryst, coord_iso_list_H1_cryst,coord_iso_list_H2_cryst,coord_iso_list_H3_cryst}
cell_type_plot={"alphashape","scatter","scatter","scatter"};
cell_size={0, 21, 21, 21};
color=autumn;
cell_colors={[222,8,85]./255,color(1,:), color(floor(255/2),:), color(255,:)};
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)

%%
cell_coordinates={coord_cryst, coord_iso_list_deltaH1_cryst,coord_iso_list_deltaH2_cryst,coord_iso_list_deltaH3_cryst}
cell_type_plot={"alphashape","scatter","scatter","scatter"};
cell_size={0, 21, 21, 21};
color=autumn;
cell_colors={[222,8,85]./255,color(1,:), color(floor(255/2),:), color(255,:)};
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)



%%
coord_pareto_amorph=table2array(pareto_amorph_base(:,1:5))*[x y z];
coord_pareto_cryst=table2array(pareto_cryst_base(:,1:5))*[x y z];

%%
cell_coordinates={coord_amorph,coord_trans,coord_pareto_amorph}
cell_type_plot={"alphashape","alphashape","scatter"}
scaled_deltaH_pareto=(pareto_amorph_base.deltaH-min(pareto_amorph_base.deltaH))/(max(pareto_amorph_base.deltaH)-min(pareto_amorph_base.deltaH))
cell_size={30,0,15+40*scaled_deltaH_pareto}
color=jet
scaled_H_pareto=(pareto_amorph_base.RF_HardnessPrediction_GPa_-min(pareto_amorph_base.RF_HardnessPrediction_GPa_))/(max(pareto_amorph_base.RF_HardnessPrediction_GPa_)-min(pareto_amorph_base.RF_HardnessPrediction_GPa_))
color_index=(round(scaled_H_pareto.*255)+1)
cell_colors={[0,104,222]./255,[130,68,192]./255,color(color_index,:)}
    
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)

%%
cell_coordinates={coord_cryst,coord_trans,coord_pareto_cryst}
cell_type_plot={"alphashape","alphashape", "scatter"}
scaled_deltaH_pareto=(pareto_cryst_base.deltaH-min(pareto_cryst_base.deltaH))/(max(pareto_cryst_base.deltaH)-min(pareto_cryst_base.deltaH))
cell_size={30,0,15+30*scaled_deltaH_pareto}
color=jet
scaled_H_pareto=(pareto_cryst_base.RF_HardnessPrediction_GPa_-min(pareto_cryst_base.RF_HardnessPrediction_GPa_))/(max(pareto_cryst_base.RF_HardnessPrediction_GPa_)-min(pareto_cryst_base.RF_HardnessPrediction_GPa_))
color_index=(round(scaled_H_pareto.*255)+1)
cell_colors={[222,8,85]./255,[130,68,192]./255,color(color_index,:)}
    
plot_predictions(DT, TR, name_elements, cell_coordinates,cell_type_plot, cell_colors, cell_size)

