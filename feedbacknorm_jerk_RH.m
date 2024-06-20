% Function to calculate norm_jerk from the index of peak velocity to the
% endpoint of movement. This is in response to the March 2022 reviewer
% comments (initial submission)

function [fbnorm_jerk, fbnorm_jerk_c, fbnorm_jerk_down_st, fbnorm_jerk_up_st] = feedbacknorm_jerk_RH(plotBool, sortData, indPeak, offset, numTrials, wrong_trial, upTrials, downTrials, exTrials, peTrials, subID, fs, fbMT, fbmov_int)
%%%%%%%%%%%%%%%%%%%%%%% Normalized Jerk %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_t = 1/fs; %Sample Period
acc_tan = cell(numTrials,1);
jerk = cell(numTrials,1);
jerk_square = cell(numTrials,1);
delta_1 = cell(numTrials,1);
jerk_int = zeros(numTrials,1);
norm_jerk = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0
        acc_tan{i,1} = 100*sqrt((sortData(i).Right_HandXAcc(indPeak(i):offset(i))).^2 + (sortData(i).Right_HandYAcc(indPeak(i):offset(i))).^2); % in cm/s/s % NOTE: the original code did not segment to onset/offset. I've added it here
        jerk{i,1} = diff(acc_tan{i,1})/delta_t;
        jerk_square{i,1} = jerk{i,1}.^2;
        delta_1{i,1} = (0:1:(length(jerk_square{i,1}) - 1)) ./fs;
        jerk_int(i) = trapz(delta_1{i,1},jerk_square{i,1}); 
        norm_jerk(i) = sqrt(0.5 *jerk_int(i) * ((fbMT(i))^5)/ (fbmov_int(i)^2));
    else
        norm_jerk(i) = NaN;
    end
end

%% norm_jerk outlier analysis
data = outlier_t(norm_jerk(upTrials(1:8))); % Outlier for visual baseline
norm_jerk_c(upTrials(1:8)) = data;
data = outlier_t(norm_jerk(downTrials(1:8)));
norm_jerk_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 trials from outlier scrubbing
norm_jerk_c(upTrials(9:14)) = norm_jerk(upTrials(9:14));
norm_jerk_c(downTrials(9:14)) = norm_jerk(downTrials(9:14));

data = outlier_t(norm_jerk(upTrials(15:28))); % Outlier for last 28 exposure
norm_jerk_c(upTrials(15:28)) = data;
data = outlier_t(norm_jerk(downTrials(15:28)));
norm_jerk_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
norm_jerk_c(upTrials(29:36)) = norm_jerk(upTrials(29:36));
norm_jerk_c(downTrials(29:36)) = norm_jerk(downTrials(29:36));

% transpose and calculate standardized variable
norm_jerk_c = norm_jerk_c';
bkup_mean = nanmean(norm_jerk_c(upTrials(1:8)));
bkup_std = nanstd(norm_jerk_c(upTrials(1:8)));
norm_jerk_up_st = (norm_jerk_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(norm_jerk_c(downTrials(1:8)));
bkdown_std = nanstd(norm_jerk_c(downTrials(1:8)));
norm_jerk_down_st = (norm_jerk_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for norm_jerk
if plotBool == 1
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),norm_jerk(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),norm_jerk_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),norm_jerk(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),norm_jerk_c(downTrials(1:8)),'rx');
axis([0 16 0 1000]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',0:100:1000,'YTickLabel', 0:100:1000,'FontName','Arial','FontSize',10); ylabel('norm jerk [?]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,norm_jerk(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,norm_jerk_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,norm_jerk(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,norm_jerk_c(downTrials(9:28)),'rx');
axis([0 40 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,norm_jerk(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,norm_jerk_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,norm_jerk(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,norm_jerk_c(downTrials(29:36)),'rx');
axis([0 16 0 1000]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'norm_jerk'])
end
%% Export vars
fbnorm_jerk = norm_jerk;
fbnorm_jerk_c = norm_jerk_c;
fbnorm_jerk_down_st = norm_jerk_down_st;
fbnorm_jerk_up_st = norm_jerk_up_st;