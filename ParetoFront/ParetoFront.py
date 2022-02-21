# -*- coding: utf-8 -*-
"""
############
Description
############

Module to train detect Pareto optimum points for two properties

Contains functions to :
    * define Pareto front with a certain acceptation width
    * plot Pareto optimal points among all points
    * save Pareto optimal points 

##########
Functions
##########

"""

import pandas as pd
import numpy as np
import os as os
import matplotlib.pyplot as plt



def pareto_frontier(dataframe, objective1, objective2,acceptation_range_objective2):
    '''Pareto frontier selection process
    
    :param panda.DataFrame dataframe: datasets that contains the two antagonistic properties values
    :param str objective1: column of the dataframe that contains the first objective/property to optimize
    :param str objective2: column of the dataframe that contains the second objective/property to optimize
    :param float acceptation_range_objective2: width of Pareto band, value is zero if we keep the strictly optimal values, higher than zero if we accept points close to the front. 
    :return: - pareto_front: Pareto optimal points or near optimal points
             - color: optimal points are associated to red, near optimal in orange.
    :rtype: panda.DataFrame,str
    '''
    
    # Sort by objective 1
    sorted_dataframe=dataframe.sort_values(by=objective1, ascending=False)

    # First point of the front : maximise objective 1, minimise objective 2
    pareto_front = pd.DataFrame(sorted_dataframe.iloc[0,:]).T
    min_objective2=pareto_front[objective2]
    colors=['red']

    for i in range (1,len(sorted_dataframe)):
        # for each line of the sorted dataframe
        line=pd.DataFrame(sorted_dataframe.iloc[i,:]).T 
        # objective 2 must increases to be part of Pareto frontier (which will be plotted in red)
        if float(line[objective2])>=float(min_objective2): 
            pareto_front=pareto_front.append(line,ignore_index=True)
            min_objective2=line[objective2] # new minimum of objective 2 
            colors.append('red')
        
        # one can accept a certain error range on objective 2  (experimental error, calculation error...).These points will be plotted in orange
        if float(line[objective2])<float(min_objective2) and abs(float(line[objective2])-float(min_objective2))<acceptation_range_objective2  :
            pareto_front=pareto_front.append(line,ignore_index=True)
            colors.append('orange')

    # return the points of the Pareto frontier and colors. 
    return [pareto_front,colors]

def plot_pareto(dataframe,pareto_front, objective1, objective2, txt_objective1, txt_objective2,colors,save):
    '''Plotting Pareto frontier
    
    :param panda.DataFrame dataframe: datasets that contains the two antagonistic properties values
    :param panda.DataFrame pareto_front: Pareto optimal and near optimal points
    :param str objective1: column of the dataframe that contains the first objective/property to optimize
    :param str objective2: column of the dataframe that contains the second objective/property to optimize
    :param str txt_objective1: axis name corresponding to objective1
    :param str txt_objective2: axis name corresponding to objective2
    :param str colors: color associated with optimal (red) and near optimal(orange) points
    :param str save: path to save the Pareto front plot
    :return: Nothing, just plot the Pareto front.
    '''

    plt.figure(figsize=(10,10))
    # scatter all points 
    plt.scatter(dataframe[objective2],dataframe[objective1],s=5)

    #re-scatter in colors the Pareto frontier
    pf_X = pareto_front[objective2]
    pf_Y = pareto_front[objective1]
    plt.grid()
    plt.scatter(pf_X, pf_Y, s=5, c=colors)
    plt.rcParams.update({'axes.titlesize': 'large',
                 'axes.labelsize':'large', 
                 'ytick.labelsize': 'large',
                 'xtick.labelsize': 'large'})
    plt.xlabel(txt_objective1)
    plt.ylabel(txt_objective2)

    # Save the plot 
    plt.savefig(save)
    plt.show()

    