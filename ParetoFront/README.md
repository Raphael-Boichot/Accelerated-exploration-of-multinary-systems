# Pareto front computation

This module allows to detect Pareto optimal composition, for two antagonistic criteria/properties. 

## Requirements:
* Install following libraries, via pip or conda
	* pandas 
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Content 

* `ParetoFront`: modules to compute Pareto front (optimal and near optimal compositions) and plot the front

* `Pareto_front_computation`: Notebook to compute Pareto front for predicted hardness and ductility characteristics, for compositions predicted as amoprhous and compositions predited as crystalline. The datasets used are available [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). 