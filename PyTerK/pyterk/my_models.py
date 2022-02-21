
# ------------------------------------------------------------------
#        __  __         __  __           _      _
#       |  \/  |_   _  |  \/  | ___   __| | ___| |___
#       | |\/| | | | | | |\/| |/ _ \ / _` |/ _ \ / __|
#       | |  | | |_| | | |  | | (_) | (_| |  __/ \__ \
#       |_|  |_|\__, | |_|  |_|\___/ \__,_|\___|_|___/
#               |___/                                     My Models
# ------------------------------------------------------------------

""" Module to copy in same folder than `run`notebooks. It allow to build a model from keras or scikit learn library"""


from tensorflow import keras
import tensorflow as tf

from sklearn.ensemble import RandomForestRegressor

import numpy as np


def get_keras_mpp(input_shape=(5,), neurons=[20,20,2], activations=['relu','relu',None], 
              optimizer='adam', loss='mse', metrics=['mse','mae'],
              verbose=False):
    '''
    Return a tensorflow/keras  model
    params:
        input_shape : shape of input data (5,)
        neurons     : number of neurons per layer ([20,20,2])
        activations : activation function for each layer (['relu','relu',None])
        optimizer   : optimizer for gradient descent ('adam')
        loss        : loss function ('mse')
        metrics     : metrics (['mse','mae'])
        verbose     : print a model summary (False)
    return :
        compiled model
    '''
    model = keras.models.Sequential()
    
    model.add( keras.layers.InputLayer(input_shape=input_shape) )
    
    for i in range(len(neurons)):
        if activations[i]=='None' :activations[i]=None
        model.add( keras.layers.Dense(neurons[i], activations[i]) )

#     keras.backend.set_epsilon(1)
    
    model.compile(optimizer = optimizer,
                 loss       = loss,
                 metrics    = metrics )
    
    if verbose: model.summary()
    return model


def get_sklearn_rfr(max_depth=10, n_estimators=200):
    '''
    Return a sklearn / random forest model
    params:
        max_depth    : max depth of trees 
        n_estimators : number of trees
    return :
        model
    '''
    model = RandomForestRegressor(max_depth=max_depth, n_estimators=n_estimators, n_jobs=1)
    return model
