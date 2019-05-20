
function [nll,dnll] = getNLLwrapper(x,hyp_in,inf,mean,cov,lik,x_samples,y_samples)

% n_lik = length(hyp_in.lik);
n_mean = length(hyp_in.mean);
n_lik = 1;

% n_cov = length(hyp_in.cov);
% n_lik = 1;
hyp.lik = x(n_lik);
% hyp.lik = -10;
hyp.mean = x(n_lik+1:n_lik+1+n_mean-1);
hyp.cov = x(n_lik+1+n_mean:end)';

if (nargout > 1)
    [nll,dnll] = gp_call(hyp,inf,mean,cov,lik,x_samples,y_samples);
else
    [nll] = gp_call(hyp,inf,mean,cov,lik,x_samples,y_samples);
%     nll = nll;
end


end