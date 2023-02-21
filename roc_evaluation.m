function [error_score_pointdetect,score,TPR_pointdetect,FPR_pointdetect,ACC_pointdetect,PR_pointdetect,Fscore_pointdetect,...
    TPR_thresholddetect,  FPR_thresholddetect, ACC_thresholddetect, PR_thresholddetect, Fscore_thresholddetect, ...
    error_thresholddetect] = roc_evaluation(groundtruth_exact_cp_index, detectedSegLoc_pointdetector,...
    detectedSegLoc_thresholddetector, dataLength, groundtruth_exact_cp_points,windowsize)
if isempty(detectedSegLoc_pointdetector)
    detectedSegLoc_pointdetector = 1;
end
%% Floss score
    [~, n] = size(groundtruth_exact_cp_index);
    [~, k] = size(detectedSegLoc_pointdetector);
    ind(1:n) = -1;
    minV(1:n) = inf;
    for j = 1:1:n
        for i = 1:1:k
            if(abs(detectedSegLoc_pointdetector(i) - groundtruth_exact_cp_index(j)) < abs(minV(j)))
                minV(j) = abs(detectedSegLoc_pointdetector(i) - groundtruth_exact_cp_index(j));
                ind(j) = i;
            end
        end
    end
    sumOfDiff = sum(minV);
    score = sumOfDiff/dataLength;

    %% Compute ROC point values using proposed detector output
    NN = length(find(groundtruth_exact_cp_points == 0));
    PP = length(groundtruth_exact_cp_points) - NN;
    labeltestdata = zeros(1,dataLength);
    
    len_detected_points = length(detectedSegLoc_pointdetector);
    len_actual_points = PP;
    hh = diff(groundtruth_exact_cp_index);
    hh_min = min(hh);
    if windowsize > hh_min(1)
        windowsize = hh_min(1)-1;
    end

    for i = 1:len_detected_points
        for j = 1:len_actual_points
            if detectedSegLoc_pointdetector(i) >= groundtruth_exact_cp_index(j) - windowsize/2 && ...
                    detectedSegLoc_pointdetector(i) <= groundtruth_exact_cp_index(j) + windowsize/2
                detectedSegLoc_pointdetector(i) = groundtruth_exact_cp_index(j);
            end
        end
    end

    labeltestdata(detectedSegLoc_pointdetector) = 1;

    TP = 0; FP = 0; TN = 0; FN = 0;
    for kk = 1:dataLength
        if labeltestdata(kk) == 1
            if groundtruth_exact_cp_points(kk) == 1
                TP = TP + 1;
            else
                FP = FP + 1;
            end
        else
            if groundtruth_exact_cp_points(kk) == 0
                TN = TN + 1;
            else
                FN = FN + 1;
            end
        end
    end
    TPR_pointdetect = TP/PP;
    FPR_pointdetect = FP/NN;
    ACC_pointdetect = (TP + TN)/(PP + NN);
    PR_pointdetect = TP/(TP + FP);
    Fscore_pointdetect = TP/(TP + 0.5*(FP + FN));
    error_score_pointdetect = (score + FPR_pointdetect)/2; % proposed evaluation metric

    %% Compute ROC point values using simple threshold detector output
    NN = length(find(groundtruth_exact_cp_points == 0));
    PP = length(groundtruth_exact_cp_points) - NN;
    labeltestdata = zeros(1,dataLength);
    
    len_detected_points = length(detectedSegLoc_thresholddetector);
    len_actual_points = PP;

    for i = 1:len_detected_points
        for j = 1:len_actual_points
            if detectedSegLoc_thresholddetector(i) >= groundtruth_exact_cp_index(j) - windowsize/2 && ...
                    detectedSegLoc_thresholddetector(i) <= groundtruth_exact_cp_index(j) + windowsize/2
                detectedSegLoc_thresholddetector(i) = groundtruth_exact_cp_index(j);
            end
        end
    end

    labeltestdata(detectedSegLoc_thresholddetector) = 1;

    TP = 0; FP = 0; TN = 0; FN = 0;
    for kk = 1:dataLength
        if labeltestdata(kk) == 1
            if groundtruth_exact_cp_points(kk) == 1
                TP = TP + 1;
            else
                FP = FP + 1;
            end
        else
            if groundtruth_exact_cp_points(kk) == 0
                TN = TN + 1;
            else
                FN = FN + 1;
            end
        end
    end
    TPR_thresholddetect = TP/PP;
    FPR_thresholddetect = FP/NN;
    ACC_thresholddetect = (TP + TN)/(PP + NN);
    PR_thresholddetect = TP/(TP + FP);
    Fscore_thresholddetect = TP/(TP + 0.5*(FP + FN));
    error_thresholddetect = (score + FPR_pointdetect)/2; % proposed evaluation metric
end