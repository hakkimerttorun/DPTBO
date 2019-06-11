% Copyright (c) 2019 Hakki Mert Torun
% School of Electrical and Computer Engineering
% 3D Packaging Research Center (PRC)
% Georgia Institute of Technology


%High Dimensional Bayesian Optimization with Deep Partitioning Tree
%(DPT-BO) for maximizing a black-box objective function.
%If you want minimization, multiply objective function by "-1".

%This work is funded in part by the DARPA CHIPS project under
%Award N00014-17-1-2950 and by ASCENT, one of six centers in JUMP, a
%Semiconductor Research Corporation (SRC) program sponsored by DARPA
%For questions and queries, please contact: htorun3@gatech.edu

%Please cite our paper if you use any part of the code:
%H. M. Torun and M. Swaminathan,
%"High Dimensional Global Optimization Method for High-Frequency Electronic Design"
%in IEEE Transactions on Microwave Theory and Techniques, vol. 66, no. 6, June 2019.

clear all
close all
clc

addpath(genpath('util/'));
addpath(genpath('gpml-matlab-v4.1-2017-10-19/'));
addpath(genpath('test_function'));
%% Function Pointer List

Hart6 = @(value) -1*hart6f(value);
Schwef = @(value) -1*schwef(value);
qinq = @(value) -1*qingfcn(value);
Levy = @(value) -1*levy(value);
Michalewicz = @(value) -1*michal(value,10);

%% Select the function to Maximize, specify sample space, dimensionality and groups.
% Here, "group_length" specifies how many groups and number of parameters in each group. For instance,
% group_length = [7,7,5] means there are 3 groups (M = 3 in the paper) and 
% 1st & 2nd groups contain 7 most influential parameters (learned during
% optimization) and 3rd group contain the least effective 5 parameters

% f = Hart6; dimension=6; sample_space = [0 1; 0 1; 0 1; 0 1; 0 1; 0 1]; group_length = [3,3];
% f = qinq; dimension=25; sample_space = ones(dimension,2).*[0,10]; group_length = [5,5,5,5,5];
% f = Levy; dimension=15; sample_space = ones(dimension,2).*[-15 1]; group_length = [5, 5, 5];
% f = Schwef; dimension=10; sample_space = ones(dimension,2).*[300 500]; group_length = [5,5];
f = Michalewicz; dimension = 10; sample_space = ones(dimension,2).*[0 pi]; group_length = [7,3];
%%
%% Settings
% !!!HYPERPARAMETER UPDATE SCHEDULING!!!
% Hyperparameter update (Training the Additive GP) is the most CPU
% intensive part of the method. We HIGHLY RECOMMEND using the default setting,
% however, you can significantly reduce CPU time by using a "logspace"
% scheduling by uncommenting below. 

settings.count_max = 150;
settings.hyperUpdateTime = 1:1:settings.count_max;
% settings.hyperUpdateTime = [1,2,3,4,5,floor(logspace(1,5))];

%RANDOM STREAM FOR REPRODUCIBILITY
%This shouldn't change the optimization. Only randomness is for
%hyperparameter optimization.
settings.random_stream = 0; %set to 1 to fix random stream. Set to "0" in general.


% You can start from a checkpoint by loading samples and targets from
% previous iterations. Alternatively, if you have any prior data of the
% objective function, load it here for a "warm start".
% Set "settings.total_samples" and "settings.total_targets" to do this.
% Targets are optional, and if they are not provided,
% points in "total_samples" will be treated as initial points that will
% be simulated BEFORE the optimization starts.

%If you don't provide initial point, the 'mid-point' of the sample space
%will be used as initial.

%settings.total_targets = [];
%settings.total_samples = [];

settings.sample_space = sample_space;
settings.training_num_random_restarts = 1;
settings.group_length = group_length;
settings.UCB_param = 0.05;
settings.EI_param = 0.1;
settings.PI_param = 0.1;

results = DPTBO(f, settings);


