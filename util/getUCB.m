%Copyright (c) 2019 Hakki M. Torun
%Upper confidence bound acquisition function
function UCB = getUCB(gp_output,sample_std,M, UCB_param)
    nu = UCB_param;
    GP_varsigma = @(M) sqrt(2*log(pi^2*(M)^2/(12*nu))); 
    UCB = (gp_output + GP_varsigma(M)*(sample_std));
end