clc; clear; close all;
%% Set all input parameters here...
phi_P = 0.03; % Local detection: peak prominence
phi_G = 0.5; % Global detection: magnitude detection threshold  value
windowsize_bcave = 8; % Window size
%% Load real dataset here...
maindata = readmatrix('scalingvariance.xls'); % It is adviced to create your dataset in an excel format....
data = maindata(:,1);
datalen = length(data);
%% Set the groundtruth index here...
gg = find(~isnan(maindata(:,2)));
groundtruth_exact_cp_index = maindata(gg,2);
groundtruth_exact_cp_points = zeros(1,length(data));
groundtruth_exact_cp_points(groundtruth_exact_cp_index) = 1;
%% Ensure that the data is in a column format...
if isrow(data)
 data = transpose(data);
end
%% Plot time and frequency domain response of input data...
dataorig = data; 
tc = dataorig(groundtruth_exact_cp_index);
figure
% tiledlayout(1,1)
%   ------- Plot input data --------
% nexttile
plot(data,'LineWidth',2)
% hold on
% bar(groundtruth_exact_cp_index,tc,'FaceColor','r','EdgeColor','r', 'BarWidth',0.05,'LineStyle','-')
xlabel('Data Index')
ylabel('Magnitude')
axis tight
title('Input data (Time domain)')
%% Call the bcave clustering algorithm here...
tStart_bcave = tic;    
[measure_bcave,criterion_mean_data,windowsize_bcave,absmeandiff_point] = bcave(data, windowsize_bcave);
tEnd_bcave = toc(tStart_bcave);
lendata = length(measure_bcave);
% ------- Detect the change points using different detection approaches ---------
% ------- Method 1: MATLAB inbuild peak detector -------
[~,locs_bcave,~,prominence_bcave] = findpeaks(measure_bcave,'MinPeakProminence',phi_P);
changepointdet_bcave = zeros(1,datalen);
changepointdet_bcave(locs_bcave) = prominence_bcave;
% ------- Method 2: Simple threshold detector -------
detectedSegLoc_thresholddetector_bcave = find(measure_bcave > phi_G);
%  ------- Plot bcave results here  ------- 
gc = groundtruth_exact_cp_points(groundtruth_exact_cp_index);
figure
tiledlayout(5,1)
%   ------- Plot data and change points -------
nexttile
plot(dataorig)
hold on
bar(groundtruth_exact_cp_index,tc,'FaceColor','r','EdgeColor','r', 'BarWidth',0.05,'LineStyle','-')
hold on
plot(locs_bcave,dataorig(locs_bcave),'r.','MarkerSize', 14)
xlabel('Data Index')
ylabel('Magnitude')
axis tight
title('Input data')
% ------- Plot bcave measure -------
nexttile
plot(measure_bcave,'k','LineWidth',2)
hold on
bar(groundtruth_exact_cp_index,gc,0.01,'k','LineStyle','--')
hold on
plot(locs_bcave,measure_bcave(locs_bcave), 'r.','MarkerSize', 14)
hold on
plot(changepointdet_bcave, 'k')
xlabel('Data Index')
ylabel('Normalized Average BCV')
axis tight
title('BCAVE')
%   ------- Evaluation -------
detector_output_bcave = zeros(1,lendata);
detector_output_bcave(locs_bcave) = 1;
[~,~,~,~,AUC_bcave] = roc_plot(measure_bcave,groundtruth_exact_cp_points);
[~,floss_score_bcave,TPR_pointdetect_bcave,FPR_pointdetect_bcave,ACC_pointdetect_bcave,PR_pointdetect_bcave...
    ,Fscore_pointdetect_bcave,TPR_thresholddetect_bcave,  FPR_thresholddetect_bcave, ACC_thresholddetect_bcave, ...
    PR_thresholddetect_bcave, Fscore_thresholddetect_bcave, ~] = ...
    roc_evaluation(groundtruth_exact_cp_index, locs_bcave,detectedSegLoc_thresholddetector_bcave, lendata,...
    groundtruth_exact_cp_points,windowsize_bcave);
[proposed_delay_measure_peak_bcave,~,~,...
    proposed_delay_measure_th_bcave,~,~] = ...
    proposed_error_measure(measure_bcave,phi_G,groundtruth_exact_cp_index,windowsize_bcave,locs_bcave,datalen);
new_proposed_error_bcave = (proposed_delay_measure_peak_bcave + FPR_pointdetect_bcave)/2;