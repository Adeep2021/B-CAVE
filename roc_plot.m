function [groundtruth,th_values_2,TPR,FPR,AUC] = roc_plot(changepointmeasure,groundtruth)
% You must ensure that both groundtruth and test datasets are labeled
% either ZEROES or ONES. This means that samples of interest to be detected
% must be labeled as 1 in the groundtruth, while others must be labeled 0.
% Similarly, the test dataset must have detected samples as 1, while others
% be labeled 0.
% function [PD,PFA] = roc_plot_final(groundtruth,test)
% clc; clear; close all;
%% Threshold Limits
thmin = min(changepointmeasure);
thmax = max(changepointmeasure);
smooth_factor = 1;
NN = length(find(groundtruth == 0));
PP = length(groundtruth) - NN;

%% PLOTTING ROC
TP = 0; FP = 0; TN = 0; FN = 0;
jj = 0;
TPR = 0; FPR = 0; ACC = 0; PR = 0; AUC = 0;
thstep = (thmax - thmin)/1000;
th_values_2 = [];
datalen = length(changepointmeasure);
th = thmax;
% for th = thmax:thstep:thmin
while th > thmin - thstep
    jj = jj + 1;
    labeltestdata = double(changepointmeasure >= th);
    for kk = 1:datalen
        if labeltestdata(kk) == 1
            if groundtruth(kk) == 1
                TP = TP + 1;
            else
                FP = FP + 1;
            end
        else
            if groundtruth(kk) == 0
                TN = TN + 1;
            else
                FN = FN + 1;
            end
        end
    end
    TPR(jj) = TP/PP;
    FPR(jj) = FP/NN;
    ACC(jj) = (TP + TN)/(PP + NN);
    PR(jj) = TP/(TP + FP);
    Fscore(jj) = TP/(TP + 0.5*(FP + FN));
    TP = 0; FP = 0; TN = 0; FN = 0;
    th_values_2 = [th_values_2,th];
    if th == 0.5001
        results = [TPR(jj);FPR(jj);PR(jj);Fscore(jj);ACC(jj)]
        hh = 1;
    end

    th = th - thstep;
end
% TPR = smooth(TPR,smooth_factor);
% FPR = smooth(FPR,smooth_factor);
if isscalar(FPR) || isscalar(TPR)
    AUC = 0;
    th_values_2 = max(changepointmeasure);
else
    AUC = trapz(FPR,TPR);
end

%% Plot ROC curves: Second method...
nexttile
plot(FPR,TPR,'-b')
axis([0 1 0 1])
grid on
xlabel('Probability of False Alarm')
ylabel('Probability of Detection')
title('ROC CURVE')
%% Plot Accuracy curve...
nexttile
plot(th_values_2,ACC,'-r')
grid on
xlabel('Threshold values')
ylabel('Accuracy')
title('ACCURACY')
axis tight
%% Plot against threshold values: Second method...
nexttile
plot(th_values_2,TPR,'b-','LineWidth',2)
hold on
plot(th_values_2, FPR,'r-','LineWidth',2)
grid on
axis([thmin thmax 0 1])
legend('Detection Curve','False Alarm Curve')
xlabel('Threshold Values')
ylabel('Probability Values')
title('DETECTION and FALSE ALARM')