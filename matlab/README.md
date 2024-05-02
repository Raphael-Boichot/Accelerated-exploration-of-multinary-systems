# Main
The file main coded in matlab allows to predict value of Young modulus, Hardness, and to determine if the phase is crystalline or amorphous.

### Path

The first step is to change the path in main.m 

### Choice of the data for the train 

There are different set of data. These data are located in the section "input". 
The dataset used can be chosen my modifying the variable "Data" in main.m.
To use other datasets than those provided, columns must be named Zr_at, Nb_at, Mo_at, Ti_at, Cr_at, E_GPa, H_GPa, CI and XRD in order to work.
To plot predicted values based on compo_E_wo_outlier and compo_H_wo_outlier, trainings must be carried out for both before file before being able to plot the predictions.

### Training of the neural Network 

The number of training for each neuralnetwork can be chosen by modifying the variable "nbentrainement".
The four matrices containing the neuralnetworks' weights are saved in the folder "best_net". Their names can be modified in main.m.

### Display of the RMSE

The function RMSE_trace displays the RMSE of all training iteration for the four neuralnetworks.

### Experimental vs AI comparison

- [ ] Choose the name of the spreadsheet where the values predicted by the neural network for the experimental compositions will be saved by modifying the variable "Filename" in main.m.
- [ ] Then the function prediction_exp predicts the value.
- [ ] The function comparaison_exp_IA displays the predicted values as a function of the experimental values.

### Preparation for the values prediction 

- [ ] Choose the percentage. This is the percentage variation in compositions. For example, if the percentage is 5%, Zr values will vary by step of 5% as well as the other elements. 
- [ ] The function connectionprediction generates a matrix containing all the compositions possibilities with the percentage chosen. It also generates the connexion matrix which calculates the number of neighbours of each value, it is then use to achieve Delaunay triangulation.
- [ ] The function "prediction" determines the predicted values using the neural network weights stored in the matrices before. The predicted values are stored in a file named after "Filename".
- [ ] The function "detlaH" determines the ductility index and adds a column to the file containing the predicted values
### The different display 
- [ ] Experimental values 
- [ ] Hardness, Young modulus are plotted as a gradient of color. The size of the dots can be modified using the variable "point_size".
- [ ] Pareto front. The tolerance can be modified to consider more or less values as transition values.
- [ ] Amorphous and crystalline phases plot.



# Here is a summary of the various sections

## RMSE

In this section, all the RMSE of the differents neural network are saved. 
The goal is to display the RMSE and hope the distribution following a normal distribution. 
To display the RMSE, use the function "RMSE_trace" in the section "function".

## BEST_NET

In this section, it is save in format .mat all the parameters of one neuralnetwork. With this file, it's possible to predict the value for different composition, for example for the Hardness. 

## Compo_prediction

This section save the value of the composition to predict with the neuralnetwork.

## input 

All necessary training data are saved in this section. 

### data_averaged
This spreadsheet contains the avergae values of the 4 parameters for each composition 

### Raw_data
The difference with "data_averaged" is that there is the fifth values of the fifth mesures for each composition.

### Compo_E_wo_outlier
This spreadsheet contains only the value of the Young modulus, as Raw_data it contains the fith values for each composition but without the outlier. It's the same for "Compo_H_wo_outlier" except that is for Hardness and not for the Young modul. 

## Output 

This section contains the values predicted by the neuralnetwork



