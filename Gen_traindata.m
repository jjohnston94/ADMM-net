%% Generate training data
clear data

config;
ND = nnconfig.DataNmber;
TN = nnconfig.TrainNumber;

for i = 1:1:ND 

gen_signal;
% store training pair
data.train = bb;
data.label = x;
save(strcat('./data/ChestTrain_sampling/', saveName(i, 2)), 'data');
end

% for i = 1:TN
%     gen_signal;
%     data(i).train = bb;
%     data(i).label = x;
% end