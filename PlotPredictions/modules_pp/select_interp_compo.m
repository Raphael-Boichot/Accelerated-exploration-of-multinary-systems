function [selection_coord,compo_iso_list,coord_iso_list] = select_interp_compo(database,compo_indices, output_column, isovalue, mask, connexions_table, interpolation, x,y,z)
% Select database lines thanks to a mask and return the associated coordinates. Can interpolate a property isolvalue and return the corresponding compositions.
%
% :param table database: database as a table 
% :param list(int) compo_indices: column indices that contains the compositions 
% :param str output_column: output one wants to represent for a certain value
% :param float isovalue: value of output one want to lpot in the simplexe
% :param list mask: database selection. If isovalue is interpolated from data then the mask select a range of isovalue +/- delta. Else it select directly the isovalue
% :param array connexions_table: array of indices of nearest neighbours
% :param bool interpolation: boolean to indicate if isovalue is obtained from interpolation or not
% :param float x,y,z: coordinates of vertices (pure elements)
% :return: - selection_coord : coordinates of selected compositions
           - compo_iso_list : list of composition corresponding to isovalue
           - coord_iso_list : coordinates of compositions corresponding to isovalue
% :rtype: arrays

zone_selection=database(mask,:);
selection_coord=table2array(zone_selection(:,compo_indices))*[x,y,z];
connexions_mask=table2array(connexions_table(mask,:));

if interpolation =="True"
    k=size(compo_indices,2)+1; % number of neighbours
    compo_iso_list=[];
    for i =1:size(connexions_mask,1)
        point_ref=table2array(database(connexions_mask(i,1),compo_indices));
        for j=2:k
            neigh_j=table2array(database(connexions_mask(i,j),compo_indices));
                if output_column(connexions_mask(i,1))>isovalue && output_column(connexions_mask(i,j))<isovalue || output_column(connexions_mask(i,1))<isovalue && output_column(connexions_mask(i,j))>isovalue
                    coeff=(output_column(connexions_mask(i,1))-isovalue)/(output_column(connexions_mask(i,1))-output_column(connexions_mask(i,j)));
                    vecteur_ij=neigh_j-point_ref;
                    vecteur_i_iso=coeff*vecteur_ij;
                    compo_iso=vecteur_i_iso+point_ref;
                    compo_iso_list=[compo_iso_list;compo_iso];
                end     
        end
    end
end

if interpolation == "False"
    compo_iso_list=table2array(zone_selection(:,compo_indices));
end

if isempty(compo_iso_list)==0
    X=compo_iso_list*x;
    Y=compo_iso_list*y;
    Z=compo_iso_list*z;
    coord_iso_list=[X,Y,Z];
else
    coord_iso_list=[];
    compo_iso_list=[];

end

