# ------------------------------------------------------------------
#                  ____        _            _
#                 |  _ \ _   _| |_ ___ _ __| | __
#                 | |_) | | | | __/ _ \ '__| |/ /
#                 |  __/| |_| | ||  __/ |  |   <
#                 |_|    \__, |\__\___|_|  |_|\_\
#                        |___/                              reporter
# ------------------------------------------------------------------
# Python Iterator for Kfold and co. - E Garel / JL Parouty 2021

"""
Module to generate execution reports.

During the run of the tasks, the bestmodel and results are saved in h5 and json files:

* `about.json` : information and description of the task
* `history.json` : history from model.fit()
* `evaluation.json` : evaluation from model.evaluate()
* `bestmodel.h5` : best model

#########
Example : 
#########
::

    reporter.show_run_reports(settings,
                              args       = ['dataset_id','model_id','batch_size'],
                              evaluation = [2])

This module will retrieve information from json files and generate a report.






"""


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator

from IPython.display import display,Image,Markdown,HTML

import os
from glob import glob
from pathlib import Path

import yaml,json,re
import importlib
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
from sklearn.metrics import classification_report
from sklearn.metrics import hamming_loss

import pyterk.config as config

def _subtitle(t):
    display(Markdown(f'<br>**{t}**'))

def _md(t):
    display(Markdown(t))
    
def _html(t):
    display(HTML(t))


    
def show_report(run_dir, padding='', 
                sections   = ['title','context','args','settings','evaluation', 'monitoring', 'history', 'distribution', 'correlation'],
                context    = ['function', 'version', 'date', 'description', 'seed'],
                args       = ['run_dir', 'dataset_id', 'model_id', 'n_iter', 'k_fold', 'epochs', 'batch_size'],
                settings   = ['file', 'version', 'description', 'datasets_dir', 'run_dir'],
                evaluation = ['all'],
                monitoring = ['duration', 'used_data'],
                history      = [ dict(metric='val_mae',    min=None,max=None, figsize=(8,6), savefig=True, mplstyle='pyterk') ],
                distribution = [ dict(metric_id=2, bins=4, min=None,max=None, figsize=(8,6), savefig=True, mplstyle='pyterk') ],
                correlation  = [ dict(axes_min='auto',axes_max='auto', figsize=(8,6), marker='.', markersize=8, alpha=0.7, color='auto', savefig=True, mplstyle='pyterk') ],
                confusion    = [ dict(normalize='pred', predict_type='softmax', figsize=(5,5), savefig=True, mplstyle='pyterk') ]
               ):
    """
    Builds and displays a report from the json data of a given run_dir.

    Args:
        run_dir (string): directory path of json report file
        sections (list): list of sections to include in the report
        context (list): informations to include in context section
        args (list): informations to include in args section
        settings (list): informations to include in settings section
        evaluation (list): \#metrics to include in evaluation section. 'all' mean all. Example : [0,1,2]
        history (dict): parameters for history plot - see `plot_history`
        distribution (dict): parameters for metrics distribution plot
        correlation (dict): parameters for correlation plot
        confusion (dict): parameters for confusion matrix (need yytest files)
    """

    # ---- Reccursive mode or not ?
    #
    if not os.path.isfile(run_dir+'/about.json'):
        params = locals().copy()
        subdirs = sorted(os.listdir(run_dir))
        _md(f'Report for : **{run_dir}**' )
        _md(f'This report have **{len(subdirs)}** parts :')
        _md( '\n'.join(['  - '+s for s in subdirs]) )
        for subdir in subdirs:
            params['run_dir']=os.path.join(run_dir, subdir)
            show_report(**params)
        return
    
    # ---- Retrieve about
    #
    with open(run_dir+'/about.json') as fd:
        about = json.load(fd)
        
    # ---- Retrieve Evaluation
    #
    with open(run_dir+'/evaluation.json') as fd:
        eva = json.load(fd)
        eva = np.array(eva).transpose()
        if 'all' in evaluation: evaluation= range(len(eva))
    
    # ---- Title
    #
    if 'title' in sections:
        _subtitle(about['context']['description'])

    # ---- Context
    #
    if 'context' in sections:
        print(f'{padding}---- context -----------------------------------------------')
        for k in context:
            if k in about['context'] : print(f'{padding}{k:12s} :',about['context'][k])

    # ---- Args
    #
    if 'args' in sections:
        print(f'{padding}---- args --------------------------------------------------')
        for k in args:
            if k in about['args'] : print(f'{padding}{k:12s} :',about['args'][k])

    # ---- Settings
    #
    if 'settings' in sections:
        print(f'{padding}---- settings ----------------------------------------------')
        for k in settings:
            if k in about['settings'] : print(f'{padding}{k:12s} :',about['settings'][k])

    # ---- Evaluation
    #
    if 'evaluation' in sections:
        print(f'{padding}---- evaluation --------------------------------------------')    
        print(f'{padding}id      count        mean           std')
        for i in evaluation:
            m=eva[i]
            mean = np.mean(m)
            std  = np.std(m)
            print(f'{padding}{i}       {len(m):3d}        {mean:7.2f}       {std:7.2f}')

    # ---- Monitoring
    #
    if 'monitoring' in sections:
        print(f'{padding}---- monitoring --------------------------------------------')    
        for k in monitoring:
            if k in about['monitoring'] : print(f'{padding}{k:12s} :',about['monitoring'][k])

    # ---- Add ultimate line to close
    #      Add if one of there section is there
    s=['context','args','evaluation', 'monitoring']
    if len(set(s) & set(sections))>0:
        print(padding+'-'*60)
    
    # ---- history
    #
    if 'history' in sections:
        for params in history:
            params['run_dir']=run_dir
            plot_history(**params)
    
    # ---- distribution
    #
    if 'distribution' in sections:
        for params in distribution:
            params['run_dir']=run_dir
            plot_distribution(**params)

    # ---- correlation
    #
    if 'correlation' in sections:
        for params in correlation:
            # ---- Set run_dir
            #
            if about['context']['function']=='model_fit'         : continue
            if about['context']['function']=='manyfold'          : params['run_dir']=run_dir
            if about['context']['function']=='iterative_manyfold': params['run_dir']=run_dir+'/iter-000'
                
            # ---- Read an yytest.json
            #
            yytest_file = params['run_dir']+'/kfold-00/yytest.json'
            if not os.path.isfile(yytest_file): return
            with open(yytest_file) as fd:
                yydata = json.load(fd)
            y_pred     = np.array( yydata['y_pred'])
            
            # ---- Scalar or vector
            #
            if len(y_pred.shape)==0:
                plot_kfold_correlation(channel=0,**params)
            else:
                for c in range(y_pred.shape[1]):
                    plot_kfold_correlation(channel=c,**params)
    
    # ---- confusion
    #
    if 'confusion' in sections:
        for params in confusion:
            params['run_dir']=run_dir
            plot_confusion(**params)
    
    
    
        
    
