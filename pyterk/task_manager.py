# ------------------------------------------------------------------
#                  ____        _            _
#                 |  _ \ _   _| |_ ___ _ __| | __
#                 | |_) | | | | __/ _ \ '__| |/ /
#                 |  __/| |_| | ||  __/ |  |   <
#                 |_|    \__, |\__\___|_|  |_|\_\
#                        |___/                         task manager
# ------------------------------------------------------------------
# Python Iterator for Kfold and co. - E Garel / JL Parouty 2021

"""
Allows to generate tasks and to execute them in a distributed way.  

See example notebook : `03-Example-03.ipynb`


Example :
```
task_manager.add_combinational_iterative_manyfold(settings = settings, 
                                                  run_key= 'Example-03.3')
```
"""



import numpy as np
import pandas as pd
from sklearn.model_selection import KFold

import multiprocessing as mp
import random
import os, json
import datetime, time

from collections     import OrderedDict
from timeit          import default_timer as timer
from IPython.display import display,Image,Markdown,HTML

import pyterk
import pyterk.worker  as worker
import pyterk.config  as config


_settings = None
_seed     = None
_tasks    = []
_posts    = OrderedDict()


def _subtitle(t):
    display(Markdown(f'<br>**{t}**'))
    
    
def show_tasks_size():
    """Print pending tasks size"""
    print('Total pending tasks:',len(_tasks))

    
def reset():
    """Reset pending tasks. Suppress all of them !"""
    global _tasks
    _tasks = []
    _posts = OrderedDict()
    print('All pending tasks have been removed.')

    
def seed(seed=None):
    '''Init random generators with given seed'''
    global _seed
    # ---- seed : None
    if seed is None or seed == 'None':
        print('Seed is None : do nothing.')
        return
    # ---- Given seed is settings
    if type(seed) == dict:
        seed=seed['global']['seed']
    # ---- Seed it
    _subtitle('Init random generators...')
    print('With seed    :',seed)
    np.random.seed(seed)
    random.seed(seed)
    _seed=seed
    
    
def _get_about(fname, params):
    """
    Return an about dict with 3 sections (context,args and monitoring)
    Args:
        fname (string): function name that generate the about
        params (dict): aguments of the function
    Returns:
        about dict, that will be save later, after all tasks are done.
    """
    
    about      = OrderedDict()
    context    = OrderedDict()
    args       = OrderedDict()
    monitoring = OrderedDict()
    
    # ---- Context 
    #
    context['function']    = fname
    context['version']     = pyterk.VERSION
    context['date']        = datetime.datetime.now().strftime("%A %d %B %Y, %H:%M:%S")
    context['description'] = params['description']
    context['seed']        = _seed
    
    # ---- Args
    #
    for k in ['run_dir', 'dataset_id', 'model_id', 'n_iter', 'k_fold', 'epochs', 'batch_size']:
        if k in params: args[k]=params[k]
    
    # ---- Monitoring
    #
    monitoring['used_data'] = []
    monitoring['duration']  = 0
    
    # --- 
    about['context']    = context
    about['args']       = args
    about['settings']   = _settings['global']
    about['monitoring'] = monitoring
    
    return about
    
    
    
def add_manyfold(settings=None, run_dir=None, 
                 dataset_id=None, model_id=None, 
                 k_fold=10, epochs=10, batch_size=10, description=None,
                 save_xxtest=False,
                 save_yytest=False,
                 verbose=1):
    """
    Add tasks for a manyfold - see `01-Example-01.ipynb`  
    Generate k_fold tasks, each task will generate one subdirectory in run_dir.
    Args:
        settings (dict): settings
        run_dir (string): run directoty to output k results (json files and best model)
        dataset_id (string): datasets id in settings file
        model_id (string): model id in settings file
        k_fold (int): number of fold
        epochs (int): number of epochs
        batch_size (int): size of batch
        description (string): description of the action
        save_xxtest (Boolean): save x_test as json file, or not
        save_yytest (Boolean): save y_test and y_pred  as json file, or not
        verbose (int): verbosity of generated tasks
    Returns:
        Nothings. Task are added to the pending taks queue.
    """
    
    global _settings
    global _tasks
    global _posts
    
    _settings = settings
    
    # ---- Few words
    #    
    if verbose>0:
        _subtitle('Add manyfold taks...')
        print('Directory          :',run_dir)
        print('Description        :',description)
        print('Models to fit      :',k_fold)

    # ---- Get x,y
    #
    (x,y) = settings['datasets'][dataset_id]['xy']
    
    # ---- Cutting into K folds
    #
    kf = KFold(n_splits=k_fold, shuffle=True)
    k=0
    for train_index, test_index in kf.split(x):

        seed = random.randint(1,9999999)
        k_dir = f'{run_dir}/kfold-{k:02d}'
        task=(k_dir, dataset_id, train_index, test_index, model_id, epochs, batch_size, seed, description, save_xxtest, save_yytest)
        _tasks.append(task)
        k+=1

    # ---- Prepare about file (which will be saved later)
    #
    about = _get_about( 'manyfold', locals() )
    _posts[run_dir]=about
        
    if verbose>0:
        show_tasks_size()

        
        
        
