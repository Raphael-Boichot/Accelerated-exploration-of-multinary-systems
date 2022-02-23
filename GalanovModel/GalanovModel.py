# -*- coding: utf-8 -*-
"""
Galanov model
==============

This code allows to compute elastic-plastic zone :math:`\\frac{b_s}{c}`, the constrain factor :math:`C` and ductility characteristic :math:`\delta_H` by solving equations proposed by Galanov *et al* (Galanov, Ivanov, et Kartuzov, *Improved Core Model of the Indentation for the Experimental Determination of Mechanical Properties of Elastic-Plastic Materials and Its Application*.)

Model summary
--------------
Scheme of the interaction of a conical indenter and a sample under load P

.. image:: ../../GalanovModel/Schema.png
  :width: 500

We know:
    - :math:`E_S` : elastic modulus of the sample
    - :math:`\\nu_S` : Poisson coefficient of the sample
    - :math:`E_i` : elastic modulus of indenter
    - :math:`\\nu_i` : Poisson coefficient of indenter
    - :math:`H` : hardness of the sample
    - :math:`\\cot \\gamma_i=\sqrt[4]{\\frac{\pi^{2}}{27}} \cot \gamma_{B}` with :math:`\gamma_{B}=65°` for Brkovitch indenter
From:

.. math::  

    E_{i}^{*}=\\frac{E_i}{1-\\nu_i**2}

    Ks=\\frac{E_s}{3(1-2\\nu_s)}

We define: 

.. math::  

    \\begin{aligned}
        \\alpha_S & = \\frac{2(1-2\\nu_s}{3(1-\\nu_S)} \\

        \\beta_{S} & = \\frac{E_{S}}{6\left(1-\\nu_{S}\\right) H} \\

        \\theta_{S} & = \\frac{H}{K_{S}} \\
    \\end{aligned}

    
and dimensionless unknowns

.. math:: 

    \\begin{aligned}
        x&=\\frac{b_{S}}{c}\\

        y&=\\frac{Y_{S}}{H M}\\

        z&=\\cot \\psi\\
    \\end{aligned}


The system to solve is then:

.. math::

    \\left\{\\begin{array}{l}
        z=\\cot \\gamma_{i}-\\frac{2 H M}{E_{i}^{*}} \\

      \\left(1-\\theta_{S}(1-2 y \ln x)\\right)\\left(x^{3}-\\alpha_{S}\\right)=\\frac{\\beta_{S} z}{y} \\

        1=y\\left(\\frac{2}{3}+\\frac{y\left(x^{3}-\\alpha_{S}\\right)}{\\beta_{S}} \\ln \\left[1-\\frac{y\\left(x^{3}-\\alpha_{S}\\right)}{2 \\beta_{S}}\\right]^{-1}+2 \\ln x\\right)
    \\end{array}\\right.

were :math:`z` is completely known.
Moreover, :math:`C=\\frac{1}{y}` 
"""

import pandas as pd
import numpy as np
import os as os
import math

global nu_i
global alpha_s
global beta_s
global theta_s
global H_s_Ei_star
global z


def Galanov_math_values (E_s,nu_s,E_i,nu_i,H_s):
    """
        Compute the known values in Galanov models from machanical properties of sample and indenter

        :param float E_s: elastic modulus of sample
        :param float nu_s: Poisson coefficient of sample
        :param float E_i: elastic modulus of indenter
        :param float nu_i: Poisson coefficient of indenter
        :param float H_s: Hardness of the sample
        :return: - Ei_star
                 - Ks
                 - alpha_s
                 - beta_s
                 - cot_gamma_i,z
                 - theta_s
        :rtype: float
    """

    Ei_star=E_i/(1-nu_i**2)
    Ks=E_s/(3*(1-2*nu_s))
    alpha_s=2*(1-2*nu_s)/(3*(1-nu_s))
    beta_s=E_s/(6*(1-nu_s)*H_s)
    cot_gamma_i=(np.pi**2/27)**(1/4)*1/math.tan(65/180*np.pi)
    theta_s=H_s/Ks
    H_s_Ei_star=H_s/Ei_star
    z=(cot_gamma_i-2*H_s_Ei_star)

    return Ei_star,Ks,alpha_s,beta_s,theta_s,cot_gamma_i,z


def system_x_y (p,*args):
    """
    Solve Galanov sytem

    :param tuple p: tuple of values of x and y
    :param tuple args: contains alpha_s,beta_s,theta_s,z
    :return: result of equation 1 and 2 with x and y values
    """

    (x,y)=p
    #print(args)
    (alpha_s,beta_s,theta_s,z)=args

    eq1=(1-theta_s*(1-2*y*np.log(x)))*(x**3-alpha_s)-beta_s*z/y
    
    eq2=1/y-(2/3+y*(x**3-alpha_s)/beta_s*np.log((1-y*(x**3-alpha_s)/(2*beta_s))**(-1))+2*np.log(x))
    

    return [eq1, eq2]


def delta_H_value (E_s,H_s,nu_s,z):
    """
    Compute ductility characteristics

    :param float E_s: elastic modulus of sample
    :param float nu_s: Poisson coefficient of sample
    :param float H_s: Hardness of the sample
    :param float z: Galanov unknown 
    :return: delta_H the ductility characteristics
    :rtype: float between 0 and 1
    """
    eps_p=-np.log(np.sqrt(1+ z**2))
    eps_l=-(1+nu_s)*(1-2*nu_s)*H_s/E_s
    delta_H=eps_p/(eps_p+eps_l)

    return delta_H


   