def plot_history(run_dir, metric='val_mae', min=None, max=None, figsize=(10,8), savefig=False, mplstyle='pyterk'):
    """
    Plot history evolution from history.json saved file.  
    For a kfold or an iterative kfold, all history data are concatened in history.json file in main run_dir.  
    This will plot a curve for each one in a common plot.

    Args:
        run_dir (string): directory path of json history file
        metric (string): metric name to plot. Example : 'val_mae'
        figsize (tuple): figure size, default is (10,8)
        savefig (boolean): if True, figure will be save in run_dir.
        mplstyle (string): name of matplotlib style. default is 'pyterk', but all matplotlib are ok (default, bmh, ...)

    Returns:
        Nothing, but display a beautifull plot !    
    """
   
    if mplstyle=='pyterk' : mplstyle=config._pyterk_path('/pyterk.mplstyle')
    
    # ---- Load history
    history_file = run_dir+'/history.json'
    print('History from :',history_file)
    with open(history_file) as fd:
        history = json.load(fd)
    # ---- Get metric data
    m = [ h[metric] for h in history ]
    print('Number of curves :',len(m))
    # ---- Plot it
    with plt.style.context(mplstyle):
        plt.figure(figsize=figsize)
        plt.title(f'History of metric : {metric}')
        plt.ylabel(metric)
        plt.xlabel('Epoch')
        ax = plt.gca()
        ax.xaxis.set_major_locator(MaxNLocator(integer=True))
        if (min,max) != (None,None):
            ax.set_xlim([min,max])
        for c in m:
            plt.plot(c,color='tomato', alpha=0.5)
        if savefig:
            save_as = f'{run_dir}/history-{metric}.png'
            plt.savefig(save_as,dpi=300)
    plt.show()
    if savefig:  print('saved as : ',save_as)
    
    
    
