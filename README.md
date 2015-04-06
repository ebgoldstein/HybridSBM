This is a Matlab rewrite of the Sorted Bedform code, initially written in
'C' by Giovanni Coco and A. Brad Murray. The code has been modfied and rewritten to accomodate
machine learnign based predictors (a 'hybrid' model).

the model was used in the paper:
Goldstein, E. B., G. Coco, A.B. Murray, and M.O. Green, (2014), 
Data driven components in a model of inner shelf sorted bedforms: a new hybrid model, 
Earth Surface Dynamics, 2, 67-82
available online (open access): http://www.earth-surf-dynam.net/2/67/2014/esurf-2-67-2014.html

SBM.m is the main script for running the model, all
other functions and model subroutines are incorporated below.

The code saves the entire structure that houses the model data and assumes you have the parallel package for matlab.
Some of the features of teh original code are not implemented

Written by EBG 2/12


Copyright EBG: 
Creative Commons 
Attribution-NonCommercial-ShareAlike 
3.0 Unported
