.. Accelerated exploration of multinary systems documentation master file, created by
   sphinx-quickstart on Thu Feb 10 10:42:17 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Accelerated exploration of multinary systems's documentation!
========================================================================

This documentation aims at helping use the codes developped for "Accelerated exploration of multinary systems using high-throughput experiments and machine learning" project.

This project combines material Science and AI, and consists in producing experimental data using combinatorial high-throuput methods and mixture design, and then to analyse them using Machine Learning tools to extract predictive models linking compositions, structures and properties.


**Experiments Planification**

This Matlab GUI interface allow to prepare the experimental work. It gives a set of 1D linear gradients or 2D planar gradients for 3 to 7 element systems. It can optimize the number of samples or the experiments price.  

*Requirements*: Matlab2019 or more 


**PyTerK**

These Python modules and notebooks perform iterative k-fold crossvalidation for Scikit-learn or Keras models, on any datasets, with parallelization of works. Settings are written in yml files, trainings are performed in "run" notebooks and results are visualized in "report" notebooks.  

*Requirements*:
   * Install following libraries, via pip or conda
      * tensorflow - keras
      * pandas 
      * scikit-learn
   * Create environment variables:
      * path to folder that contains the datasets DATASETS_DIR : $ path/to/datasets/
      * path to folder that will contain the training results : RUN_DIR : $ path/to/run/ 


**Multiple Regression**

These Python modules and notebooks perform iterative k-fold crossvalidation for statsmodel multilinear regression, on any datasets. Training and report are performed in one notebook. 

*Requirements*: 
   * Install following libraries, via pip or conda
	   * statsmodels.formula.api
	   * pandas
	   * scikit-learn
   * Create environment variables in bash_profile:
      * path to folder that contains the datasets: export DATASETS_DIR = $path/to/datasets/
      * path to folder that will contain the training results : export RUN_DIR= $path/to/run/


.. toctree::
   :maxdepth: 2
   :caption: Contents

   ExperimentsPlannification
   PyTerK
   MultipleRegression
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
