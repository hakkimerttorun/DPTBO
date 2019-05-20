function [av_nll,hyp_samples_thinned] = trainGP_SLS(nll_func,hyp)
% n_lik = length(hyp.lik);
n_lik = 1;
n_mean = length(hyp.mean);
%FOR RL: 
% nCov = length(hyp.cov)-2;
nCov = length(hyp.cov);
bounds =...
    [ones(n_lik,2).*[-12 -2];
    ones(n_mean,2).*[-3 3];
    ones(nCov,2).*[-15 15]
    ];
%FOR GC
% bounds(4,:) = [-1,3];
% bounds(5,:) = [-5,-2];
%FOR RL
% bounds(4,:) = [0.5,3];
% bounds(5,:) = [-3,0];
%bounds(6,:) = [-15,15];
%bounds(7,:) = [-15,15];
%bounds(9,:) = [1,5];
%bounds(10,:) = [-3,0.5];
bounds = [bounds];
sls_opts = sls_opt;
sls_opts.nsamples = 150;
sls_opts.nomit = 100;
sls_opts.method = 'minmax';

sls_opts.display = 2;
sls_opts.wsize = 10;
sls_opts.plimit = 5;
sls_opts.unimodal = 0;
sls_opts.mmlimits = bounds';%[-13 -50 -9*ones(1,nMean-1) -5*ones(1,nCov); -8 -35 10*ones(1,nMean-1) 5*ones(1,nCov)];

sls_opts.maxiter = 150;
thinning = 1;
nLengthscales = 5;
n_lik = 1;
n_mean = 1;
nCov = length(hyp.cov);
m_lik = -7; var_lik = 3;
m_mean = 1; var_mean = 2;
m_ls_single = -1; var_ls_single = 4;
m_ls = -1*ones(nLengthscales,1); var_ls = 4*ones(nLengthscales,1); 
m_ss = [0]; var_ss = [4];
m_a1 = -1; var_a1 = 4;
m_a0 = 0; var_a0 = 4;
m_theta1 = 2; var_theta1 = 2;
m_theta3 = -2; var_theta3 = 3;
prior_mean = [m_lik; m_mean; m_ss; m_theta1; m_theta3; m_ss; m_ls_single; m_a1];
%FOR RL: prior_mean = [m_lik; m_mean;  m_ls_single; m_theta1; m_theta3; m_a0;m_ls_single; m_ss;1; 0; m_ls; m_ss];
prior_mean = -1*ones(size(bounds,1)-2,1)+1*rand(size(bounds,1)-2,1);
prior_mean = [m_lik;m_mean;prior_mean];
%FOR GC: prior_mean = [m_lik; m_mean; m_ls_single;   m_ss; m_ls; m_ss];


% prior_cov = [var_lik; var_mean; var_a0; var_theta1; var_theta3; var_ls_single; var_ss; var_ls_single; var_ss;  var_ls; var_ss].*eye(n_lik+n_mean+nCov-2);

% prior_mean = [m_lik; m_mean; m_ls_single; m_a1; m_a0; m_theta1; m_ls_single; m_ss; 2; -3];
% prior_cov = [var_lik; var_mean; var_ls_single; var_a1; var_a0; var_theta1; var_ls_single; var_ss; 2; 2].*eye(n_lik+n_mean+nCov-1);

%         prior_cov =  [var_lik; var_mean; var_ls; var_ss].*eye(n_lik+n_mean+nCov);%;var_ls;var_a1;var_a0].*eye(n_lik+n_mean+nCov);

% p_prior = mvnpdf(x',prior_mean,prior_cov);
% initial = mvnrnd(prior_mean,prior_cov,1000);
initial = prior_mean;%mean(initial);
% initial(4) = 1;
% initial = bounds(:,1)+(bounds(:,2)-bounds(:,1)).*rand(size(bounds,1),1);
% if(nargin > 2)
%     nLengthscales =  nCov-R;
%     initial(1) = -5; %noise
%     initial(2) = 0; %mean
%     initial(3:nLengthscales) = -1;
%     initial(nLengthscales+1:end-1) = 0;
%     initial(end) = 0;
% end

[hyp_samples, energies,~] = sls(nll_func, initial, sls_opts);

hyp_samples_thinned = hyp_samples(1:thinning:end,:);
energies_thinned = energies(1:thinning:end);
av_nll = mean(energies_thinned);

end