# Accelerated exploration of multinary systems using high-throughput experiments and machine learning

Repository of codes for experiments scheduling and machine learning modeling of experimental data. 
More details are given in README of each modules and in Documentation. The dataset used is stored in a separate dedicated cloud storage fitted for big data and can be consulted and downloaded from [here](https://zenodo.org/record/6104937#.YhOpROjMLct).

## Contents 

### Experiments Planification

This Matlab GUI interface allows to prepare the experimental work. It gives a set of 1D linear gradients or 2D planar gradients for 3 to 7 element systems. It can minimize the total number of samples or the experiments price.  

__Requirements__: Matlab2019 or more 


### PyTerK 

These Python modules and notebooks perform iterative k-fold crossvalidation for Scikit-learn or Keras models, on any datasets, with parallelization of works. Settings are written in yml files, trainings are performed in "run" notebooks and results are visualized in "report" notebooks.  

__Requirements__:
* Install following libraries, via pip or conda
	* tensorflow - keras
	* pandas 
	* scikit-learn
* Create environment variables:
	* path to folder that contains the datasets DATASETS_DIR=$path/to/datasets/
	* path to folder that will contain the training results : RUN_DIR=$path/to/run/ 

### Multiple Regression

These Python modules and notebooks perform iterative k-fold crossvalidation for statsmodel multilinear regression, on any datasets. Training and report are performed in one notebook. 

__Requirements__: 
* Install following libraries, via pip or conda
	* statsmodels.formula.api
	* pandas
	* scikit-learn
* Create environment variables in bash_profile:
	* path to folder that contains the datasets: export DATASETS_DIR = $path/to/datasets/
	* path to folder that will contain the training results : export RUN_DIR= $path/to/run/
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

### Evaluations Models Tables

These notebooks are a complement to report in PyTerK. They allowed to gather evaluation metrics/scores in tables and export them as csv, while notebooks allows to visualize them. 

__Requirement__: same as PyTerK


## Galanov Model

This module allows to compute elastic-plastic zone $\frac{b_s}{c}$, the constrain factor $C$ and ductility characteristic $\delta_H$ by solving equations proposed by Galanov `et al` (Galanov, Ivanov, et Kartuzov, `Improved Core Model of the Indentation for the Experimental Determination of Mechanical Properties of Elastic-Plastic Materials and Its Application`.)

## Requirements:
* Install following libraries, via pip or conda
	* pandas 
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Pareto Front

This module allows to detect Pareto optimal composition, for two antagonistic criteria/properties. 

## Requirements:
* Install following libraries, via pip or conda
	* pandas 
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)


## Plot Predictions

These Matlab modules plot Machine Learning prediction. It can scatter composition point of plot alpha shape of compositions points. User can add color or point size to plot along the predicted properties of the composition points. 

## Requirements
* Matlab2019 or later
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)