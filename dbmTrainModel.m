function [dbm_mdl, dbm_train_report] = dbmTrainModel( pose_sequences_training, pseudolabels_training, pose_sequences_validation, pseudolabels_validation, use_gpu )
%%
arguments
    pose_sequences_training cell
    pseudolabels_training cell
    pose_sequences_validation cell
    pseudolabels_validation cell
    use_gpu (1,1) logical = false
end

if use_gpu
    exec_env = 'gpu';
else
    exec_env = 'cpu';
end

%% define network architecture

sz_in = size(pose_sequences_training{1},1);
sz_out = size(pseudolabels_training{1},1);
if sz_out==1
    sz_out = numel(categories(pseudolabels_training{1}));
end
%{
layers = [
    sequenceInputLayer(sz_in,"Name","sequence","Normalization","zscore","NormalizationDimension","channel")
    gaussianNoiseLayer(0.1, "noise_1")
    fullyConnectedLayer(10,"Name","fc_1","WeightL2Factor",1)
    tanhLayer("Name","tanh_1")
    lstmLayer(10,"Name","lstm1","InputWeightsL2Factor",1,"RecurrentWeightsL2Factor",1)
    gaussianNoiseLayer(0.1, "noise_2")
    fullyConnectedLayer(10,"Name","fc_2","WeightL2Factor",1)
    reluLayer("Name","relu_1")
    fullyConnectedLayer(10,"Name","fc_3","WeightL2Factor",1)
    reluLayer("Name","relu_2")
    fullyConnectedLayer(sz_out,"Name","fcout","WeightL2Factor",1)
    softmaxLayer
    classificationLayer];
%}
%{
layers = [
    sequenceInputLayer(sz_in,"Name","sequence","Normalization","zscore","NormalizationDimension","channel")
    lstmLayer(40,"Name","lstm1","OutputMode","sequence") % Moderately complex
    dropoutLayer(0.3, "Name", "dropout1") % Balanced dropout
    batchNormalizationLayer("Name", "bn1")
    reluLayer("Name","relu_1")
    fullyConnectedLayer(25,"Name","fc_1","WeightL2Factor",1) % Moderate size and regularization
    dropoutLayer(0.3, "Name", "dropout2") % Balanced dropout
    lstmLayer(25,"Name","lstm2","OutputMode","sequence") % Moderately complex
    dropoutLayer(0.3, "Name", "dropout3") % Balanced dropout
    batchNormalizationLayer("Name", "bn2")
    reluLayer("Name","relu_2")
    fullyConnectedLayer(sz_out,"Name","fcout","WeightL2Factor",1) % Moderate regularization
    softmaxLayer
    classificationLayer];
%}
layers = [
    sequenceInputLayer(sz_in,"Name","sequence","Normalization","zscore","NormalizationDimension","channel")
    fullyConnectedLayer(25,"Name","fc_1","WeightL2Factor",1) % Moderate size and regularization
    lstmLayer(40,"Name","lstm1","OutputMode","sequence") % Moderately complex
    dropoutLayer(0.3, "Name", "dropout1") % Balanced dropout
    batchNormalizationLayer("Name", "bn1")
    reluLayer("Name","relu_1")
    fullyConnectedLayer(25,"Name","fc_1","WeightL2Factor",1) % Moderate size and regularization
    dropoutLayer(0.3, "Name", "dropout2") % Balanced dropout
    lstmLayer(25,"Name","lstm2","OutputMode","sequence") % Moderately complex
    %dropoutLayer(0.3, "Name", "dropout3") % Balanced dropout
    batchNormalizationLayer("Name", "bn2")
    reluLayer("Name","relu_2")
    fullyConnectedLayer(sz_out,"Name","fcout","WeightL2Factor",1) % Moderate regularization
    softmaxLayer
    classificationLayer];
%% Set training options
shufInd = randperm(numel(pose_sequences_training));

iter_epoch = floor(numel(pose_sequences_training)/25);
pnetOpts = trainingOptions('adam', ...
    'Plots', 'training-progress', ...
    'MiniBatchSize', iter_epoch, ...
    'Shuffle', 'every-epoch', ...
    'MaxEpochs', 100, ...
    'InitialLearnRate', 0.002, ...
    'ExecutionEnvironment', exec_env, ...
    'ValidationData', {pose_sequences_validation, pseudolabels_validation}, ...
    'ValidationFrequency', floor(3*numel(pose_sequences_training)/iter_epoch));

%% Train model

[dbm_mdl, dbm_train_report] = trainNetwork(pose_sequences_training(shufInd), pseudolabels_training(shufInd), layers, pnetOpts);


%%
end