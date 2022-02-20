Experiments Plannification
==========================

.. toctree::
   :maxdepth: 4

Principle
----------

A Matlab GUI interface was developed in order to automatically generate a set of experiments to screen a N-element composition space using a combinatorial approach and a 2- to 3-cathodes magnetron sputtering. The starting point of this method is based on simplex centroid mixture design, in order to screen the space as uniformly as possible. From the composition points given by the mixture design, all linear/planar gradients passing by 3/7 of them are computed. Then a set of gradients/planes is chosen in order to pass at least once by each point and to respect the user inputs. The choice is done with a random exploration of all possible gradients, that starts all over again if the set does not meet the requirements. 

**Features** :
   * Adaptability to the user’s needs
      * The user enters the elements of the composition space they want to explore (from 3 to 7 elements).
      * Chooses if they are using two or three cathodes
      * Indicates if they want to preferentially explore some point of the mixture design.
   * Representation of the composition space and of the gradients/planes that are explored. 
   * Give the list of targets that allow to perform the experiments

.. image:: ../../ExperimentsPlannification/Supplementary_Matlab_interface.png
  :width: 700
  

Modules
--------

.. mat:automodule:: modules
.. mat:autofunction:: check_do_not_align

.. mat:automodule:: modules
.. mat:autofunction:: check_not_repeat

.. mat:automodule:: modules
.. mat:autofunction:: check_repeat_only

.. mat:automodule:: modules
.. mat:autofunction:: compute_alignments

.. mat:automodule:: modules
.. mat:autofunction:: compute_planes

.. mat:automodule:: modules
.. mat:autofunction:: coordinates_name_centroid_points

.. mat:automodule:: modules
.. mat:autofunction:: count_occur

.. mat:automodule:: modules
.. mat:autofunction:: fix_nb_repetition

.. mat:automodule:: modules
.. mat:autofunction:: get_elements

.. mat:automodule:: modules
.. mat:autofunction:: gradients_set

.. mat:automodule:: modules
.. mat:autofunction:: index_alignments

.. mat:automodule:: modules
.. mat:autofunction:: kill_program

.. mat:automodule:: modules
.. mat:autofunction:: lineIntersect3D

.. mat:automodule:: modules
.. mat:autofunction:: listing_targets

.. mat:automodule:: modules
.. mat:autofunction:: listing_targets_3cath

.. mat:automodule:: modules
.. mat:autofunction:: plot_compo_space_gradients

.. mat:automodule:: modules
.. mat:autofunction:: plot_compo_space_planes

.. mat:automodule:: modules
.. mat:autofunction:: parameters_file

.. mat:automodule:: modules
.. mat:autofunction:: planes_set
   
.. mat:automodule:: modules
.. mat:autofunction:: price_calculation

.. mat:automodule:: modules
.. mat:autofunction:: vector_coeff













