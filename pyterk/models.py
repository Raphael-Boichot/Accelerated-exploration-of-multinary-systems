
# ------------------------------------------------------------------
#     ____       _       _                 _
#    |  _ \ ___ | |_   _| |_ ___ _ __ __ _| |_ ___  _ __
#    | |_) / _ \| | | | | __/ _ \ '__/ _` | __/ _ \| '__|
#    |  __/ (_) | | |_| | ||  __/ | | (_| | || (_) | |
#    |_|   \___/|_|\__, |\__\___|_|  \__,_|\__\___/|_|
#                  |___/                               Models stuff
# ------------------------------------------------------------------
# Python Iterator for Kfold and co. - E Garel / JL Parouty 2021


"""
This module is for internal use only - You do not have to interact with ;-).
"""



import importlib
import os


def get_model(profile):
    '''
    Get a model from a model profile.
    The profile contains the module and function name of the model, and the arguments.
    The model will be retrieved by calling the function with the arguments.

    Args:
        profile (dict): a model profile

    Returns:
        model (keras model): keras model as defined in the profile.
    '''
    
    module_name   = profile.get('module')
    function_name = profile.get('function')
    class_name    = profile.get('class')
    args          = profile.get('args')
    
    # ---- Load module
    #
    module    = importlib.import_module(module_name)

    # ---- Get model by function
    #
    if function_name is not None:
        function_ = getattr(module,function_name)
        model     = function_(**args)
        return model

    # ---- Get model by class
    #
    if class_name is not None:
        class_ = getattr(module, class_name)
        model  = class_(**args)
        return model



