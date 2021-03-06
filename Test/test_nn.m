%% Test trained ADMM-net and compare with regular ADMM algorithm
% number of test pairs
iter = 500;
QUIET = 1;
PLOT = 0;
errN = zeros(iter, 1);
errL = zeros(iter, 1);
for i = 1:iter
    % generate test pair
    gen_signal;
    d.train = bb;
    d.label = x;
    
    % compute network output
    [loss, grad, x_hat, res] = loss_with_gradient_single( d, net1, m, n );
    
    % compute LASSO output
    [x_L, history, x_history] = lasso(A, bb, 1, 1, 1.0, 1.0, n, m, QUIET);
    
    % plots
    if PLOT == 1
        figure
        stem(x)
        title('True x') 
        figure
        stem(x_hat)
        title('ADMM-net x_{hat}')
        figure
        stem(x_L)
        title('ADMM x_{hat}')
    end

    % compute errors
    errN(i) = norm(x_hat - x)/norm(x);
    errL(i) = norm(x_L - x)/norm(x);
end
disp('ADMM-net')
disp(mean(errN))
disp('ADMM')
disp(mean(errL))