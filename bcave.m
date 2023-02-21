function [bcv_mean_avg_all_dims_norm,criterion_mean_data,windowsize,absmeandiff_point] = bcave(data,windowsize)
%% Extra the data and the classes...
[~,dataDim] = size(data);  % obtain the data size and its dimensions
%% Multi-dimensional process 
%% Begin iteration over each dimension of the dataset here...
for dd = 1:dataDim
    dataset = data(:,dd); % Extracts each dimension of the dataset
    datalen = length(dataset); % obtain length of the dataset
    %% ------ Ensure batchsize is even ------
    if mod(windowsize,2) > 0
        windowsize = windowsize + 1;
    end
%     stepsize_in_batch = 1;
    stepsize_in_batch = windowsize/2;
    %% ------ Make dataset into a row ------
    if iscolumn(dataset)
        dataset = transpose(dataset);
    end
    %% ------ Compute the average BCV for a single dimension of the dataset ------
    [bcv_mean_each_dim,criterion_mean_data,overall_time_end_data,avg_batch_time_end_data,absmeandiff_point] = sliding_window_process(dataset,datalen,windowsize,stepsize_in_batch);
    %% ------ Store all the average BCV of all the dimensions of the dataset ------
    bcv_mean_all_dims(:,dd) = bcv_mean_each_dim;
end
%% Estimate mean of the average BCV over the entire dimensions of the dataset ------
bcv_mean_avg_all_dims = mean((bcv_mean_all_dims),2); 
% bcv_mean_avg_all_dims_norm = bcv_mean_avg_all_dims;
bcv_mean_avg_all_dims_norm = normalize(bcv_mean_avg_all_dims,"range");
% bcv_mean_avg_all_dims_norm = 1 - bcv_mean_avg_all_dims_norm; % complement of the bcv


