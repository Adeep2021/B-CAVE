function [bcv_mean,criterion_mean,overall_time_end,avg_batch_time_end,absmeandiff_point] = sliding_window_process(dataset,datalen,windowsize,stepsize_in_batch)
%% Initialize memory for saving the output results
criterion_mean = zeros(datalen,1);
bcv_mean = zeros(datalen,1);
avg_batch_time_end = zeros(datalen,1); % stores the total time taken to process the entire dataset
bcv_batch_size = length(1:stepsize_in_batch:windowsize);
overall_time_start = tic;
%% ====== Phase 1: Average of between class mean ======
for i = 1:datalen
    %% Select data for batch processing
    if windowsize < datalen
        if windowsize/2<i&&i<=datalen-windowsize/2
            cwin=[i-windowsize/2:i-1 i+1:i+windowsize/2];
        elseif i==1
            cwin=i+1:i+windowsize;
        elseif i>1&&i<=windowsize/2
            cwin=[1:i-1 i+1:windowsize+1];
        elseif i>=datalen-windowsize/2+1&&i<datalen
            cwin=[datalen-windowsize:i-1 i+1:datalen];
        elseif i==datalen
            cwin=i-windowsize:i-1;
        end
    elseif windowsize == datalen
        if i == 1
            cwin=i+1:windowsize;
        elseif i > 1
            cwin=[1:i-1 i+1:windowsize];
        end
    end
    avg_batch_time_start = tic; %starts measuring time for batch processing
    %%   ====== Load data into the batch memory ======
    windata = dataset(cwin);
    %% ====== Apply Proposed Method ======
    overall_time_start = tic;
    [~,~,absmeandiff] = Otsu_Instance(windata,stepsize_in_batch,bcv_batch_size);
    absmeandiff_point(i) = mean(absmeandiff);
    avg_batch_time_end(i) = toc(avg_batch_time_start);
end
%% ====== Phase 2: Compute average of between-class variance ======
for i = 1:datalen
    %% Select data for batch processing
    if windowsize < datalen
        if windowsize/2<i&&i<=datalen-windowsize/2
            cwin=[i-windowsize/2:i-1 i+1:i+windowsize/2];
        elseif i==1
            cwin=i+1:i+windowsize;
        elseif i>1&&i<=windowsize/2
            cwin=[1:i-1 i+1:windowsize+1];
        elseif i>=datalen-windowsize/2+1&&i<datalen
            cwin=[datalen-windowsize:i-1 i+1:datalen];
        elseif i==datalen
            cwin=i-windowsize:i-1;
        end
    elseif windowsize == datalen
        if i == 1
            cwin=i+1:windowsize;
        elseif i > 1
            cwin=[1:i-1 i+1:windowsize];
        end
    end

   avg_batch_time_start = tic; %starts measuring time for batch processing
    %%   ====== Load pre-processed data into the batch memory ======
    windata = absmeandiff_point(cwin);
    %% ====== Apply Proposed Method ======
    overall_time_start = tic;
    [bcv,criterion,~] = Otsu_Instance(windata,stepsize_in_batch,bcv_batch_size);
    bcv_mean(i) = mean(bcv);
    criterion_mean(i) = max(criterion);
    avg_batch_time_end(i) = toc(avg_batch_time_start);
end
overall_time_end = toc(overall_time_start);
ptext = ['The total computational time is ',num2str(overall_time_end)];
% disp(ptext)
avg_batch_time_end = mean(avg_batch_time_end);
ptext = ['The average batch computational time is ',num2str(avg_batch_time_end)];
% disp(ptext)