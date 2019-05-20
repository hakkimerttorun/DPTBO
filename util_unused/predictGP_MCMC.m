function [output_predictions,output_stdev,full_K] = predictGP_MCMC(samples,meanfunc,covfunc,likfunc,total_samples,total_targets,test_samples)
% load('GP_MI_MCMC_continue_V1_46.mat');

nsamples = size(samples,1);
D = size(total_samples,2);
pred_all = NaN(size(test_samples,1),nsamples);
var_all = NaN(size(test_samples,1),nsamples);
% full_K_temp = NaN(size(test_samples,1),size(test_samples,1),nsamples);
for a = 1:nsamples
   nMean = eval(feval(meanfunc{:}));

    x = samples(a,:);
    hyp.lik  = x(1);
    hyp.mean = x(2:2+nMean-1);
    hyp.cov  = x(2+nMean:end);
    if nargout < 2
        pred_all(:,a) = gp_call(hyp, @infGaussLik, meanfunc, covfunc, likfunc, total_samples, total_targets, test_samples);
    elseif nargout < 3
        [pred_all(:,a),var_all(:,a)] = gp_call(hyp, @infGaussLik, meanfunc, covfunc, likfunc, total_samples, total_targets, test_samples);
%         output_stdev = sqrt(s2);
    else
        [pred_all(:,a),var_all(:,a),final_lik] = gp_call(hyp, @infGaussLik, meanfunc, covfunc, likfunc, total_samples, total_targets, test_samples);
        hyp.lik = final_lik;
        kfcn_temp = @(XN,XM) feval(covfunc{:},hyp.cov,XN,XM);
        Kss = kfcn_temp(test_samples,test_samples)+exp(2*final_lik)*eye(size(test_samples,1));
        ks = kfcn_temp(test_samples,total_samples);
        k = kfcn_temp(total_samples,total_samples)+exp(2*final_lik)*eye(size(total_samples,1));
        full_K_temp(:,:,a) = Kss-(ks/k)*ks';
        full_K = mean(full_K_temp,3);

    end
end
output_predictions = mean(pred_all,2);
output_var = mean(var_all,2) + var(pred_all,[],2);
output_stdev = sqrt(output_var);
% output_stdev = std(pred_all,[],2);
end