def plot_distribution(run_dir, metric_id=0, bins=10, min=None,max=None,
                      figsize=(10,8), savefig=False, mplstyle='pyterk'):
    """
    Plot distribution of a given metric from an evaluation.json saved file.  
    For a kfold or an iterative kfold, all evaluation data are concatened in an evaluation.json file in main run_dir.

    Args:
        run_dir (string): directory path of json evaluation file
        metricid (int): number of metric to plot. Example : 2
        min (int): min value
        max (int): max value
        bins (int): number of bins
        figsize (tuple): figure size, default is (10,8)
        savefig (boolean): if True, figure will be save in run_dir.
        mplstyle (string): name of matplotlib style. default is 'pyterk', but all matplotlib are ok (default, bmh, ...)

    Returns:
        Nothing, but display a beautifull distribution plot !    
    """
     
    if mplstyle=='pyterk' : mplstyle=config._pyterk_path('/pyterk.mplstyle')
    # ---- Load evaluations
    with open(run_dir+'/evaluation.json') as fd:
        eva = json.load(fd)
        eva = np.array(eva).transpose()
    # ---- plot it
    with plt.style.context(mplstyle):
        plt.figure(figsize=figsize)
        plt.title(f'Distribution of metric : #{metric_id}')
        plt.ylabel('Frequency')
        plt.xlabel('Metric')
        ax = plt.gca()
        if (min,max) != (None,None):
            ax.set_xlim([min,max])
        plt.hist(eva[metric_id],bins=bins)
    if savefig:
        save_as = f'{run_dir}/distribution-{metric_id}.png'
        plt.savefig(save_as,dpi=300)
    plt.show()
    if savefig:  print('saved as : ',save_as)
        

    
def plot_kfold_correlation(run_dir, channel=0, 
                      figsize=(8,6), axes_min='auto', axes_max='auto', yy_deltamax=None,
                      marker='o', markersize=8, alpha=0.7, color='auto', savefig=True, mplstyle='pyterk'):
    """
    Plot a correlation for a (y_test, y_pred) saved json file.

    Args:
        run_file: a manyfold directory where kfold subdirectories are
        channel: composant of y to plot
        figsize (tuple): figure size, default is (10,8)
        axes_min : min value for x and y axe. 'auto' or float
        axes_max : max value for x and y axe. 'auto' or float
        mplstyle (string): name of matplotlib style. default is 'pyterk', but all matplotlib are ok (default, bmh, ...)
        marker: marker, default is '.'
        markersize: marker size
        alpha: marker alpha
        color: plot color or 'auto'
        savefig: if True, save fig in run_dir

    Returns:
        Nothing, but display a beautifull correlation plot 
    """

    if mplstyle=='pyterk' : mplstyle=config._pyterk_path('/pyterk.mplstyle')

    # ---- Retreive subdirs
    #
    subdirs = [f.path for f in os.scandir(run_dir) if f.is_dir() and not f.name.startswith('.')]
    subdirs = sorted(subdirs)    
    if not os.path.isfile(subdirs[0]+'/yytest.json'): return
        
    # ---- Axes min/max
    #
    xy_min =  float('inf') if axes_min=='auto' else axes_min
    xy_max = -float('inf') if axes_max=='auto' else axes_max
     
    # ---- Plot figure
    #
    params={'marker':marker, 'markersize':markersize, 'alpha':alpha, 'color':color}
    if color=='auto': del params['color']      
        
    with plt.style.context(mplstyle):
        plt.figure(figsize=figsize)
        plt.title(f'Correlation y_test/y_pred - channel {channel}')
        plt.ylabel('y_pred')
        plt.xlabel('y_test')

        # ---- Plot y_test, y_pred
        #
        all_x_out, all_y_out, all_d_out = [],[],[]
        for s in subdirs:
            with open(f'{s}/about.json') as fd:
                about=json.load(fd)
                mean=float(about["monitoring"]["mean"])
                std=float(about["monitoring"]["std"])
            with open(f'{s}/yytest.json') as fd:
                yyfile=json.load(fd)
                y_test = np.array( yyfile['y_test'])
                y_pred = np.array( yyfile['y_pred'])

            if len(y_test.shape)>=1:
                y_test = y_test[:,channel]
                y_pred = y_pred[:,channel]

            if axes_min=='auto' : xy_min = min( min(y_pred), min(y_test), xy_min )
            if axes_max=='auto' : xy_max = max( max(y_pred), max(y_test), xy_max )

            plt.plot(y_test,y_pred, linestyle='', **params)

            if yy_deltamax is not None:
                with open(f'{s}/xxtest.json') as fd:
                    x_test = np.array( json.load(fd), dtype='float' )
                delta_y    = np.absolute( y_pred - y_test )
                i_out      = np.where( delta_y > yy_deltamax )
                all_x_out.extend( (x_test[ i_out ]*std+mean).tolist() )
                all_y_out.extend( y_test[ i_out ].tolist()  )
                all_d_out.extend( delta_y[ i_out ].tolist() )
                plt.plot(y_test[i_out],y_pred[i_out], linestyle='', c='dimgray', alpha=1, marker='x', markersize=markersize*1.5)
            
        plt.axis('equal')
        axes = plt.gca()
        axes.set_xlim( xy_min, xy_max )
        axes.set_ylim( xy_min, xy_max )
        plt.plot([0,xy_max], [0,xy_max], '--', color='lightgray')

        if savefig:
            save_as = f'{run_dir}/correlation-{channel}.png'
            plt.savefig(save_as)
        plt.show()
        if savefig:  print('saved as : ',save_as)

        if yy_deltamax is not None:
            df = pd.DataFrame( {'x':all_x_out, 'y':all_y_out, 'delta':all_d_out})
            df['s'] = df['x'].astype(str)
            df = df.drop_duplicates(subset=['s'])
            df = df.drop(['s'], axis=1)
            df = df.sort_values(by='delta', ascending=False)
            return df
    
    


