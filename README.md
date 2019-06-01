# High dimensional Bayesian Optimization with Deep Partitioning Tree (DPT-BO)

Copyright (c) 2019 Hakki M. Torun <br />
3D Packaging Research Center <br />
School of Electrical and Computer Engineering <br />
Georgia Institute of Technology <br />

The Matlab code associated with the paper ["High Dimensional Global Optimization Method for High-Frequency Electronic Design"](https://ieeexplore.ieee.org/document/8727492). A Python version is currently under development.

We propose a new high-dimensional Bayesian optimization (BO) method, Bayesian Optimization with Deep Partitioning Tree (DPT-BO), which uses an additive Gaussian Process (GP) to approximate the high-dimensional objective function. The additive structure we use preserve interaction between every parameter to capture various classes of functions that can be modelled. This makes the DPT-BO method particularly applicable to high-frequency electronic design problems since such interactions needs to be considered in high-frequency design problems.  

Preserving such interactions makes the auxiliary optimization of acquisition function in BO very challenging. Here, we propose a new hierarchical partitioning scheme, Deep Partitioning Tree, that completely eliminates this auxiliary optimization step and uses sensitivity of input parameters to determine where to query the function next. The sensitivities are learned on-the-fly by utilizing Automatic Relevance Determination (ARD) kernels for the GP.

This work is funded in part by the DARPA CHIPS project under award N00014-17-1-2950 and by ASCENT, one of six centers in JUMP, a Semiconductor Research Corporation (SRC) program sponsored by DARPA.

For questions, queries and bug reports, please feel free to contact: htorun3@gatech.edu

## Examples:
"DPTBO_main.m" function provides example usage of the method to maximize a black-box function. Please refer to the comment therein for details of the usage of the code. The actual implementation of the algorithm is "DPTBO.m" function.

## System Requirements:
The code is tested using Matlab R2018b and R2019a. 
