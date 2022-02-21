# Multiple Regression model 

This module and notebooks allows to perform Multiple Regression on datasets. The method that lies behind the model training is identical to PyTerK one, with iterative k-fold cross-validation. 

## Requirements: 
* Install following libraries, via pip or conda
	* statsmodels.formula.api
	* pandas
	* scikit-learn
* Create environment variables in bash_profile:
	* path to folder that contains the datasets: export DATASETS_DIR = $path/to/datasets/
	* path to folder that will contain the training results : export RUN_DIR= $path/to/run/
NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Content

* [MultipleRegression](./MultipleRegression.py): python module that contains main function for iterative k-fold cross-validation Multiple Regression. Documentation is given in the [main domumentation](../Documentation/Accelerated Exploration Of Multinary Systems modules.pdf)

* MR_model_assessment is a notebook that test different regression model with more or less interactions on the same datasets. It allows to assess the best model structure. 

* MR_effect_outliers is notebook that allows to perform regression with the best model assessed before on different datasets. That allows to see the effect of outliers on the model quality.

* HTML version of the notebooks correspond to execution of the notebooks with our experimental datasets produced for the study of multinary Nb-Ti-Zr-Cr-Mo, available as csv files [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs) with their description. Download the files and create the datasets folder corresponding to $DATASETS_DIR. You can use notebooks and yml of the campaigns file directly to reproduce the results. Ignore tar.gz for MultipleRegression, they are only used in PyTerK.



