function [nll,dll,final_lik] = gp_call(hyp2, infFunc, meanfunc, covfunc, likfunc, total_samples, total_targets,allCombinations)
done = false;
while (~done)
    try
        if (nargin > 7)
            [nll,dll] = gp(hyp2, infFunc, meanfunc, covfunc, likfunc, total_samples, total_targets,allCombinations);
            final_lik = hyp2.lik;
        else
            if(nargout == 2)
                [nll,dll] = gp(hyp2, infFunc, meanfunc, covfunc, likfunc, total_samples, total_targets);
            else
                nll = gp(hyp2, infFunc, meanfunc, covfunc, likfunc, total_samples, total_targets);
                final_lik = [];
            end
        end
        done = true;
        
    catch
        if(hyp2.lik < -15)
            hyp2.lik = -15;
        elseif hyp2.lik > 5
            hyp2.lik = 0;
        else
            hyp2.lik = hyp2.lik + 1;
        end
        done = false;
    end
    
    
    
    
end
