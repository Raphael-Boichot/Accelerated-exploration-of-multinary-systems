# ------------------------------------------------------------------
#                  ____        _            _
#                 |  _ \ _   _| |_ ___ _ __| | __
#                 | |_) | | | | __/ _ \ '__| |/ /
#                 |  __/| |_| | ||  __/ |  |   <
#                 |_|    \__, |\__\___|_|  |_|\_\
#                        |___/                            Runner v2
# ------------------------------------------------------------------
# Python Iterator for Kfold and co. - E Garel / JL Parouty 2021

"""
This module is for internal use only - You do not have to interact with ;-).
"""


import tensorflow as tf
from tensorflow import keras

import numpy as np
import pandas as pd

import os
import json
import datetime, time
import random
import joblib

import multiprocessing as mp

from IPython.display import display,Image,Markdown,HTML
from timeit          import default_timer as timer
from collections     import OrderedDict

import pyterk
import pyterk.models
import pyterk.config

import sklearn
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error

settings   = None
trave_lock = None
verbose    = None

    
def init(s,l,v):
    global settings, trace_lock, verbose
    settings   = s
    trace_lock = l
    verbose    = v
    

def get_model_family(model):
    '''
    Should return the model family : 'tensorflow', 'keras' or 'sklearn'
    '''
    t=type(model)
    return t.__module__.split('.')[0]




def model_fit_tensorflow( model,
                          run_dir=None, 
                          x_train=None, y_train=None, x_test=None,y_test=None, 
                          epochs=None, batch_size=None, save_xxtest=False, save_yytest=False):

    bestfile  = f'{run_dir}/bestmodel.h5'
    histfile  = f'{run_dir}/history.json'
    evalfile  = f'{run_dir}/evaluation.json'
    yyfile    = f'{run_dir}/yytest.json'
    xxfile    = f'{run_dir}/xxtest.json'


    # ---- Best model callback
    #
    bestmodel_callback = keras.callbacks.ModelCheckpoint(filepath=bestfile, verbose=0, save_best_only=True)

    # ---- Fit
    #
    history = model.fit(x_train,
                        y_train,
                        epochs          = epochs,
                        batch_size      = batch_size,
                        verbose         = 0,
                        validation_data = (x_test, y_test),
                        callbacks       = [bestmodel_callback])
    
    # ---- Force bestmodel if doesn't exist
    #
    if not os.path.isfile(bestfile):
        model.save(bestfile)
        print(f'!', end='')
    
    # ---- Get best model and evaluate it
    #
    model = tf.keras.models.load_model(bestfile)
    evaluation = model.evaluate(x_test, y_test, verbose=0)
    
    # ---- Save yytest
    #
    if save_yytest:
        yytest={}
        yytest['y_test']=y_test.tolist()
        yytest['y_pred']=model.predict(x_test, verbose=0).tolist()
        with open(yyfile, 'w') as fd:
            json.dump(yytest, fd,           sort_keys=False, indent=4)

    # ---- Save xxtest
    #
    if save_xxtest:
        with open(xxfile, 'w') as fd:
            json.dump(x_test.tolist(), fd,  sort_keys=False, indent=4)

    # ---- Save history and evaluation
    #
    with open(histfile, 'w')  as fd:
        json.dump(history.history, fd, sort_keys=False, indent=4)
    with open(evalfile, 'w')  as fd:
        json.dump(evaluation, fd,      sort_keys=False, indent=4)





def model_fit_sklearn( model,
                       run_dir=None, 
                       x_train=None, y_train=None, x_test=None,y_test=None,
                       save_xxtest=False, save_yytest=False):

    
    modelfile  = f'{run_dir}/savedmodel.joblib'
    histfile   = f'{run_dir}/history.json'
    evalfile   = f'{run_dir}/evaluation.json'
    yyfile     = f'{run_dir}/yytest.json'
    xxfile     = f'{run_dir}/xxtest.json'

    # ---- Fit
    # sklearn return a warning is y have a (-1,1) shape
    #
    s=y_train.shape
    if len(s)>1 and s[1]==1:
        model.fit(x_train, y_train.ravel())
        score  = model.score(x_test, y_test.ravel())
    else:
        model.fit(x_train, y_train)
        score  = model.score(x_test, y_test)

    # ---- Save model
    #
    joblib.dump(model, modelfile) 

    # ---- Prediction
    #
    y_pred = model.predict(x_test)

    # Calculate MAE and MSE
    mae=sklearn.metrics.mean_absolute_error(y_test, y_pred)
    mse=sklearn.metrics.mean_squared_error(y_test, y_pred)
    
    # ---- Remain evaluation and (fake) history
    #
    evaluation = [ score , mse, mae  ]
    history    = { 'score': [score], 'mae':[mae], 'mse':[mse] }
    
    # ---- Save yytest
    # We want a 2d shape
    #
    if len(y_pred.shape)==1:
        y_pred=y_pred.reshape((-1,1))

    if save_yytest:
        yytest={}
        yytest['y_test']=y_test.tolist()
        yytest['y_pred']=y_pred.tolist()
        with open(yyfile, 'w') as fd:
            json.dump(yytest, fd,           sort_keys=False, indent=4)

    # ---- Save xxtest
    #
    if save_xxtest:
        with open(xxfile, 'w') as fd:
            json.dump(x_test.tolist(), fd,  sort_keys=False, indent=4)

    # ---- Save history and evaluation
    #
    with open(histfile, 'w')  as fd:
        json.dump(history, fd, sort_keys=False, indent=4)
    with open(evalfile, 'w')  as fd:
        json.dump(evaluation, fd,      sort_keys=False, indent=4)