def add_iterative_manyfold(settings=None, run_dir=None, 
                           dataset_id=None, model_id=None, 
                           n_iter=2, k_fold=10, epochs=10, batch_size=10, 
                           description=None,
                           save_xxtest=False,
                           save_yytest=False,
                           verbose=1):
    """
    Add tasks for an iterative manyfold - see `02-Example-02.ipynb`  
    Generate n_ter*k_fold tasks, each iteration will generate a subdirectory in run_dir.
    Args:
        settings (dict): settings
        run_dir (string): run directoty to output k results (json files and best model)
        dataset_id (string): datasets id in settings file
        model_id (string): model id in settings file
        n_iter (int): number of iteration
        k_fold (int): number of fold
        epochs (int): number of epochs
        batch_size (int): size of batch
        description (string): description of the action
        save_xxtest (Boolean): save x_test as json file, or not
        save_yytest (Boolean): save y_test and y_pred  as json file, or not
        verbose (int): verbosity of generated tasks
    Returns:
        Nothings. Task are added to the pending taks queue.
    """

    global _settings
    global _tasks
    global _posts
    
    _settings = settings

    # ---- Few words
    #    
    if verbose>0:
        _subtitle('Add iterative manyfold taks...')
        print('Directory          :',run_dir)
        print('Description        :',description)
        print('Models to fit      :',n_iter*k_fold)
    
    # ---- Iterate...
    #   
    for i in range(n_iter):
                   
        # ---- run_dir subdirectory
        #
        run_dir_i = f'{run_dir}/iter-{i:03d}'
        
        # ---- Add manyfold
        #
        add_manyfold(settings=settings, run_dir=run_dir_i, 
                     dataset_id=dataset_id, model_id=model_id, 
                     k_fold=k_fold, epochs=epochs, batch_size=batch_size, 
                     description=description, 
                     save_xxtest=save_xxtest, 
                     save_yytest=save_yytest,
                     verbose=0)
    
    # ---- Prepare about file (which will be saved later)
    #
    about = _get_about( 'iterative_manyfold', locals() )
    _posts[run_dir]=about

    if verbose>0:
        show_tasks_size()
    
    
    
def add_combinational_iterative_manyfold(settings=None, run_key=None, verbose=1):
    """
    Add tasks for a combinational iterative manyfold - `see 03-Example-03`.ipynb  
    Generates all the tasks of the combinatorial described in the run section of the settings file.
    Args:
        settings (dict): settings
        run_key (string): name of the config run section
        verbose (int): verbosity of generated tasks
    Returns:
        Nothings. Task are added to the pending taks queue.
    """

    global _settings
    global _tasks
    global _posts

    _settings = settings

    # ---- What we need
    
    models   = settings['models']
    datasets = settings['datasets']
    run_dir  = settings['global']['run_dir']
    
    # ---- get the run profile
    
    run      = settings['runs'][run_key]
        
    run_name    = run['key']
    description = run['description']
    save_xxtest = run.get('save_xxtest', False)
    save_yytest = run.get('save_yytest', False)
    
    # ---- Few words
    #
    if verbose>0:
        _subtitle('Add combinational iterative manyfold...')
        print('Run name           :',run_name)
        print('Directory          :',f'{run_dir}/{run_name}')
        print('Description        :',description)
    
    # ---- How many manyfold will we have to call ?
    #
    n_steps=1
    for d in ['datasets', 'models', 'n_iters', 'k_folds', 'epochs', 'batch_sizes']:
         n_steps=n_steps*len(run[d])
    print('Iterative manifold :',n_steps)

    # ---- How many models will we have to fit ?
    #
    n_mods=0
    for i in run['n_iters']:
        for k in run['k_folds']:
            n_mods+=i*k
    n_mods=n_mods*n_steps
    print('Models to fit      :',n_mods)

    # ---- Start combinational game...

    run_id       = 0
    chrono_start = time.time()

    for dataset_id in run['datasets']:
        for model_id in run['models']:
            for n_iter in run['n_iters']:
                for k_fold in run['k_folds']:
                        for epochs in run['epochs']:
                            for batch_size in run['batch_sizes']:

                                my_run_dir     = f'{run_dir}/{run_name}/{run_name}-{run_id:04d}'
                                my_description = f'{run_name}-{run_id:04d} {description}'

                                # ---- Add tasks
                                #
                                add_iterative_manyfold(settings=_settings, run_dir=my_run_dir,
                                                       dataset_id=dataset_id, model_id=model_id,
                                                       n_iter=n_iter, k_fold=k_fold, epochs=epochs, batch_size=batch_size,
                                                       description=my_description,
                                                       save_xxtest=save_xxtest, 
                                                       save_yytest=save_yytest, 
                                                       verbose=0 )

                                run_id+=1

    if verbose>0:
        show_tasks_size()

       
    
        
