
# ------------------------------------------------------------------
#                  ____        _            _
#                 |  _ \ _   _| |_ ___ _ __| | __
#                 | |_) | | | | __/ _ \ '__| |/ /
#                 |  __/| |_| | ||  __/ |  |   <
#                 |_|    \__, |\__\___|_|  |_|\_\
#                        |___/                               config
# ------------------------------------------------------------------
# Python Iterator for Kfold and co. - E Garel / JL Parouty 2021

"""
Configuration management.  

The settings files allow to specify datasets and models.

## Utilisation:
Loading a settings file :
```
settings = config.load('settings_example.yml')
```
or:
```
settings = config.load('settings_example.yml', 
                        datasets_dir_env='MY_DATASETS_DIR')
```

where MY_DATASETS_DIR is an environment variable that will override `datasets_dir`
directive in settings file.
"""


import tensorflow as tf
import numpy as np
import pandas as pd
import matplotlib

from IPython.display import display,Image,Markdown,HTML

import sys,os, importlib
import hashlib
import random
import yaml


settings = None
"""Dict of settings"""
run_dir  = None
"""run_dir, the place to put all output directories"""
datasets = None
"""datasets profiles"""
models   = None
"""models profiles"""
runs     = None
"""dict of runs section"""


def _subtitle(t):
    """Print a subtitle in markdown"""
    display(Markdown(f'<br>**{t}**'))


def _hash_data(*args):
    """Return a sha256 hash of given vars
    Args:
        *args: a list of vars, like numpy array
    Return:
        _has_data: Sha256 hash
    """
    
    h=hashlib.sha256()
    for a in args:
        h.update(a)
    return h.hexdigest()


def _pyterk_path(filename):
    """Return a full pathname in the package dir for a given filename
    Parameters:
        filename : a filename
    Return:
        full path for filename in package directory
    """
    module  = importlib.import_module(__name__)
    dirname = os.path.dirname(module.__file__)
    return f'{dirname}/{filename}'

   

def load( filename, 
          datasets_dir_env='PYTERK_DATASETS_DIR',
          run_dir_env='PYTERK_RUN_DIR',
          verbose=0):  
    '''Load a setting file and dfined datasets.  
     If given, environment variable can be use to overide `datasets_dir` directive from setting file.  
     Usefull for portability between several sites.  
     
    Args:
        filename (string): Filename of the yaml setting file 
        datasets_dir_env (string): Name of the overiding environment variable
        verbose (int): verbose mode for loaded datasets (0).
        
    Returns:
        A dict from setting file, completed by datasets and more.
    
    
    '''
    global settings, run_dir, datasets, models, runs
    
    # ---- Load settings
    #
    with open(filename,'r') as fp:
        settings = yaml.load(fp, Loader=yaml.FullLoader)

    # ---- Maybe an env var is defined for datasets dir
    #
    prefix = os.getenv(datasets_dir_env, None)
    if prefix is not None:
        settings['global']['datasets_dir'] = prefix + '/' + settings['global']['datasets_dir']

    # ---- Maybe an env var is defined for run dir
    #
    prefix = os.getenv(run_dir_env, None)
    if prefix is not None:
        settings['global']['run_dir'] = prefix + '/' + settings['global']['run_dir']

    # ---- Add 'settings_file' in global part
    #
    settings['global']['file']=filename
    
    # ---- Add keys for datasets, models and run profiles
    #
    for key,profile in settings['datasets'].items():
        profile["key"]=key

    for key,profile in settings['models'].items():
        profile["key"]=key    

    for key,profile in settings['runs'].items():
        profile["key"]=key    
        
    # ---- Welcome on board...       
    #
    _subtitle('Pyterk - A Python iterative KFold stuff...')
    print('settings     :',filename)
    
    about=settings['global']
    if verbose==0:
        for k in ['description', 'datasets_dir', 'run_dir']:
            if k in about: print(f'{k:12s} : {about[k]}')
    else:
        for k,v in about.items():
            print(f'{k:12s} : {v}')
        
    # ---- Load datasets...
    #
    _load_datasets(settings, verbose=verbose)
    
    run_dir  = settings['global']['run_dir']
    datasets = settings['datasets']
    models   = settings['models']
    runs     = settings['runs']
    
    return settings

    
def _load_datasets(settings, verbose=1, return_all=False):
    '''
    Load all datasets as specified in settings.
    references to datasets are add to settings in ['datasets'][<key>]['xy'] as (x,y) 
    params:
        settings : settings from yml settings file
        verbose : 0 is silent, 1 is verbose, 2 give details (1)
        return_all : return datasets, dataframe and sha256 hash (False)
    returns:
        [datasets_xy] : dictionary of datasets [ key:(x,y), key:(x,y), key:(x,y) ...]
        [datasets_df] : dictionary of datasets dataframe
        [datasets_h] : dictionary of datasets hash
    '''
    
    if verbose>0:
        _subtitle('Load datasets...')

    datasets_dir   = settings['global']['datasets_dir']
     
    datasets_df = {}
    datasets_xy = {}
    datasets_h  = {}
    
    for key in settings['datasets']:
        
        filename  = settings['datasets'][key]['filename']
        columns_x = settings['datasets'][key]['columns_x']
        columns_y = settings['datasets'][key]['columns_y']
        
        # ---- Read csv as a DataFrame
        #
        df = pd.read_csv(f'{datasets_dir}/{filename}',sep=',', header=0)
        
        # ---- Basic check
        #
        nb_NaN = df.isna().sum().sum()
        if nb_NaN>0:
            print(f'** WARNING : Dataset {key} have {nb_NaN} missing value(s) !')
        
        # ---- Extract columns
        #
        x = np.ascontiguousarray( df[ columns_x ] )
        y = np.ascontiguousarray( df[ columns_y ] )
        
        # ---- Hash for reproductibility
        #
        h= _hash_data(x,y)

        # ---- Add datasets ref and hash to datasets settings
        #
        settings['datasets'][key]['xy'] = (x,y)
        settings['datasets'][key]['sha256'] = h
        
        # ---- In case of return all
        #
        datasets_df[key] = df
        datasets_xy[key] = (x,y)
        datasets_h[key] = h

        # ---- Few news...
        #
        if verbose>0:
            print(f'{key:12s} : {h} (sha256)')
        
        if verbose>1:
            _subtitle('Read dataset : '+key)
            display(df.head())
            print('\nDonnées manquantes : ',df.isna().sum().sum(), '  Shape is : ', df.shape)
            print('\nx as numpy array :\n', settings['datasets'][key]['xy'][0])
            print('\ny as numpy array :\n', settings['datasets'][key]['xy'][1])
            
    if return_all:
        return dataset_xy, datasets_df, datasets_h
    
