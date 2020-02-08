function [ loss, grad ] = loss_with_gradient_total( weights)
%% Compute average loss and average gradient for training data set

config;
m = nnconfig.ImageSize;
nn = nnconfig.PartitionSize;
% Number of training pairs
TN = nnconfig.TrainNumber;

% Create net object using weights
net = weiTOnet(weights);

% Initialize
loss = 0;


%% Only compute the avg loss
if nargout == 1
    for i = 1:TN
        % get training data
        data = getMData(i);  
         l = loss_with_gradient_single(data, net, m, nn);
        loss = loss + l;
    end
    loss = loss / TN;
    
%% Compute avg loss and avg gradient
elseif nargout == 2
    grad_length = length(weights);
    grad = zeros(grad_length,1);
    for i = 1:TN
        data = getMData(i);
        [l, g] = loss_with_gradient_single(data, net, m, nn);
        loss = loss + l;      
        grad = grad + g;
    end
    loss = loss / TN;
    grad = grad / TN;
else
    error('Invalid out put number.');
end

end

