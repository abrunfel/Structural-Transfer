% Function to calculate MT from the index of peak velocity to the
% endpoint of movement. This is in response to the March 2022 reviewer
% comments (initial submission)

function [fbMT, fbMT_c, fbMT_down_st, fMT_up_st] = feedbackMT(plotBool, indPeak, offset, fs, wrong_trial, upTrials, downTrials, exTrials, peTrials, subID)
%% Movement Time (MT)
%%%%%%%%%%%%%%%%%%%%%%%%%%% Movement Time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MT = (offset - indPeak)/fs;
MT(wrong_trial==1) = NaN;

%% MT outlier analysis
data = outlier_t(MT(upTrials(1:8))); % Outlier for visual baseline
MT_c(upTrials(1:8)) = data;
data = outlier_t(MT(downTrials(1:8)));
MT_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 trials of exposure from outlier scrubbing
MT_c(upTrials(9:14)) = MT(upTrials(9:14));
MT_c(downTrials(9:14)) = MT(downTrials(9:14));

data = outlier_t(MT(upTrials(15:28))); % Outlier for last 28 exposure
MT_c(upTrials(15:28)) = data;
data = outlier_t(MT(downTrials(15:28)));
MT_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
MT_c(upTrials(29:36)) = MT(upTrials(29:36));
MT_c(downTrials(29:36)) = MT(downTrials(29:36));

% transpose and calculate standardized variable
MT_c = MT_c';
bkup_mean = nanmean(MT_c(upTrials(1:8)));
bkup_std = nanstd(MT_c(upTrials(1:8)));
MT_up_st = (MT_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(MT_c(downTrials(1:8)));
bkdown_std = nanstd(MT_c(downTrials(1:8)));
MT_down_st = (MT_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for MT
if plotBool == 1
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),MT(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),MT_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),MT(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),MT_c(downTrials(1:8)),'rx');
axis([0 16 0 6]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:1:6,'YTickLabel',0:1:6,'FontName','Arial','FontSize',10); ylabel('MT [s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,MT(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,MT_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,MT(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,MT_c(downTrials(9:28)),'rx');
axis([0 40 0 6]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,MT(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,MT_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,MT(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,MT_c(downTrials(29:36)),'rx');
axis([0 16 0 6]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'MT'])
end
%% Export vars
fbMT = MT;
fbMT_c = MT_c;
fbMT_down_st = MT_down_st;
fMT_up_st = MT_up_st;