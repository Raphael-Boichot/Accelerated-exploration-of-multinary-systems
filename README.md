# Accelerated exploration of multinary systems using high-throughput experiments and machine learning

Repository of codes for experiments scheduling and machine learning modeling of experimental data. 
More details are given in README of each modules and in Documentation. 

## Contents 

### Experiments Planification

This Matlab GUI interface allow to prepare the experimental work. It gives a set of 1D linear gradients or 2D planar gradients for 3 to 7 element systems. It can optimize the number of samples or the experiments price.  

Requirement: Matlab2019 or more 


### PyTerK 

These Python modules and notebooks perform iterative k-fold crossvalidation for scikit-learn or keras models, on any datasets. Works are parallelized. Settings are written in yml files, trainings are performed in "run" notebooks and results are visualized in "report" notebooks.  

Requirements:
* Install following libraries, via pip or conda
	* tensorflow - keras
	* pandas 
	* scikit-learn
* Create environment variables:
	* path to folder that contains the datasets DATASETS_DIR : $ path/to/datasets/
	* path to folder that will contain the training results : RUN_DIR : $ path/to/run/ 

### Multiple Regression

These Python modules and notebooks perform iterative k-fold crossvalidation for statsmodel multilinear regression, on any datasets. Training and report are performed in one notebook. 

Requirements: 
* Install following libraries, via pip or conda
	* statsmodels.formula.api
	* pandas
	* scikit-learn
* Create environment variables in bash_profile:
	* path to folder that contains the datasets: export DATASETS_DIR = $path/to/datasets/
	* path to folder that will contain the training results : export RUN_DIR= $path/to/run/
NB: for windows, see [this help] (https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

### Evaluations Models Tables

These notebooks are a complement to report in PyTerK. They allowed to gather evaluation metrics/scores in tables and export them as csv, while Notebooks allows to visualize them. 

Requirement: same as PyTerK


## Examples : open-source datasets, campaigns and training results on these datasets

### PyTerK examples

The experimental datasets produced for the study of multinary Nb-Ti-Zr-Cr-Mo are available [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). 
Download the files and create the datasets folder corresponding to $DATASETS_DIR. You can use notebooks and yml of the campaigns file directly to reproduce the results. 

If you just want to visualized the results we obtained, training results are available [here](https://zenodo.org/record/6127502#.YhKccS9zgUs). Add the files in $RUN_DIR files and execute the report notebook to visualized the results. Predcitions can also be performed with [prediction](Examples/prediction.ipynb) notebook using the trained models.

### Multiple Regression examples:

Download the datasets [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs) and execute the notebooks. 




