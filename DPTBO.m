% Copyright (c) 2019 Hakki Mert Torun
% School of Electrical and Computer Engineering
% 3D Packaging Research Center (PRC)
% Georgia Institute of Technology

% Main code for DPT-BO.
% For questions and queries, please contact: htorun3@gatech.edu

%Please cite our paper if you use any part of the code:
%H. M. Torun and M. Swaminathan,
%"High Dimensional Global Optimization Method for High-Frequency Electronic Design"
%in IEEE Transactions on Microwave Theory and Techniques, vol. 66, no. 6, June 2019.
function results = DPTBO(f, settings)
% Fix Random Stream for Reproducability
if ~(isfield(settings,'random_stream'))
    settings.random_stream = 0;
end

if (settings.random_stream)
    s = RandStream('mt19937ar','Seed', 0);
    RandStream.setGlobalStream(s);
end
if ~(isfield(settings,'sample_space'))
    error('You must specify the sample space!')
    return;
end

sample_space = settings.sample_space;
dimension = size(sample_space,1);

if ~(isfield(settings,'initialSamples'))
    settings.initSamples = ((sample_space(:,1) + sample_space(:,2))./2)';
    if  (isfield(settings,'initialTargets'))
        settings.initTargets = initTargets;
    else
        settings.initTargets = [];
    end
end
if ~(isfield(settings,'count_max'))
    settings.count_max = 150;
end
if ~(isfield(settings,'training_num_random_restarts'))
    settings.training_num_random_restarts = 1;
end
if ~(isfield(settings,'hyperUpdateTime'))
    settings.hyperUpdateTime = 1:1:settings.count_max;
end
if ~(isfield(settings,'UCB_param'))
    settings.UCB_param = 0.05;
end
if ~(isfield(settings,'EI_param'))
    settings.EI_param = 0.1;
end
if ~(isfield(settings,'PI_param'))
    settings.PI_param = 0.01;
end
if ~(isfield(settings,'group_length'))
    group_length = auto_gen_groups(dimension);
    warning_text = sprintf(['It is highly encouraged that you select the number of groups (M)\n', ...
        'and number of parameters (d) in each group.\nDo you want to', ...
        'continue with automatically generated d = %d, M = %d? (Y/N)\n'], max(group_length),length(group_length));
%     warning(warning_text)
    input_check = false;
    while ~input_check
        str = input(warning_text,'s');
        if strcmpi(str,'N')
            results = [];
            return
        elseif strcmpi(str,'Y')
            fprintf('*********Continuing with the automatically generated groups...*********\n');
            input_check = true;
        else
            frpintf('Invalid input. Do you want to continue? (Y/N)');
        end
    end
end

UCB_param = settings.UCB_param;
EI_param = settings.EI_param;
PI_param = settings.PI_param;

ntrials = settings.training_num_random_restarts;
hyperUpdateTime = settings.hyperUpdateTime;
group_length = settings.group_length;
total_samples = settings.initSamples;
total_targets = settings.initTargets;
count_max = settings.count_max;
%%
D = dimension;

% max_split_size = min(10,dimension);
% regions_total = splitregion_selected(sample_space,1:1:max_split_size);

if (isempty(total_targets))
    for i = 1:size(total_samples,1)
        total_targets = [total_targets;f(total_samples(i,:))];
    end
end

max_depth = count_max;
t = cell(max_depth,1);
for a = 1:max_depth
    t{a}.regions = [];
end
%% INITIALIZATIONS
best_parameters = [];
best_targets =[];
count = 0;
t{1,1}.regions = sample_space;

max_of_targets = max(total_targets);


R = min(2,D-1);
seU = {'covSEisoU'};
maternU = {'covMaternisoU',5};
matern = {'covMaternard',5};
se = {'covSEard'};
covdd = {'covADD',{1:R,maternU}};
covfunc = {'covSum',{matern,covdd}};

nCov = eval(feval(covfunc{:}))-D;
%Initialize hyperparameters. It can be if needed for specific application.
hyp.mean = 0;
hyp.lik = -3;
input_spread = (sample_space(:,2)-sample_space(:,1))./sqrt(12);
hyp.cov = [log(input_spread); zeros(R+1,1)];



