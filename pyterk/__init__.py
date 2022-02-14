"""
**PyTerK** - A Python Iterated K-fold cross validation with shuffling  

By E Garel / JL Parouty - SIMaP 2021

This package allows you to perform a **statistical evaluation** of different learning strategies (Keras/sklearn) by varying different (hyper)parameters.

## Description :

It is possible to combine the following (hyper)parameters :

* datasets
* models (with their characteristics...)
* batch size
* epochs
* iterations
* k fold
* seed (to control pseudo random generator)

It is possible, for example, to combine 3 datasets, with 3 models and to perform for each combination, 5 iterations of a cross validation of KFold type, with k=10.  
In this case, the total number of models to test would be 3x3x5x10=450 training sessions...  
So, be careful, the number of model.fit can quickly be very important !

The tasks will be run in **parallel** on the different CPUs/cores available.

## Documentation and examples :

Here is a basinc example, detailled in a notebook :

```
import pyterk.config       as config
import pyterk.reporter     as reporter
import pyterk.task_manager as task_manager

settings = config.load('settings_example.yml')

task_manager.add_combinational_iterative_manyfold(settings, run_key= 'Example-03.1')
task_manager.run()

reporter.show_run_reports(settings)
```

This will retrieve all settings from `settings_example.yml`, prepare the different tasks and execute them.
The last call, intended to be used from a Jupyter lab notebook, displays a complete execution report.

You can find **3 full example notebooks**, with a setting file :

* settings_example.yml
* 01-Example-01.ipynb
* 02-Example-02.ipynb
* 03-Example-03.ipynb
"""

VERSION=2.14
"""pyterk version"""

# Documentation generate with pdoc
# pdoc --html --output-dir docs pyterk
