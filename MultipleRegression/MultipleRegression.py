# -*- coding: utf-8 -*-
"""
Module to train Multiple Linear Regression with Scheffe ineteraction terms with iterative k-fold crossvalidation

Contains functions to :

    - generate interactions

    - train regression models

    - plot iterative k-fold crossvalidation results


"""

import numpy as np
import statsmodels.formula.api as smf
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import KFold
import matplotlib.pyplot as plt
import sys


sys.path.append('../')
import pyterk.config as config



def Scheffe_interactions_terms(data, in_percent='True',compo_columns=['Zr', 'Nb','Mo','Ti','Cr'] ):
    """
    Shaping composition in percentage rate into percentage
    Compute interaction terms for all Scheffe interactions for quartic multiple regression and add it to dataframe data
        
        
    :param panda.DataFrame: dataset that contains compositions in Zr, Nb, Mo, Ti, Cr in columns of the same name
    :return: extended input dataset with interactions 
    :rtype: DataFrame
    """

    if in_percent=='True':
        data[['Zr', 'Nb','Mo','Ti','Cr']]=data[['Zr', 'Nb','Mo','Ti','Cr']]/100

     # Differences
    for i in range(0,len(compo_columns)):
        for j in range(i+1,len(compo_columns)):
            data[compo_columns[i]+'_'+compo_columns[j]]=data[compo_columns[i]]-data[compo_columns[j]]

    # Squared compositions
    for i in range(0,len(compo_columns)):
        data[compo_columns[i]+'2']=data[compo_columns[i]]**2
            
    #Quared differences
    for i in range(0,len(compo_columns)):
        for j in range(i+1,len(compo_columns)):
            data[compo_columns[i]+'_'+compo_columns[j]+'2']=(data[compo_columns[i]]-data[compo_columns[j]])**2
    
    
    return data
  
    
def fit_outputs(model_expression,k,nb_it,output,X,y):
    """
    Takes an OLS model expression, and use it to perform regression between X and y . 
    Model regression is performed using iterative k-fold crossvalidation
    Evaluation is performed through R2 and MAE computation 
    
    :param OLS-formula: contain OLS formula for regression
    :param int k: number of folds for iterative k-fold crossfvalidation
    :param int nb_it: number of iterations for iterative k-fold crossfvalidation
    :param str output: name of the Y output to fit
    :param panda.DtataFrame X: contains composition and interaction terms for regression input
    :param panda.DataFrame y: contains single column dataframe with regression output

    :return model: model coefficients and p-values
    :rtype: statsmodels.regression.linear_model.RegressionResultsWrapper
    :return MAE_list: list of MAE for every run of iterative k-fold crossvalidation, between expected vs predicted value on test set
    :rtype: list
    :return R2_list: list of R2 for every run of iterative k-fold crossvalidation, between expected vs predicted value on test set
    :rtype: list
    :return: Y_pred : list of predicted values on test set
    :rtype: list
    :return: Y_test : list of expected values on test set
    :rtype: list
    """

    kf = KFold(n_splits=k, shuffle=True)
    Y_pred=[]
    Y_test=[]
    R2_list=[]
    MAE_list=[]
    for it in range (0,nb_it):
        for train_index, test_index in kf.split(X):
            # split in k-fold
            X_train, X_test = X.iloc[train_index,:], X.iloc[test_index,:]
            y_train, y_test = y.iloc[train_index], y.iloc[test_index]

            # keep in memory the test outputs y for all k-fold and iterations
            Y_test.append(y_test)

            #create rtain dataframe
            train_data=X_train.copy()
            train_data[output]=y_train
            
            # train model
            model = smf.ols(model_expression,data=train_data)
            model=model.fit()

            # Compute predictions and keep in momory the predicted outputs 
            y_pred=model.predict(X_test)
            Y_pred.append(y_pred)

            # Compute R2 on y_pred vs y_test 
            corr_matrix = np.corrcoef(y_test,y_pred)
            corr = corr_matrix[0,1]
            R2 = corr**2
            R2_list.append(R2)

            # Compute MAE
            MAE=mean_absolute_error(y_test, y_pred)
            MAE_list.append(MAE)
            

    return model, MAE_list,R2_list,Y_pred,Y_test



def plot_result( metric, output , val_metric, Y_pred, Y_test, min_hist, max_hist, iter, kfold, save_distri, save_regression):
    """ 
    Plot metric histogram and regression between predictions and test values and save graphs

    :param str metric: name of the metric distribution to plot
    :param str output: name of the Y output to fit
    :param list val_metric: list of MAE for every run of iterative k-fold crossvalidation, between expected vs predicted value on test set
    :param list Y_pred: list of predicted values on test set
    :param list Y_test: list of expected values on test set
    :param int min_hist: minimun of abscissa for metric distribution histogram
    :param int max_hist: maximum of abscissa for metric distribution histogram
    :param int iter: plot regression over a certain number of iterations 
    :parm int kfold: plot regression over a certain number of k-fold for each iteration
    :param str save_distri: path to save metric distribution 
    :param std save_regression: path to save regression 
    """

    # Import style from pyterk
    mplstyle=config._pyterk_path('/pyterk.mplstyle')

    # Plot histogram
    with plt.style.context(mplstyle):
        plt.figure(figsize=(5,5)) 
        plt.title('Distribution of '+metric)
        plt.ylabel('Frequency')
        plt.xlabel(metric)
        ax = plt.gca()
        ax.set_xlim(min_hist,max_hist)
        plt.hist(val_metric,bins=10)
        plt.draw()
        plt.savefig(save_distri,dpi=300)
        plt.show()

    # Plot regression
    xy_max=0
    with plt.style.context(mplstyle):
        plt.figure(figsize=(8,6))
        plt.title('Predicted ' + output + ' vs Experimental ' + output)
        plt.ylabel('y_pred')
        plt.xlabel('y_test')
        for i in range(0,iter*kfold):
            xy_max = max( max(Y_pred[i]), Y_test[i].max(), xy_max )
            plt.plot(Y_test[i],Y_pred[i],linestyle='',marker='.', markersize=8, alpha=0.7)
    plt.plot([0,xy_max], [0,xy_max], '--', color='lightgray')
    plt.draw()
    plt.savefig(save_regression, dpi=300)
    plt.show()


  
    