def plot_confusion(run_dir, predict_type='softmax', normalize='pred', figsize=(5,5), savefig=True, mplstyle='pyterk'):
    '''
    Plot a confusion matrix

    Args:
        iterations_dir : a directory with iterations subdirs (iter-000, iter-001, ...)
        predict_type : sigmoid, softmax or classes
        normalize : true, pred, all or None (pred)
        figsize: figure size
        savefig: save fig (True) or not (False)

    Return:
        Just plot the matrix and print report and hamming loss
    '''

    # ---- Search and cumul all yytest.json
    #
    yy_test=[]
    yy_pred=[]

    for path in Path(run_dir).rglob('yytest.json'):
    
        with open(path) as fd:
                yyfile=json.load(fd)
                y_test = np.array( yyfile['y_test']).squeeze()
                y_pred = np.array( yyfile['y_pred'])

        yy_test.extend(y_test)
        yy_pred.extend(y_pred)
    
    if len(yy_pred)==0:
        print('** Warning : No yy_test values found...')
        return

    # ---- Retrieve classes from yy_pred
    #
    yy_test = np.array(yy_test)
    yy_pred = np.array(yy_pred)

    if predict_type=='softmax':
        print('y_pred is considered as softmax array')
        yy_pred = np.array( [ np.argmax(y) for y in yy_pred] )
    
    if predict_type=='sigmoid':
        print('y_pred is considered as sigmoid array')
        yy_pred = np.array( [ 0 if y<0.5 else 1 for y in yy_pred] )
        
    if predict_type=='classes':
        print('y_pred is considered as classes array')
        yy_pred = yy_pred.squeeze()

    # ---- Print nice stuffs
    #
    print('Nombre de données cumulées : ',len(yy_pred))

    display(Markdown('**Confusion matrix**'))
    cm = confusion_matrix( yy_test, yy_pred, normalize=normalize)
    cmp=ConfusionMatrixDisplay(confusion_matrix=cm)
    plt.rcParams.update({'font.size': 16})
    _, ax = plt.subplots(figsize=figsize)
    cmp.plot(ax=ax)

    # ---- Plot and save
    #
    if savefig:
        save_as = f'{run_dir}/confusion-matrix.png'
        plt.savefig(save_as,dpi=300)
    plt.show()
    if savefig:  print('saved as : ',save_as)

    display(Markdown('**Classification report**'))
    df=pd.DataFrame(classification_report(yy_test,yy_pred,output_dict=True))
#     display(df.T.style.format(precision=2))
    display(df.T)

    display(Markdown('**Hamming Loss**'))
    hml=hamming_loss(yy_test, yy_pred)
    print(f'Hamming loss : {hml:.3f}')



    