def run(processes=None, maxtasksperchild=10, verbose=1):
    
#     mp.set_start_method('spawn')

    if processes is None: processes = mp.cpu_count()
    
    _subtitle('Run pending tasks...')
    print('Number of cores   :', mp.cpu_count())
    print('Number of workers :', processes)
    print('Number of tasks   :', len(_tasks),'\n')

    print('o : job start    O : job end    . :job already done    + : results synthesis\n')
    
    # ---- Prepare pool
    trace_lock= mp.Lock()
    
    pool = mp.Pool(initializer = worker.init,
                   initargs    = [_settings, trace_lock, verbose],
                   processes   = processes,
                   maxtasksperchild = maxtasksperchild)
   
    # ---- Run...
    start = timer()
    res   = pool.starmap(worker.model_fit, _tasks)
    pool.close()
    pool.join()

    # ---- Post update
    #      Concat evaluation/history and save about files
    #
    print()
    for run_dir,about in _posts.items():
        _post_update(run_dir,about)
        
    # ---- All is done
    #
    problems = abs(sum(res)-len(_tasks))
    if problems==0:
        print(f'\n\nDone. All {len(_tasks)} tasks appear to have been completed correctly.')
    else:
        print(f'\n\n*** Args... {problems} tasks seem to have disappeared ! :-((')

    dt = timer()-start
    print(f'\nDuration : {dt:.2f} s')
    
    


def _post_update(run_dir, about, verbose=1):

    # ---- Retreive subdirs
    #
    subdirs = [f.path for f in os.scandir(run_dir) if f.is_dir() and not f.name.startswith('.')]
    subdirs = sorted(subdirs)

    # ---- Read evaluation and history in each subdir
    #
    all_evaluation    = []
    all_history       = []
    duration          = 0
    used_data         = []
    
    for s in subdirs:

        with open(s+'/about.json') as fd:
            about_s = json.load(fd)

        with open(s+'/history.json') as fd:
            history_s = json.load(fd)

        with open(s+'/evaluation.json') as fd:
            evaluation_s = json.load(fd)

        #  ---- Concat data or [data,...]

        if type(history_s) is list:
            all_history.extend(history_s)
            all_evaluation.extend(evaluation_s)
        else:
            all_history.append(history_s)
            all_evaluation.append(evaluation_s)

        duration+=about_s['monitoring']['duration']
        used_data.extend(about_s['monitoring']['used_data'])
            
    about['monitoring']['duration']  = round(duration,2)
    about['monitoring']['used_data'] = list(set(used_data))
    
    # ---- Save them
    #
    aboutfile = f'{run_dir}/about.json'
    histfile  = f'{run_dir}/history.json'
    evalfile  = f'{run_dir}/evaluation.json'

    with open(aboutfile, 'w') as fd:
        json.dump(about, fd,          sort_keys=False, indent=4)
    with open(histfile, 'w')  as fd:
        json.dump(all_history, fd,    sort_keys=False, indent=4)
    with open(evalfile, 'w')  as fd:
        json.dump(all_evaluation, fd, sort_keys=False, indent=4)
    
    if verbose==1:
        print('+', end='')
    if verbose==2:
        print(f'Update : {run_dir} ({len(subdirs)} sub.)')
    
    
    
    
    
    
    
    