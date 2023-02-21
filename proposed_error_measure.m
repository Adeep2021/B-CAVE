function [proposeddelaymeasure_peak,missdetectionrate_peak,TPR_detrate_peak,...
    proposeddelaymeasure_th,missdetectionrate_th,TPR_detrate_th] = proposed_delay_measure(measure,th,groundtruth_exact_cp_index,windowsize,detectedSegLoc_proposeddetector,datalen)

%% Proposed scoring measure
ws = datalen - groundtruth_exact_cp_index(end);
if windowsize > ws
    windowsize = ws;
end
groundtruth_exact_cp_index = [groundtruth_exact_cp_index;datalen];
%% Using peak detector
detected_label_peak = zeros(1,datalen);
len_actual_index = length(groundtruth_exact_cp_index);
detected_label_peak(detectedSegLoc_proposeddetector) = 1; % peak detection
a = 1;
missdetection_peak = 0;
hh = diff(groundtruth_exact_cp_index);
hh_min = min(hh);
if windowsize > hh_min(1)
    windowsize = hh_min(1)-1;
end
for j = 1:len_actual_index-1
    seg_peak = groundtruth_exact_cp_index(j) + windowsize;
    detsegloc_peak = find(detected_label_peak(1:seg_peak) == 1);
    detsegloc_peak = detsegloc_peak(detsegloc_peak>a);
    if isempty(detsegloc_peak)
        detsegloc_peak = a;
        missdetection_peak = missdetection_peak + 1;
    end
    lendetseg = length(detsegloc_peak);
    aa = abs(detsegloc_peak - groundtruth_exact_cp_index(j));
    meandelay_peak(j) = mean(aa);
    a =  groundtruth_exact_cp_index(j) + windowsize;
end
missdetectionrate_peak = missdetection_peak/length(groundtruth_exact_cp_index);
TPR_detrate_peak = 1 - missdetectionrate_peak;
proposeddelaymeasure_peak = sum(meandelay_peak)/datalen;
% proposeddelaymeasure = avg_meandelay/datalen;

%% Using threshold line detector
missdetection_th = 0;
detected_label_th = zeros(1,datalen);
len_actual_index = length(groundtruth_exact_cp_index);
detected_label_th(measure >= th) = 1; % manual threshold detection
a = 1;
missdetection_th = 0;
for j = 1:len_actual_index-1
    seg_th = groundtruth_exact_cp_index(j) + windowsize;
    detsegloc_th = find(detected_label_th(1:seg_th) == 1);
    detsegloc_th = detsegloc_th(detsegloc_th>a);
    if isempty(detsegloc_th)
        detsegloc_th = a;
        missdetection_th = missdetection_th + 1;
    end
    lendetseg = length(detsegloc_th);
    aa = abs(detsegloc_th - groundtruth_exact_cp_index(j));
    meandelay_th(j) = mean(aa);
    a =  groundtruth_exact_cp_index(j) + windowsize;
end
missdetectionrate_th = missdetection_th/length(groundtruth_exact_cp_index);
TPR_detrate_th = 1 - missdetectionrate_th;
proposeddelaymeasure_th = mean(meandelay_th);