# PyTerK : A Python Iterated K-fold cross validation with shuffling  

These modules were build to perform iterative k§fold crossvalidation trainings on Machine Learing model of type Keras Neural Network (NN), Scikit-learn Random Forest (RF) and Scikit-learn SVM, for regression and classification. Works are also parallelized. 

## Requirements:
* Install following libraries, via pip or conda
	* tensorflow - keras
	* pandas 
	* scikit-learn
* Create environment variables:
	* path to folder that contains the datasets DATASETS_DIR : $ path/to/datasets/
	* path to folder that will contain the training results : RUN_DIR : $ path/to/run/ 
NB: for windows, see [this help] (https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)


## Content

### pyterk 
 
Contains the pyhton modules, documentend in [main documentation](../Documentation/Accelerated Exploration Of Multinary Systems modules.pdf). 

### Examples: 

* `Examples_PyTerK_user` are a set of notebooks with simple illustration of PyTerK modules to understand what lies behind. 

* `Model_assessment`: ensemble of notebooks used to assess best models architecture/hyperparameters for NN, SVM and RF. They can be directly used with our datasets (see below). The "settings" yml files contain the trainings set up that are called in "run" notebooks, in which the models are trained, and in the "report" notebooks, in which the campaign results are plotted and summed up. The settings and notebooks proposed here were used on our datasets (see below)

* `Train_best_models_all_databases` are an ensemble of notebooks that allow to train the best models assessed before on different datasets. The effect of outliers in the datasets, as well as the effect the size of the dataset, on model quality can be evaluated. Proposed settings files were used on our datasets. 

* `predictions`: notebooks in which different trained Keras and Scikit§-learn models are loaded and used to predict properties from compositions of an alloy. The notebook was used with the models trained in  `Train_best_models_all_databases` with our datasets. These trained models are available (see below)

### Open-source datasets, campaigns and training results on these datasets

The experimental datasets produced for the study of multinary Nb-Ti-Zr-Cr-Mo are available as csv [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). Download the files and create the datasets folder corresponding to $DATASETS_DIR. You can use notebooks and yml of the campaigns file directly to reproduce the results. 

If you just want to visualized the results we obtained, trained models and evaluation metrics are available as tar.gz archives [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). Extract the tarballs in $RUN_DIR files and execute the "report" notebooks to visualized the results. Predicitions can also be performed with [prediction](Examples/prediction.ipynb) notebook using the trained models.

