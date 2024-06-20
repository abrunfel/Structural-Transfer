% Function to calculate RMSE from the index of peak velocity to the
% endpoint of movement. This is in response to the March 2022 reviewer
% comments (initial submission)

function [fbrmse, fbrmse_c, fbrmse_down_st, fbrmse_up_st] = feedbackrmse_train(plotBool, cursorPosX, cursorPosY, indPeak, offset, numTrials, wrong_trial, upTrials, downTrials, exTrials, peTrials, subID)
%% RMSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RMSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taken straight from kinsym2 step 2 files
rmse=zeros(numTrials,1); % allocate space for rmse
mov_int = zeros(numTrials,1);
for i=1:numTrials
    if wrong_trial(i)==0
        xx=cursorPosX{i,1}(indPeak(i):offset(i)-1)*1000; % convert to mm; NOTE: This is now the 'feedback' version of RMSE (from index of peak velocity to movement offset); "-1" to fix index overflow
        yy=cursorPosY{i,1}(indPeak(i):offset(i)-1)*1000;
        % spatial resampling of movement path
        N= 2000; N1= length(xx); % Computes equally-spaced vector assuming 1000 samples
        xc= 1/(N-1)*(0:N-1)*(xx(N1)-xx(1))+xx(1);
        yc= 1/(N-1)*(0:N-1)*(yy(N1)-yy(1))+yy(1);
        % integrates the movement length
        mov_int(i)=sum(sqrt(diff(xx).^2+ diff(yy).^2));
        di=(0:N-1)*mov_int(i)/(N-1);
        d=[0; (cumsum(sqrt((diff(xx).^2)+ (diff(yy).^2))))];
        % interpolates the movement path to make it equally spaced
        x2i= interp1q(d,xx,di');
        y2i= interp1q(d,yy,di');
        x2i(N)=xc(N);
        y2i(N)=yc(N);
        optimal =[xc', yc'];
        resampled_path =[x2i, y2i];
        rmse(i) = sqrt(sum(sum((resampled_path - optimal).^2))/N);
    else rmse(i)=NaN;
    end
end

%% rmse outlier analysis
data = outlier_t(rmse(upTrials(1:8))); % Outlier for visual baseline
rmse_c(upTrials(1:8)) = data;
data = outlier_t(rmse(downTrials(1:8)));
rmse_c(downTrials(1:8)) = data;
clear data;

% Exclude ALL trials from outlier scrubbing
rmse_c(upTrials(9:128)) = rmse(upTrials(9:128));
rmse_c(downTrials(9:128)) = rmse(downTrials(9:128));


% Exclude ALL of post-exposure from outlier scrubbing
rmse_c(upTrials(129:136)) = rmse(upTrials(129:136));
rmse_c(downTrials(129:136)) = rmse(downTrials(129:136));

% transpose and calculate standardized variable
rmse_c = rmse_c';
bkup_mean = nanmean(rmse_c(upTrials(1:8)));
bkup_std = nanstd(rmse_c(upTrials(1:8)));
rmse_up_st = (rmse_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(rmse_c(downTrials(1:8)));
bkdown_std = nanstd(rmse_c(downTrials(1:8)));
rmse_down_st = (rmse_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for rmse
if plotBool == 1
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),rmse(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),rmse_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),rmse(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),rmse_c(downTrials(1:8)),'rx');
axis([0 16 0 60]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',0:10:60,'YTickLabel', 0:10:60,'FontName','Arial','FontSize',10); ylabel('rmse [mm]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,rmse(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,rmse_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,rmse(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,rmse_c(downTrials(9:28)),'rx');
axis([0 40 0 60]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(129:136)-peTrials(1)+1,rmse(upTrials(129:136)),'bo');
hold on
plot(upTrials(129:136)-peTrials(1)+1,rmse_c(upTrials(129:136)),'bx');
hold on
plot(downTrials(129:136)-peTrials(1)+1,rmse(downTrials(129:136)),'ro');
hold on
plot(downTrials(129:136)-peTrials(1)+1,rmse_c(downTrials(129:136)),'rx');
axis([0 16 0 60]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'rmse'])
end
%% Export vars
fbrmse = rmse;
fbrmse_c = rmse_c;
fbrmse_down_st = rmse_down_st;
fbrmse_up_st = rmse_up_st;
end