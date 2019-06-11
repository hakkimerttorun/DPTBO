%Copyright (c) 2019 Hakki M. Torun
%Expected improvement acquisition function
function EI = getEI(gp_output,sample_std,max_of_targets, EI_param)
    sigma1 = EI_param;
    Z1 = (gp_output - max_of_targets-sigma1)./(sample_std);
    EI = ((-max_of_targets+gp_output-sigma1).*normcdf(Z1) + (sample_std).*normpdf(Z1));
end