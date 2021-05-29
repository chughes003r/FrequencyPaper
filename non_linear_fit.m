function [mdl,f] = non_linear_fit(param, resps, fit)
    %may need to switch betas back
    wgt_func = 'ols'; %for some reason ols isn't working properly
    if strcmp(fit, 'power2')
        f = @(b,t) b(1)*t.^b(2)+b(3);
        %beta = [(max(resps)-min(resps)) 2 (min(resps))]; this was causing
        %issues
        beta = [0 0 0];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'power1')
        f = @(b,t) b(1)*t.^b(2);
        %beta = [(max(resps)-min(resps)) 2];
        beta = [0 0];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'asymp')
        f = @(b,t) b(1)+log(t)./(log(t+b(2)));
        %beta = [(max(resps)-min(resps)) 2];
        beta = [1 1];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'exp1')
        f = @(b,t) b(1)*exp(b(2)*t);
        beta = [(max(resps)-min(resps)) 2];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'exp2')
        f = @(b,t) b(1)*exp(b(2)*t)+b(3)*exp(b(4)*t);
        beta = [(max(resps)-min(resps)) 2 (max(resps)-min(resps)) 2];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'poly5')
        f = @(b,t) b(1)+b(2).*t+b(3).*t.^2+b(4).*t.^3+b(5).*t.^4+b(6).*t.^5;
        beta = [min(resps) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps))];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'poly4')
        f = @(b,t) b(1)+b(2).*t+b(3).*t.^2+b(4).*t.^3+b(5).*t.^4;
        beta = [min(resps) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps))];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'poly3')
        f = @(b,t) b(1)+b(2).*t+b(3).*t.^2+b(4).*t.^3;
        beta = [min(resps) (max(resps)-min(resps)) (max(resps)-min(resps)) (max(resps)-min(resps))];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'poly2')
        f = @(b,t) b(1)+b(2).*t+b(3).*t.^2;
        beta = [min(resps) (max(resps)-min(resps)) (max(resps)-min(resps))];
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    elseif strcmp(fit, 'poly1')
        f = @(b,t) b(1)+b(2).*t;
        beta = [min(resps) (max(resps)-min(resps))];            
        opts = statset('nlinfit');
        opts.RobustWgtFun = wgt_func;
        if strcmp(wgt_func, 'ols')
            mdl = fitnlm(param, resps, f, beta);
        else
            mdl = fitnlm(param, resps, f, beta, 'Options', opts);
        end
    end
end

