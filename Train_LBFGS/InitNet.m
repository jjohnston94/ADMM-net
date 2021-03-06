function net = InitNet(flag)
%% Network initialization
%% We initialize the network parameters according to the ADMM algorithm optimizing the baseline CS-MRI model.

% %% network setting
config;

m = nnconfig.ImageSize;
n= nnconfig.PartitionSize;

% get A matrix of size m by m+n
% A = gen_A(m, m+n);
if flag == 1
    A = gen_A(m,n+m);
    % A = [real(A), -imag(A); imag(A), real(A)];
    m = size(A,1);
    n = size(A,2) - m;
    
%     nnconfig.ImageSize = size(A,1);
%     nnconfig.PartitionSize = size(A,2) - nnconfig.ImageSize;
    
%     % % data vector length
%     m = nnconfig.ImageSize;
% 
%     % number of grid points
%     n = nnconfig.PartitionSize;

    % cache LU factorization of A
    Rho = 1;
    [L, U] = factor(A, Rho);
%     nnconfig.L = L;
%     nnconfig.U = U;

    % cache for later use
    % nnconfig.AULA = (A'*(U \ ( L \ (A) )));
    AULA = (A'*(U \ ( L \ (A) )));

    % initialize l1-penalty parameters
    lambda1 = 0.5;
    lambda2 = 0.5;
    % store in vector
    lambda = [lambda1; lambda2];

    % initialize M1 and M2
    M1 = (1/Rho)*A' - (1/Rho^2)*AULA*A';
    M2 = (eye(m+n) - (1/Rho)*AULA);
    M1 = reshape(M1, [numel(M1),1]);
    M2 = reshape(M2, [numel(M2),1]);
end
if flag == 0
    m = nnconfig.ImageSize;
    n = nnconfig.PartitionSize;
    % placeholders
    M1 = zeros(m*(m+n),1);
    M2 = zeros((m+n)*(m+n),1);
    lambda = zeros(2,1);
end

%% Network structure
% The following defines each layer of the network.

% Number of stages. Each stage has 3 layers, which together execute one iteration
% of ADMM
stageN = nnconfig.Stage;

net.layers = {};

%the first stage
net.layers{end+1} = struct('type','X_org', 'weights', {{M1, M2}});
net.layers{end+1} = struct('type', 'Non_linorg', 'weights',{{lambda}});
net.layers{end+1} = struct('type', 'Multi_org');

%the middle stages
for i = 1:1:stageN-2
    net.layers{end+1} = struct('type', 'X_mid', 'weights', {{M1, M2}});
    net.layers{end+1} = struct('type', 'Non_linmid','weights',{{lambda}});
    net.layers{end+1} = struct('type', 'Multi_mid');
end

%the final stage
net.layers{end+1} = struct('type', 'X_mid', 'weights', {{M1, M2}});
net.layers{end+1} = struct('type', 'Nonlin_final', 'weights',{{lambda}});
%net.layers{end+1} = struct('type', 'Multi_final');
%net.layers{end+1} = struct('type', 'X_final', 'weights', {{M1, M2}});

% loss layer
net.layers{end+1}.type = 'loss';
end





