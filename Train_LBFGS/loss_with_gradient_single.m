function [ loss, grad, x_hat, res ] = loss_with_gradient_single( data, net, m, nn )
%% Compute the loss and the gradient of a single sample.


% training sample
y = data.train;
% training label
label = data.label;
% A matrix
% A = gen_A(m,m+nn);
% Rho
% Rho = 1.0;



% N = total number of layers
N = numel(net.layers);

% struct to store layer outputs
% res(n) contains the outputs of layer n
res = struct(...
    'x',cell(1,N+1),...
    'dzdx',cell(1,N+1),...
    'dzdw',cell(1,N+1));

% Initialize u and z
u_init = zeros(size(label));
z_init = zeros(size(label));

%% The forward propagation
for n = 1:N
    % The current layer
    l = net.layers{n};
    switch l.type
        case 'X_org'
            res(n).x = xorg (m, nn, y , z_init, u_init, l.weights);
        case 'Non_linorg'
            res(n).x = zorg(m, nn, res(n-1).x , u_init , l.weights{1});
        case 'Multi_org'
            res(n).x = betaorg(m, nn, res(n-1).x , res(n-2).x , u_init);
        case 'X_mid'
            res(n).x = xmid( m, nn, y, res(n-2).x , res(n-1).x, l.weights);
        case 'Non_linmid'
            res(n).x = zmid(m, nn, res(n-1).x , res(n-2).x , l.weights{1} );
        case 'Multi_mid'
            res(n).x = betamid(m, nn, res(n-1).x , res(n-2).x , res(n-3).x);
        case 'Multi_final'
            res(n).x = betafinal(m, nn, res(n-1).x , res(n-2).x , res(n-3).x);
        case 'Nonlin_final'
            % res(n).x = xmid( Atb, y, Rho, res(n-2).x , res(n-1).x, l.weights);
            res(n).x = zmid(m, nn, res(n-1).x , res(n-2).x , l.weights{1} );
        case 'loss'
            res(n).x = rnnloss(res(n-1).x, label);
        otherwise
            error('No such layers type.');
    end
    
end
if nargout == 1
    loss = res(N).x;
    
elseif nargout == 4
    loss = res(N).x;
    x_hat = res(N-1).x;
    grad = 0; % assign value so that MATLAB does not complain
    
    
%% The backward propagation
elseif nargout == 2
    res(end).dzdx{1} = 1;
    L = net.layers;
    for n = N:-1:1;
        switch L{n}.type
            case 'X_org'
                [res(n).dzdx{1}, res(n).dzdw{1}]  = ...
                    xorg (m, nn, y , u_init, res(n).x , ...
                          L{n+1}.weights{1}, z_init, res(n+1).dzdx{1},...
                          res(n+2).dzdx{1});
            case 'Non_linorg'
                [res(n).dzdx{1}, res(n).dzdw{1}] = ...
                    zorg(m, nn, res(2).x , u_init , L{n}.weights{1} ,...
                         res(n+1).dzdx{1}, res(n+2).dzdx{1}, ...
                         L{n+2}.weights{2});   %%%%%%%%%%
            case 'Multi_org'
                res(n).dzdx{1} = ...
                    betaorg(m, nn, 0, res(n+1).x , res(n).x , ...
                            L{n-1}.weights{1}, res(n+1).dzdx{1}, ...
                            res(n+2).dzdx{1}, res(n+3).dzdx{1}, ...
                            L{n+1}.weights{2});
            case 'Multi_mid'
                res(n).dzdx{1} = ...
                    betamid(m, nn, res(n-3).x , res(n+1).x , res(n).x , ...
                            L{n-1}.weights{1}, res(n+1).dzdx{1}, ...
                            res(n+2).dzdx{1}, res(n+3).dzdx{1}, ...
                            L{n+1}.weights{2});
            case 'Non_linmid'
                [res(n).dzdx{1}, res(n).dzdw{1}] = ...
                    zmid(m, nn, res(n-1).x , res(n-2).x , L{n}.weights{1}, ...
                         L{n+2}.weights{2}, res(n+1).dzdx{1}, ...
                         res(n+2).dzdx{1} );
            case 'X_mid'
                [res(n).dzdx{1}, res(n).dzdw{1}] = ...
                    xmid( m, nn, y, res(n-1).x , res(n).x ,  ...
                          L{n+1}.weights{1},  res(n+1).dzdx{1}, ...
                          res(n+2).dzdx{1}, res(n-2).x );
            case 'Multi_final'
                res(n).dzdx{1} = ...
                    betafinal(m, nn, res(n-3).x , res(n+1).x , res(n).x , res(n+1).dzdx{1}, L{n+1}.weights{2});
            case 'Nonlin_final'
                [res(n).dzdx{1}, res(n).dzdw{1}] = ...
                    zfinal(m, nn, res(n-1).x , res(n-2).x , ...
                           L{n}.weights{1} , res(n+1).dzdx{1});
                    % xfinal( A, y, Rho, res(n-1).x , res(n).x ,  res(n+1).dzdx{1}, res(n-2).x)
            case 'loss'
                res(n).dzdx{1} = ...
                    rnnloss(res(n-1).x, label, res(n+1).dzdx{1});
            otherwise
                error('No such layers type.');
        end
    end
    
    % Store loss
    loss = res(N).x;
    
    % Store gradient
    grad = [];
    for n = 1:N
        if isfield(res(n), 'dzdw')
            for i = 1:length(res(n).dzdw)
                gradwei = res(n).dzdw{i};
                grad = [grad;gradwei(:)];
            end
        end
    end
else
    error('Invalid output numbers.\n');
end
end