%% OPTIMIZATION START
tic
while (count <= count_max)
    count = count + 1;
    %% Train GP Model
    likfunc = @likGauss;  % likelihood function
    meanfunc = {'meanConst'}; %  mean function
    covfunc = {'covSum',{matern,covdd}};
    
    D = size(total_samples,2);
    nCov = eval(feval(covfunc{:}))-D;
    emp_mean = mean(total_targets);
    
    % Traditionally, training of GPs are done using unconstrained
    % optimization. However, constrained optimization can significantly
    % speed-up training time. One can consider the following bounds as
    % "hyperpriors" defined as box constraints.

    hyper_limits =...
        [-10 -1*abs(emp_mean) -10*ones(1,nCov);
        -1 1*abs(emp_mean) 10*ones(1,nCov)];
    
    nll_func_train = @(x) nll_func(x,hyp,meanfunc,covfunc,likfunc,total_samples,total_targets);
    initial = [hyp.lik;hyp.mean;hyp.cov];
    if(count > 1)
        initial = [std(total_samples)'; ones(R+1,1).*std(total_targets)/sqrt(2)];
        initial = [-3;0;log(initial)];
    end
    
    if(max(count == hyperUpdateTime))
        options = optimoptions('fmincon','SpecifyObjectiveGradient',true,'Display','none',...,
            'OptimalityTolerance',1e-3);
        x0 = initial;
        % You can change "ntrials" to train the GP model with random
        % restarts and pick hyperparameters that provide best likelihood.
        temp_hyps = [];
        temp_nlls = [];
        for tt = 1:ntrials
            fprintf('Finding hyperparameters of the GP: Trial (%d/%d) ...\n', tt, ntrials)
            [x,fval] = fmincon(nll_func_train,x0,[],[],[],[],hyper_limits(1,:)',hyper_limits(2,:)',[],options);
            temp_hyps = [temp_hyps,x];
            temp_nlls = [temp_nlls,fval];
            x0 = hyper_limits(1,:)'+(hyper_limits(2,:)'-hyper_limits(1,:)').*rand(length(initial),1);
        end
        [~,sel_trial] = min(temp_nlls);
        x = temp_hyps(:,sel_trial);
        hyp2.lik = x(1);
        hyp2.mean = x(2);
        hyp_cov = x(3:end);
        hyp2.cov = [hyp_cov(1:D+1);hyp_cov(1:D);hyp_cov(D+2:end)];
    end
    %% ARRANGE GROUPS BASED ON SENSITIVITY
    % Use lengthscale parameter to determine the sensitivity & arrange
    % groups of parameters to be used for Deep Partitioning Tree. (Eq. 17 in
    % paper)
    numGroups = size(group_length,2);
    lengthscales = exp(hyp2.cov(1:D));
    dim_weights = 1./lengthscales;
    groups = cell(numGroups,1);
    allDims = 1:1:D;
    [~,sort_index] = sort(dim_weights,'descend');
    for a = 1:numGroups
        numDims = group_length(a);
        groups{a} = sort(allDims(sort_index(a*numDims-numDims+1:a*numDims)),'ascend');
    end
    %% DEEP PARTITIONING TREE
    %VERTICAL EXPANSION TO SELECT INITIAL REGION FROM ALL PREVIOUS REGIONS
    current_all_regions = t{count,1}.regions;
    test_x_all = squeeze(((current_all_regions(:,1,:)+current_all_regions(:,2,:))/2))';
    
    [gp_output,sample_var] = gp_call(hyp2,@infGaussLik,meanfunc,covfunc,likfunc,total_samples,total_targets,test_x_all);
    sample_std = sqrt(sample_var);
    %Select Acquisition function (PI, UCB, EI) sequentially
    if(rem(count,3) == 2)
        acq_values = getUCB(gp_output,sample_std,count,UCB_param);
    elseif (rem(count,3) == 0)
        acq_values = getEI(gp_output,sample_std,max_of_targets, EI_param);
    else
        acq_values = getPI(gp_output,sample_std,max_of_targets, PI_param);
    end
    %Select the most promising, large region
    [~,temp_reg_index_prev] = max(acq_values);
    current_regions = current_all_regions(:,:,temp_reg_index_prev);
    reg2keep = current_all_regions;
    reg2keep(:,:,temp_reg_index_prev) = [];
    
    %HORIZONTAL EXPANSION TO SEARCH WITHIN SELECTED REGIONS
    lateral_tree = {};
    lateral_acq = NaN(numGroups,D+1);
    for a = 1:numGroups
        current_regions = splitregion_selected(current_regions,groups{a});
        
        test_x_temp = squeeze(((current_regions(:,1,:)+current_regions(:,2,:))/2))';
        [gp_output,sample_var] = gp_call(hyp2,@infGaussLik,meanfunc,covfunc,likfunc,total_samples,total_targets,test_x_temp);
        sample_std = sqrt(sample_var);
        if(rem(count,3) == 2)
            acq_values = getUCB(gp_output,sample_std,count,UCB_param);
        elseif (rem(count,3) == 0)
            acq_values = getEI(gp_output,sample_std,max_of_targets, EI_param);
        else
            acq_values = getPI(gp_output,sample_std,max_of_targets, PI_param);
        end
        [max_acq_temp,temp_reg_index] = max(acq_values);
        lateral_acq(a,:) = [max_acq_temp,test_x_temp(temp_reg_index,:)];
        if(a == numGroups)
            [max_acq,new_sample_idx] = max(lateral_acq(:,1));
            sample_new = lateral_acq(new_sample_idx,2:end);
        end
        temp_regs{a,1} = current_regions;
        temp_regs{a,1}(:,:,temp_reg_index) = [];
        current_regions = current_regions(:,:,temp_reg_index);
    end
    
    for a = 1:numGroups
        regnew{a} = splitregion_selected(current_regions,groups{a});
    end
    
    % ADD ALL REGIONS GENERATED BY VERTICAL & HORIZONTAL REGIONS TO ALL
    % PREVIOUS REGIONS
    t{count+1,1}.regions = cat(3,reg2keep,temp_regs{:},regnew{:});
    [n,m,p]=size(t{count+1,1}.regions);
    a=reshape(t{count+1,1}.regions,n,[],1);
    b=reshape(a(:),n*m,[])';
    c=unique(b,'rows','stable')';
    t{count+1,1}.regions = reshape(c,n,m,[]);
    
    %FOR DEBUGGING, YOU CAN COMMENT THE NEXT LINE. THIS CLEARS PREVIOUSLY
    %GENERATED REGIONS TO SAVE MEMORY
    
    t{count,1} = [];
    
    % FUNCTION QUERY
    sample_new_to_f = sample_new;
    target_new = f(sample_new_to_f);
    
    total_samples = [total_samples;sample_new];
    total_targets = [total_targets;target_new];
    
    [max_of_targets,best_sample_index] = max(total_targets);
    best_sample = total_samples(best_sample_index,:);
    
    elapsed_time = toc;
    fprintf('Iteration: %d, Current Best: %0.4f, Current Target: %0.4f, Elapsed Time: %0.3f min\n',count, max_of_targets, target_new, elapsed_time/60);
    
    best_targets = [max_of_targets;best_targets];
    best_parameters = [best_sample;best_parameters];
    
    if(count == count_max)
        elapsed_time = toc;
        results.total_samples = total_samples;
        results.total_targets = total_targets;
        results.best_samples = best_parameters;
        results.best_targets = best_targets;
        %SENSITIVITY OF PARAMETERS AS BY-PRODUCT OF OPTIMIZATION. NOTE THAT
        %AS THIS IS NOT THE MAIN GOAL, THE ACCURACY OF SENSITIVITY MIGHT
        %NOT BE VERY HIGH.
        results.sensitivities = 100*dim_weights./sum(dim_weights);
        results.elapsed_time = elapsed_time;
        fprintf('**********\nOptimization Finished at %d function queries in %0.3f minutes: \n',...
            count_max, elapsed_time/60);
        fprintf('Best Value found: %0.5f\n**********\n',best_targets(1));
        break;
    end
end

end
function [nll,dnll] = nll_func(x,hyp,meanfunc,covfunc,likfunc,total_samples,total_targets)
D = size(total_samples,2);
nLik = length(hyp.lik);
nMean = length(hyp.mean);
xnew = [x(1:nLik+nMean+D+1);x(nLik+nMean+1:nLik+nMean+D);x(nLik+nMean+D+2:end)]; %nLik + nMean + (D+1)+D*1+R
hyp.lik = xnew(1:nLik);
hyp.mean = xnew(nLik+1:nLik + nMean);
hyp.cov = xnew(nLik + nMean + 1:end);
if (nargout > 1)
    [nll,dnll_temp] = gp_call(hyp,@infGaussLik,meanfunc,covfunc,likfunc,total_samples,total_targets);
    dnll_temp_cov = dnll_temp.cov;
    dnll_cov = [dnll_temp_cov(1:D+1);dnll_temp_cov(D+1+D+1:end)];
    dnll = [dnll_temp.lik;dnll_temp.mean; dnll_cov];
else
    nll = gp_call(hyp,@infGaussLik,meanfunc,covfunc,likfunc,total_samples,total_targets);
end
end