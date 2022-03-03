# Galanov model implementation

This module allows to compute elastic-plastic zone $`\frac{b_s}{c}`$, the constrain factor $`C`$ and ductility characteristic $`\delta_H`$ by solving equations proposed by Galanov *et al* (Galanov, Ivanov, et Kartuzov, *Improved Core Model of the Indentation for the Experimental Determination of Mechanical Properties of Elastic-Plastic Materials and Its Application*.)

## Requirements:
* Install following libraries, via pip or conda
	* pandas 
* Create environment variables:
	* path to folder that will contain the training results : DATASETS_DIR=$path/to/datasets/ 

NB: for windows, see [this help](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html)

## Content 

* `GalanovModel`: modules to compute values of Galanov Model from experimental elastic modulus and hardness, and solve system of equations.

* `Mechanical_properties_computation`: Notebook to compute mechanical properties with Galanov models from predicted elastic modulus and hardness. The datasets used are available [here](https://zenodo.org/record/6104937#.Yg4ifC9ziRs). 
