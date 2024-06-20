% Function to calculate mov_int from the index of peak velocity to the
% endpoint of movement. This is in response to the March 2022 reviewer
% comments (initial submission)

function [fbmov_int, fbmov_int_c, fbmov_int_down_st, fbmov_int_up_st] = feedbackmov_int_train(plotBool, cursorPosX, cursorPosY, indPeak, offset, numTrials, wrong_trial, upTrials, downTrials, exTrials, peTrials, subID)
%%%%%%%%%%%%%%%%%%%%%%% Movement Length %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov_int = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0
        mov_int(i) = sum(sqrt(diff(cursorPosX{i,1}(indPeak(i):offset(i)-1)).^2 + diff(cursorPosY{i,1}(indPeak(i):offset(i)-1)).^2)) * 100; %movement length in cm; "-1" to fix index overflow
    else
        mov_int(i) = NaN;
    end
end

%% mov_int outlier analysis
data = outlier_t(mov_int(upTrials(1:8))); % Outlier for visual baseline
mov_int_c(upTrials(1:8)) = data;
data = outlier_t(mov_int(downTrials(1:8)));
mov_int_c(downTrials(1:8)) = data;
clear data;

% Exclude ALL trials of exposure to outlier scrubbing
mov_int_c(upTrials(9:128)) = mov_int(upTrials(9:128));
mov_int_c(downTrials(9:128)) = mov_int(downTrials(9:128));

% Exclude ALL of post-exposure from outlier scrubbing
mov_int_c(upTrials(129:136)) = mov_int(upTrials(129:136));
mov_int_c(downTrials(129:136)) = mov_int(downTrials(129:136));

% transpose and calculate standardized variable
mov_int_c = mov_int_c';
bkup_mean = nanmean(mov_int_c(upTrials(1:8)));
bkup_std = nanstd(mov_int_c(upTrials(1:8)));
mov_int_up_st = (mov_int_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(mov_int_c(downTrials(1:8)));
bkdown_std = nanstd(mov_int_c(downTrials(1:8)));
mov_int_down_st = (mov_int_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for mov_int
if plotBool == 1
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),mov_int(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),mov_int_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),mov_int(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),mov_int_c(downTrials(1:8)),'rx');
hold on
yline(10, '--k');
axis([0 16 0 40]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:10:40,'YTickLabel', 0:10:40,'FontName','Arial','FontSize',10); ylabel('mov_int [cm]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,mov_int(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,mov_int_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,mov_int(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,mov_int_c(downTrials(9:28)),'rx');
hold on
yline(10, '--k');
axis([0 40 0 40]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(129:136)-peTrials(1)+1,mov_int(upTrials(129:136)),'bo');
hold on
plot(upTrials(129:136)-peTrials(1)+1,mov_int_c(upTrials(129:136)),'bx');
hold on
plot(downTrials(129:136)-peTrials(1)+1,mov_int(downTrials(129:136)),'ro');
hold on
plot(downTrials(129:136)-peTrials(1)+1,mov_int_c(downTrials(129:136)),'rx');
hold on
yline(10, '--k');
axis([0 16 0 40]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'mov_int'])
end
%% Export vars
fbmov_int = mov_int;
fbmov_int_c = mov_int_c;
fbmov_int_down_st = mov_int_down_st;
fbmov_int_up_st = mov_int_up_st;