# Evaluations of Models to Tables

These notebooks are a complement to report in PyTerK. They allowed to gather evaluation metrics/scores in tables and export them as csv, while Notebooks allows to visualize them. 

## Requirements:
* Install following libraries, via pip or conda
	* tensorflow - keras
	* pandas 
	* scikit-learn
* Create environment variables:
	* path to folder that will contain the training results : RUN_DIR : $ path/to/run/ 
NB: for windows, see [this help] (https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Content 

* `Evaluation_tables_model_assessment`: Gather in a table evaluation metrics of `PyTerK/Examples/Model_assessment` campaign used to assess best models architecture/hyperparameters for NN, SVM and RF. It can be directly used with our trained models and evaluation metrics (see below)

* `Evaluation_tables_models_all_databases`: Gather in a table evaluation metrics  of `PyyTerK/Examples/Train_best_models_all_datasets` used to train the best models assessed before on different datasets. It can be directly used with our trained models and evaluation metrics (see below)

### Open-source datasets, campaigns and training results on these datasets

These notebooks allowed to obtain the Supplementary Material Tables from trained models and evaluation metrics avalaible as tarballs [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). Extract the tarballs in $RUN_DIR files and execute the notebooks to obtain tables gathering models quality metrics.