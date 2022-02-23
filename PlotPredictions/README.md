# Plot Predictions

These Matlab modules plot Machine Learning prediction. It can scatter composition point of plot alpha shape of compositions points. User can add color or point size to plot along the predicted properties of the composition points. 

## Requirements
* Matlab2019 or later
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Content

* `Connexion_table`contains a code to define connexion table between each composition points and its neihbourgs and export it in csv
* `PredictionsRepresentation` is an example of Matlab LiveScript with title and main comment should be executed by the user. The datasets used are available [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). 
* modules contains functions select specific compositions based on their properties, to interpolate specific isovalues and to plot these values with specific color and point size (depending on their properties. )
* Documentation of the modules is given in [main documentation](../Documentation/Accelerated Exploration Of Multinary Systems modules.pdf)
 

