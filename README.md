# Accelerated exploration of multinary systems using high-throughput experiments and machine learning

Repository of codes for experiments scheduling and machine learning modeling of experimental data. 
More details are given in README of each modules and in Documentation. 

## Experiments Planification

This Matlab GUI interface allow to prepare the experimental work. It gives a set of 1D linear gradients or 2D planar gradients for 3 to 7 element systems. It can optimize the number of samples or the experiments price.  

Requirement: Matlab2019 or more 


## PyTerK 

These Python modules and notebooks perform iterative k-fold crossvalidation for scikit-learn or keras models, on any datasets. Works are parallelized. Settings are written in yml files, trainings are performed in "run" notebooks and results are visualized in "report" notebooks.  

Requirements:
* Install following libraries, via pip or conda
	* tensorflow - keras
	* pandas 
	* scikit-learn
* Create environment variables:
	* path to folder that contains the datasets DATASETS_DIR : $ path/to/datasets/
	* path to folder that will contain the training results : RUN_DIR : $ path/to/run


## Multiple Regression

These Python modules and notebooks perform iterative k-fold crossvalidation for statsmodel multilinear regression, on any datasets. Training and report are performed in one notebook. 

Requirements: 
* Install following libraries, via pip or conda
	* statsmodels.formula.api
	* pandas
	* scikit-learn
* Create environment variables:
	* path to folder that contains the datasets DATASETS_DIR : $ path/to/datasets/
	* path to folder that will contain the training results : RUN_DIR : $ path/to/run







