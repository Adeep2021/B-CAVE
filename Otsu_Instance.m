%% ============= Application of the principles of discriminant analysis =================
function [bcv,criterion,absmeandiff] = Otsu_Instance(batch_data,stepsize,bcv_mem_size)
NN = length(batch_data);
bcv = zeros(bcv_mem_size,1);
batch_data = sort(batch_data);
var_data = var(batch_data); % Compute the variance of the entire data
mean_data = mean(batch_data);
q = 1;
for k = 1:stepsize:NN % iterate through each sample
    nsmean = mean(batch_data(1:k)); %obtain mean of lower class
    nsvar = var(batch_data(1:k)); %obtain variance of lower class
    pn = k/NN; % obtain normalized frequency of lower class
    if k < NN
        ps = 1 - pn; % obtain normalized frequency of upper class
        ssmean = (mean_data - nsmean*pn)/ps;  %obtain mean of upper class
        ssvar = var(batch_data(k+1:NN));
    else
        ssmean = 0;
        ps = 0;
    end
    bcv(q) = (ps*pn*(ssmean - nsmean)^2); %compute between class variance (bcv)
    wcv(q) = pn*nsvar + ps*(ssvar); % compute within class variance (wcv)
    absmeandiff(q) = abs(ssmean - nsmean);
    q = q + 1;
end
criterion = max(bcv)/var_data; %compute the criterion measure
end