def show_run_reports(run_config,
                    run_filter = '.*',
                    sections   = ['title','context','args','settings','evaluation', 'monitoring', 'history', 'distribution', 'correlation', 'confusion'],
                    context    = ['function', 'version', 'date', 'description', 'seed'],
                    args       = ['run_dir', 'dataset_id', 'model_id', 'n_iter', 'k_fold', 'epochs', 'batch_size'],
                    settings   = ['file', 'version', 'description', 'datasets_dir', 'run_dir'],
                    evaluation = ['all'],
                    monitoring = ['duration', 'used_data'],
                    history      = [ dict(metric='val_mae',    min=None,max=None, figsize=(8,6), savefig=True, mplstyle='pyterk') ],
                    distribution = [ dict(metric_id=2, bins=4, min=None,max=None, figsize=(8,6), savefig=True, mplstyle='pyterk') ],
                    correlation  = [ dict(axes_min='auto',axes_max='auto', figsize=(8,6), marker='.', markersize=8, alpha=0.7, color='auto', savefig=True, mplstyle='pyterk') ],
                    confusion    = [ dict(normalize='pred', predict_type='softmax', figsize=(5,5), savefig=True, mplstyle='pyterk') ]
                    ):


    """
    Displays a full report in two parts, short and long, for all runs defined in the settings.
    Very simple to use...

    Args:
        run_config (dict): settings, issued from config.load()
        run_filter (regx): regex to filter run entries from yml settings file (.*)
        sections (list): list of sections to include in the report
        context (list): informations to include in context section
        args (list): informations to include in args section
        settings (list): informations to include in settings section
        evaluation (list): \#metrics to include in evaluation section. 'all' mean all. Example : [0,1,2]
        history (dict): parameters for history plot - see `plot_history`
        distribution (dict): parameters for metrics distribution plot
        correlation (dict): parameters for correlation plot
        confusion (dict): parameters for confusion matrix (need yytest files)

    Returns:
        Nothing, but display a short and long report, with index.

    """
    
    def menuline(i1,i2,run_id):
        '''
        Return sommaire line, title line
        Args:
            i1,i2 Numbers ex: 1,1 for 1.1
            run_id : run id
        Returns:
            sommaire line (title with link)
            title line
        '''
        desc = run_config['runs'][run_id]['description']
        title=f'{i1}.{i2} - {desc} - ({run_id})'
        link = title.replace(' ','-').replace('(','-').replace(')','-')
        a = f'<a name="{link}"></a>'
        s = f'[{title}](#{link})'
        t = f'## {title}'
        return a,s,t
    
    # ---- Retreive usefull infos
    #
    run_dir  = run_config['global']['run_dir']
    run_list = run_config['runs'].keys()

    # ---- List of runs
    #
    reg = re.compile(run_filter)
    run_list   = list( filter(reg.match, run_list) )
    
    # ---- Display sommaire
    #
    _html('<a name="Sommaire"></a>')
    _md('## Sommaire')
    _md('### 1. Short reports')
    i1, i2, index = 1,1, []
    for run_id in run_list:
        a,s,t = menuline(i1,i2,run_id )
        index.append(s)
        i2+=1
    _md('  \n'.join(index))

    _md('### 2. Long reports')
    i1, i2, index = 2,1, []
    for run in run_list:
        a,s,t = menuline(i1,i2,run )
        index.append(s)
        i2+=1
    _md('  \n'.join(index))
        
    # ---- Short report
    #
    _md('# 1. Short reports')
    i1, i2 = 1,1
    for run_id in run_list:
        
        a,s,t = menuline(i1,i2,run_id )
        _html(a)
        _md(t)
        _md('[(Sommaire)](#Sommaire)')
        
        my_run_dir=f'{run_dir}/{run_id}'
        show_report(my_run_dir,
                    padding='     ',
                    sections   = ['title','args','evaluation' ],
                    args       = ['run_dir', 'dataset_id', 'model_id'],
                    evaluation = evaluation
                    )
        i2+=1
        
    # ---- Long report
    #
    _md('# 2. Long reports')
    i1, i2 = 2,1
    for run_id in run_list:
        
        a,s,t = menuline(i1,i2,run_id )
        _html(a)
        _md(t)
        _md('[(Sommaire)](#Sommaire)')
        
        my_run_dir=f'{run_dir}/{run_id}'
        show_report(my_run_dir,
                    padding='     ',
                    sections=sections,
                    context=context, args=args, settings=settings, evaluation=evaluation, monitoring=monitoring, 
                    history=history, distribution=distribution, correlation=correlation, confusion=confusion
               )
        
        i2+=1
    