def model_fit(run_dir=None,
              dataset_id=None, train_index=None, test_index=None, 
              model_id=None, epochs=None, batch_size=None, seed=None, description=None,
              save_xxtest=False, save_yytest=False ):
  
    start=timer()

    # ---- Seed - Note : sklearn use numpy random state
    #
    np.random.seed(seed)
    random.seed(seed)
    tf.random.set_seed(seed)

    # ---- About file
    #
    aboutfile = f'{run_dir}/about.json'
    
    # ---- Start msg
    #
    if verbose == 1 :
        trace_lock.acquire()
        print(f'o', end='')
        trace_lock.release()

    if verbose == 2:
        me=mp.current_process().name
        trace_lock.acquire()
        print(f'{me} start')
        trace_lock.release()

    # ---- Still done ?
    #      If about file exist, let us consider that the task is already done
    #
    if os.path.isfile(aboutfile):
        if verbose >= 1 :
            trace_lock.acquire()
            print(f'.', end='')
            trace_lock.release()
        return True

    # ---- Run dir / Filenames
    #
    os.makedirs(f'{run_dir}',   mode=0o750, exist_ok=True)

    # ---- Get profiles
    #
    model_profile   = settings['models'][model_id]
    dataset_profile = settings['datasets'][dataset_id]
    
    # ---- About infos
    #
    about      = OrderedDict()
    context    = OrderedDict()
    monitoring = OrderedDict()

    context['function']    = 'model_fit'
    context['version']     = pyterk.VERSION
    context['date']        = datetime.datetime.now().strftime("%A %d %B %Y, %H:%M:%S")
    context['description'] = description
    context['seed']        = seed
    
    locs=locals()
    args  = { k:locs[k] for k in ['run_dir', 'dataset_id', 'model_id', 'epochs', 'batch_size'] }
    
    about['context']  = context
    about['args']     = args
    about['settings'] = settings['global']

    # ---- Get datasets from dataset profile
    #      and extract train and test sets
    #
    (x,y)=dataset_profile['xy']
    x_train, y_train = x[train_index], y[train_index]
    x_test,  y_test  = x[test_index],  y[test_index]

    # ---- Normalize
    mean = x_train.mean()
    std  = x_train.std()
    x_train = (x_train - mean) / std
    x_test  = (x_test  - mean) / std
        
    # ---- Get model
    model  = pyterk.models.get_model(model_profile)
    family = get_model_family(model)

    if family not in ['tensorflow', 'keras', 'sklearn']:
        trace_lock.acquire()
        print(f'[Unknow family model !]', end='')
        trace_lock.release()

    if family in ['tensorflow', 'keras'] :
        model_fit_tensorflow(model, run_dir, x_train,y_train, x_test,y_test, epochs, batch_size, save_xxtest, save_yytest)

    if family=='sklearn':
        model_fit_sklearn(model, run_dir, x_train,y_train, x_test,y_test, save_xxtest, save_yytest=True)

    # ---- About infos
    #
    dt=timer()-start
    monitoring['used_data'] = [ pyterk.config._hash_data(x,y) ]
    monitoring['duration']  = dt
    monitoring['mean']      = mean
    monitoring['std']       = std
    about['monitoring']     = monitoring
    
    # ---- Save about file
    #
    with open(aboutfile, 'w') as fd:
        json.dump(about, fd,   sort_keys=False, indent=4)
        
    # ---- Done message
    #
    if verbose == 1 :
        trace_lock.acquire()
        print(f'O', end='')
        trace_lock.release()

    if verbose == 2:
        me=mp.current_process().name
        trace_lock.acquire()
        print(f'{me} saved : {evalfile}')
        print("    evaluation =",evaluation)
        trace_lock.release()
    
    return True

