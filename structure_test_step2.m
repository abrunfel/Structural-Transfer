% This loads in the .mat file generated in step 1
clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/Post_Step_1');
    fname = uigetfile('*test*.mat');
    
else
    cd('Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\Post_Step_1'); % Lab PCs
    %cd('C:\Users\Alex\Desktop\IFDosing\Post_Step_1'); % Home PC
    fname = uigetfile('*test*.mat');
end

load(fname);
subID = fname(1:13);

numTrials = size(sortData,1); % Number of Trials
fs = 1000; % Sample Rate (Hz)
delta_t = 1/fs; %Sample Period

% Conversion between global and local reference frame (this is due to all
% x,y hand positions being referenced in the global frame, whereas the
% targets in the target table are referenced in a local frame specified in
% Deterit-E
Tx = sortData(1,1).TARGET_TABLE.X_GLOBAL(1) - sortData(1,1).TARGET_TABLE.X(1);
Ty = sortData(1,1).TARGET_TABLE.Y_GLOBAL(1) - sortData(1,1).TARGET_TABLE.Y(1);

% Baseline, Exposure, and Post-exposure trials
vbTrials = 1:16;
exTrials = 17:56;
peTrials = 57:72;

% Define the rotation amounts during baseline, ex, pe
theta(vbTrials) = 0; % rotation in degrees during exposure phase
theta(exTrials) = 60; % WARNING: THIS IS HARD CODED!!!
theta(peTrials) = 0;

% Find the Cursor Position
% First, translate rotation point to global origin
% Then apply rotation, and translate back to target origin
cursorPosX = cell(numTrials,1);
cursorPosY = cell(numTrials,1);
handPosX = cell(numTrials,1);
handPosY = cell(numTrials,1);
for i = 1:numTrials
    handPosX{i,1} = sortData(i).Left_HandX - sortData(1).TARGET_TABLE.X_GLOBAL(1)/100; % Translate to global origin
    handPosY{i,1} = sortData(i).Left_HandY - sortData(1).TARGET_TABLE.Y_GLOBAL(1)/100;
    
    cursorPosX{i,1} = handPosX{i,1}.*cosd(theta(i)) - handPosY{i,1}.*sind(theta(i)); % Reverse the rotation
    cursorPosY{i,1} = handPosX{i,1}.*sind(theta(i)) + handPosY{i,1}.*cosd(theta(i));
    
    cursorPosX{i,1} = cursorPosX{i,1} + sortData(1).TARGET_TABLE.X_GLOBAL(1)/100; % Translate back to target origin
    cursorPosY{i,1} = cursorPosY{i,1} + sortData(1).TARGET_TABLE.Y_GLOBAL(1)/100;
end



% Find the "Up" and "Down" trials
upBool = zeros(numTrials,1);
for i = 1:numTrials
    upBool(i) = sortData(i).TRIAL.TP == 1 || sortData(i).TRIAL.TP == 3;
end
upBool = upBool';
upTrials = find(upBool == 1); % Trial numbers of "up" targets
upTrials = upTrials';
downTrials = find(upBool == 0);
downTrials = downTrials';


numDataPoints = zeros(numTrials,1);
for i = 1:numTrials
    numDataPoints(i) = size(sortData(i).Left_HandX,1); % Number of Data points in each trial
end

vel = cell(numTrials,1);
velPeak = zeros(numTrials,1);
indPeak = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0
        %Calculate hand speed
        vel{i,1} = sqrt(sortData(i,1).Left_HandXVel.^2 + sortData(i,1).Left_HandYVel.^2);
        %Find Peak velocity
        [velPeak(i), indPeak(i)] = max(abs(vel{i,1}(1:offset(i))));
    else
        velPeak(i) = NaN; indPeak(i) = NaN;
    end
end
velPeakTime = indPeak - onset;
%% Movement Time (MT)
%%%%%%%%%%%%%%%%%%%%%%%%%%% Movement Time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MT = (offset - onset)/fs;
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

%% IDE
%%%%%%%%%%%%%%%%%%%%%%% Initial Directional Error %%%%%%%%%%%%%%%%%%%%%%%%
% Defined as the angle between the vector from hand position at movement
% onset to target position and a vector pointing to the hand
% position at peak velocity from movement onset hand position
upTargetPos = [sortData(1,1).TARGET_TABLE.X(2) sortData(1,1).TARGET_TABLE.Y(2)];
downTargetPos = [sortData(1,1).TARGET_TABLE.X(3) sortData(1,1).TARGET_TABLE.Y(3)];

xPeak = zeros(numTrials,1);
yPeak = zeros(numTrials,1);
xStart = zeros(numTrials,1);
yStart = zeros(numTrials,1);
imd = zeros(numTrials,2); % initial movement direction (x,y)
itd = zeros(numTrials,2); % initial target direction (x,y)
ide = zeros(numTrials,1);

for i = 1:numTrials
    if wrong_trial(i) == 0
        % Hand Position at movement onset
        xStart(i) = cursorPosX{i,1}(onset(i))*100-Tx; %in cm and workspace ref frame
        yStart(i) = cursorPosY{i,1}(onset(i))*100-Ty;
        % Hand Position at peak velocity
        xPeak(i) = cursorPosX{i,1}(indPeak(i))*100-Tx; %in cm and workspace ref frame
        yPeak(i) = cursorPosY{i,1}(indPeak(i))*100-Ty;
        % Vector from start position to peak velocity position
        imd(i,:) = [xPeak(i) - xStart(i) yPeak(i) - yStart(i)];
        
        if yPeak(i) > 0
            itd(i,:) = [upTargetPos(1) - xStart(i) upTargetPos(2) - yStart(i)];
        elseif yPeak(i) < 0
            itd(i,:) = [downTargetPos(1) - xStart(i) downTargetPos(2) - yStart(i)];
        end
        ide(i) = acosd(dot(itd(i,:),imd(i,:))./(norm(itd(i,:)).*norm(imd(i,:))));
        % Make ide the the 1st and 3rd quad negative
        if imd(i,1) > 0 && imd(i,2) > 0
            ide(i) = -ide(i);
        elseif imd(i,1) < 0 && imd(i,2) < 0
            ide(i) = -ide(i);
        end
        
    else
        xPeak(i) = NaN;
        yPeak(i) = NaN;
        xStart(i) = NaN;
        yStart(i) = NaN;
        imd(i,:) = NaN;
        ide(i) = NaN;
    end
end

%ide(exTrials) = ide(exTrials)-40;

%% ide outlier analysis
data = outlier_t(ide(upTrials(1:8)));
ide_c(upTrials(1:8)) = data;
data = outlier_t(ide(downTrials(1:8)));
ide_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 trials of exposure from outlier scrubbing
ide_c(upTrials(9:14)) = ide(upTrials(9:14));
ide_c(downTrials(9:14)) = ide(downTrials(9:14));

% Outlier scrub remaining 28 exposure trials
data = outlier_t(ide(upTrials(15:28)));
ide_c(upTrials(15:28)) = data;
data = outlier_t(ide(downTrials(15:28)));
ide_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
ide_c(upTrials(29:36)) = ide(upTrials(29:36));
ide_c(downTrials(29:36)) = ide(downTrials(29:36));

% transpose and calculate standardized variable
ide_c = ide_c';
bkup_mean = nanmean(ide_c(upTrials(1:8)));
bkup_std = nanstd(ide_c(upTrials(1:8)));
ide_up_st = (ide_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(ide_c(downTrials(1:8)));
bkdown_std = nanstd(ide_c(downTrials(1:8)));
ide_down_st = (ide_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for ide
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),ide(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),ide_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),ide(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),ide_c(downTrials(1:8)),'rx');
hold on
yline(0, '--k');
axis([0 16 -80 80]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',-80:20:80,'YTickLabel',-80:20:80,'FontName','Arial','FontSize',10); ylabel('ide [s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,ide(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,ide_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,ide(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,ide_c(downTrials(9:28)),'rx');
hold on
yline(0, '--k');
axis([0 40 -80 80]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,ide(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,ide_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,ide(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,ide_c(downTrials(29:36)),'rx');
hold on
yline(0, '--k');
axis([0 16 -80 80]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'ide'])

%% RMSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RMSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taken straight from kinsym2 step 2 files
rmse=zeros(numTrials,1); % allocate space for rmse
mov_int = zeros(numTrials,1);
for i=1:numTrials
    if wrong_trial(i)==0
        xx=cursorPosX{i,1}(onset(i):offset(i))*1000; % convert to mm
        yy=cursorPosY{i,1}(onset(i):offset(i))*1000;
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

% Exclude first 12 trials from outlier scrubbing
rmse_c(upTrials(9:14)) = rmse(upTrials(9:14));
rmse_c(downTrials(9:14)) = rmse(downTrials(9:14));

data = outlier_t(rmse(upTrials(15:28))); % Outlier for remaining 28 exposure
rmse_c(upTrials(15:28)) = data;
data = outlier_t(rmse(downTrials(15:28)));
rmse_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
rmse_c(upTrials(29:36)) = rmse(upTrials(29:36));
rmse_c(downTrials(29:36)) = rmse(downTrials(29:36));

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
plot(upTrials(29:36)-peTrials(1)+1,rmse(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,rmse_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,rmse(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,rmse_c(downTrials(29:36)),'rx');
axis([0 16 0 60]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'rmse'])

%% Movement Length

%%%%%%%%%%%%%%%%%%%%%%% Movement Length %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mov_int = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0
        mov_int(i) = sum(sqrt(diff(cursorPosX{i,1}(onset(i):offset(i))).^2 + diff(cursorPosY{i,1}(onset(i):offset(i))).^2)) * 100; %movement length in cm
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

% Exclude first 12 trials of exposure to outlier scrubbing
mov_int_c(upTrials(9:14)) = mov_int(upTrials(9:14));
mov_int_c(downTrials(9:14)) = mov_int(downTrials(9:14));

data = outlier_t(mov_int(upTrials(15:28))); % Outlier for last 28 exposure
mov_int_c(upTrials(15:28)) = data;
data = outlier_t(mov_int(downTrials(15:28)));
mov_int_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
mov_int_c(upTrials(29:36)) = mov_int(upTrials(29:36));
mov_int_c(downTrials(29:36)) = mov_int(downTrials(29:36));

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
plot(upTrials(29:36)-peTrials(1)+1,mov_int(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,mov_int_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,mov_int(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,mov_int_c(downTrials(29:36)),'rx');
hold on
yline(10, '--k');
axis([0 16 0 40]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'mov_int'])

%% Normalized Jerk Score
%%%%%%%%%%%%%%%%%%%%%%% Normalized Jerk %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acc_tan = cell(numTrials,1);
jerk = cell(numTrials,1);
jerk_square = cell(numTrials,1);
delta_1 = cell(numTrials,1);
jerk_int = zeros(numTrials,1);
norm_jerk = zeros(numTrials,1);
for i = 1:numTrials
    if wrong_trial(i) == 0
        acc_tan{i,1} = 100*sqrt((sortData(i).Left_HandXAcc).^2 + (sortData(i).Left_HandYAcc).^2); % in cm/s/s
        jerk{i,1} = diff(acc_tan{i,1})/delta_t;
        jerk_square{i,1} = jerk{i,1}.^2;
        delta_1{i,1} = (0:1:(length(jerk_square{i,1}) - 1)) ./fs;
        jerk_int(i) = trapz(delta_1{i,1},jerk_square{i,1}); 
        norm_jerk(i) = sqrt(0.5 *jerk_int(i) * ((MT(i))^5)/ (mov_int(i)^2));
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

%% Peak Velocity
velPeak = velPeak * 100; % Convert to cm/s
velPeak(wrong_trial == 1) = NaN;

%% Peak Velocity outlier calc
data = outlier_t(velPeak(upTrials(1:8))); % Outlier for visual baseline
velPeak_c(upTrials(1:8)) = data;
data = outlier_t(velPeak(downTrials(1:8)));
velPeak_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 trials of exposure from outlier scrubbing
velPeak_c(upTrials(9:14)) = velPeak(upTrials(9:14));
velPeak_c(downTrials(9:14)) = velPeak(downTrials(9:14));

data = outlier_t(velPeak(upTrials(15:28))); % Outlier for last 28 exposure
velPeak_c(upTrials(15:28)) = data;
data = outlier_t(velPeak(downTrials(15:28)));
velPeak_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
velPeak_c(upTrials(29:36)) = velPeak(upTrials(29:36));
velPeak_c(downTrials(29:36)) = velPeak(downTrials(29:36));

% transpose and calculate standardized variable
velPeak_c = velPeak_c';
bkup_mean = nanmean(velPeak_c(upTrials(1:8)));
bkup_std = nanstd(velPeak_c(upTrials(1:8)));
velPeak_up_st = (velPeak_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(velPeak_c(downTrials(1:8)));
bkdown_std = nanstd(velPeak_c(downTrials(1:8)));
velPeak_down_st = (velPeak_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for velPeak
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),velPeak(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),velPeak_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),velPeak(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),velPeak_c(downTrials(1:8)),'rx');
axis([0 16 0 100]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',0:10:100,'YTickLabel', 0:10:100,'FontName','Arial','FontSize',10); ylabel('velPeak [cm/s]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,velPeak(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,velPeak_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,velPeak(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,velPeak_c(downTrials(9:28)),'rx');
axis([0 40 0 100]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,velPeak(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,velPeak_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,velPeak(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,velPeak_c(downTrials(29:36)),'rx');
axis([0 16 0 100]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'velPeak'])

%% velPeakTime
velPeakTime(wrong_trial == 1) = NaN;

data = outlier_t(velPeakTime(upTrials(1:8))); % Outlier for visual baseline
velPeakTime_c(upTrials(1:8)) = data;
data = outlier_t(velPeakTime(downTrials(1:8)));
velPeakTime_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 exposure trials from outlier scrubbing
velPeakTime_c(upTrials(9:14)) = velPeakTime(upTrials(9:14));
velPeakTime_c(downTrials(9:14)) = velPeakTime(downTrials(9:14));

data = outlier_t(velPeakTime(upTrials(15:28))); % Outlier for last 28 exposure
velPeakTime_c(upTrials(15:28)) = data;
data = outlier_t(velPeakTime(downTrials(15:28)));
velPeakTime_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
velPeakTime_c(upTrials(29:36)) = velPeakTime(upTrials(29:36));
velPeakTime_c(downTrials(29:36)) = velPeakTime(downTrials(29:36));

% transpose and calculate standardized variable
velPeakTime_c = velPeakTime_c';
bkup_mean = nanmean(velPeakTime_c(upTrials(1:8)));
bkup_std = nanstd(velPeakTime_c(upTrials(1:8)));
velPeakTime_up_st = (velPeakTime_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(velPeakTime_c(downTrials(1:8)));
bkdown_std = nanstd(velPeakTime_c(downTrials(1:8)));
velPeakTime_down_st = (velPeakTime_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;

%% Plotting Code for velPeakTime
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),velPeakTime(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),velPeakTime_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),velPeakTime(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),velPeakTime_c(downTrials(1:8)),'rx');
axis([0 16 50 500]); set(gca,'LineWidth',2,'XTick',[1 10 20],'YTick',50:50:500,'YTickLabel', 50:50:500,'FontName','Arial','FontSize',10); ylabel('velPeakTime [ms]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,velPeakTime(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,velPeakTime_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,velPeakTime(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,velPeakTime_c(downTrials(9:28)),'rx');
axis([0 40 50 500]); set(gca,'LineWidth',2,'XTick',[1 20 70 120 140],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,velPeakTime(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,velPeakTime_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,velPeakTime(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,velPeakTime_c(downTrials(29:36)),'rx');
axis([0 16 50 500]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'velPeakTime'])

%% Reaction Time (ms)
for i = 1:numTrials
    if wrong_trial(i) == 0
        RT(i) = onset(i) - sortData(i).EVENTS.TIMES(2)*1000; % Event Code 2 occurs when the targets turn on (measured relative to when hands are statioary in the home positions)
    else
        RT(i) = NaN;
    end
end
RT(wrong_trial == 1) = NaN;

data = outlier_t(RT(upTrials(1:8))); % Outlier for visual baseline
RT_c(upTrials(1:8)) = data;
data = outlier_t(RT(downTrials(1:8)));
RT_c(downTrials(1:8)) = data;
clear data;

% Exclude first 12 exposure from from outlier scrubbing
RT_c(upTrials(9:14)) = RT(upTrials(9:14));
RT_c(downTrials(9:14)) = RT(downTrials(9:14));

data = outlier_t(RT(upTrials(15:28))); % Outlier for last 28 exposure
RT_c(upTrials(15:28)) = data;
data = outlier_t(RT(downTrials(15:28)));
RT_c(downTrials(15:28)) = data;
clear data;

% Exclude ALL of post-exposure from outlier scrubbing
RT_c(upTrials(29:36)) = RT(upTrials(29:36));
RT_c(downTrials(29:36)) = RT(downTrials(29:36));

% transpose and calculate standardized variable
RT_c = RT_c';
bkup_mean = nanmean(RT_c(upTrials(1:8)));
bkup_std = nanstd(RT_c(upTrials(1:8)));
RT_up_st = (RT_c(upTrials) - bkup_mean)/bkup_std;

bkdown_mean = nanmean(RT_c(downTrials(1:8)));
bkdown_std = nanstd(RT_c(downTrials(1:8)));
RT_down_st = (RT_c(downTrials) - bkdown_mean)/bkdown_std;

clear bkup_mean; clear bkup_std; clear bkdown_mean; clear bkdown_std;
RT = RT';

%% Plotting Code for RT
figure
set(gcf,'Color','w','Position',[560 528 600 420])
hold on;

subplot('Position',[0.06 0.2 0.1 0.6]); hold on;
plot(upTrials(1:8),RT(upTrials(1:8)),'bo');
hold on
plot(upTrials(1:8),RT_c(upTrials(1:8)),'bx');
hold on
plot(downTrials(1:8),RT(downTrials(1:8)),'ro');
hold on
plot(downTrials(1:8),RT_c(downTrials(1:8)),'rx');
axis([0 16 0 1000]); set(gca,'LineWidth',2,'XTick',[1 16],'YTick',0:100:1000,'YTickLabel', 0:100:1000,'FontName','Arial','FontSize',10); ylabel('RT [ms]'); title('vis-pre','fontsize',11);

hold on
subplot('Position',[0.23 0.2 0.4 0.6]); hold on;
plot(upTrials(9:28)-exTrials(1)+1,RT(upTrials(9:28)),'bo');
hold on
plot(upTrials(9:28)-exTrials(1)+1,RT_c(upTrials(9:28)),'bx');
hold on
plot(downTrials(9:28)-exTrials(1)+1,RT(downTrials(9:28)),'ro');
hold on
plot(downTrials(9:28)-exTrials(1)+1,RT_c(downTrials(9:28)),'rx');
axis([0 40 0 1000]); set(gca,'LineWidth',2,'XTick',[1 20 40],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);

hold on
subplot('Position',[0.70 0.2 0.24 0.6]); hold on;
plot(upTrials(29:36)-peTrials(1)+1,RT(upTrials(29:36)),'bo');
hold on
plot(upTrials(29:36)-peTrials(1)+1,RT_c(upTrials(29:36)),'bx');
hold on
plot(downTrials(29:36)-peTrials(1)+1,RT(downTrials(29:36)),'ro');
hold on
plot(downTrials(29:36)-peTrials(1)+1,RT_c(downTrials(29:36)),'rx');
axis([0 16 0 1000]); set(gca,'LineWidth',2,'XTick',[1 26],'YTick',[],'YTickLabel',[],'FontName','Arial','FontSize',10); title(['post-exposure'], 'fontsize',11); xlabel('Trials','fontsize',11);
title([subID(7:9), ' ', 'RT'])

%% Movement Path Plots
ang = 0:0.1:2.01*pi;
r_home = sortData(1).TARGET_TABLE.Visual_radius(1); % Home target size
r = sortData(1).TARGET_TABLE.Visual_radius(2); % Target target size
figure
subplot(2,3,1) % Baseline Handpaths
for i = 1:16
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-25 5 -15 15]); set(gca,'LineWidth',2,'XTick',[-25 -10 5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('vis-pre','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(1)+r_home*cos(ang),sortData(1).TARGET_TABLE.Y(1)+r_home*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')

subplot(2,3,3) % Early Exposure (first 12)
for i = 17:28
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-25 5 -15 15]); set(gca,'LineWidth',2,'XTick',[-25 -10 5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Early Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(1)+r_home*cos(ang),sortData(1).TARGET_TABLE.Y(1)+r_home*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')

subplot(2,3,4) % Late Exposure (last 12)
for i = 45:56
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-25 5 -15 15]); set(gca,'LineWidth',2,'XTick',[-25 -10 5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Late Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(1)+r_home*cos(ang),sortData(1).TARGET_TABLE.Y(1)+r_home*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')

subplot(2,3,5) % Early Post-Exposure (first 8)
for i = 57:64
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-25 5 -15 15]); set(gca,'LineWidth',2,'XTick',[-25 -10 5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title('Early Post-Exposure','fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(1)+r_home*cos(ang),sortData(1).TARGET_TABLE.Y(1)+r_home*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')

subplot(2,3,6) % Late Post-Exposure (last 8)
for i = 65:72
    if wrong_trial(i) == 0
        plot(cursorPosX{i,1}(onset(i):offset(i))*100 - Tx, cursorPosY{i,1}(onset(i):offset(i))*100 - Ty)
        hold on
    end
end
axis([-25 5 -15 15]); set(gca,'LineWidth',2,'XTick',[-25 -10 5],'YTick',[-15 -10 0 10 15],'YTickLabel',[-15 -10 0 10 15],'FontName','Arial','FontSize',10); title([subID(7:9),' ','Late Post-Exposure'],'fontsize',11);
axis square
hold on
plot(sortData(1).TARGET_TABLE.X(1)+r_home*cos(ang),sortData(1).TARGET_TABLE.Y(1)+r_home*sin(ang),'Color',[255/255 117/255 56/255]) %home position
hold on
plot(sortData(1).TARGET_TABLE.X(2)+r*cos(ang),sortData(1).TARGET_TABLE.Y(2)+r*sin(ang),'r')
hold on
plot(sortData(1).TARGET_TABLE.X(3)+r*cos(ang),sortData(1).TARGET_TABLE.Y(3)+r*sin(ang),'r')

jhgjkhgjkh
%% Data Export
%switch Directory
if strcmp(str,'MACI64') == 1
    cd(['/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/Post_Step_2']);
else
    cd(['Z:\UURAF Projects/UURAF 2019 Structural Learning and Transfer\Post_Step_2']); % Lab PCs
end

save([subID '_test_postStep2' '.mat'],'sortData','downTrials','upTrials','subID','onset','offset','wrong_trial',...
    'ide', 'ide_c', 'ide_down_st', 'ide_up_st',...
    'mov_int', 'mov_int_c', 'mov_int_down_st', 'mov_int_up_st',...
    'MT', 'MT_c', 'MT_down_st', 'MT_up_st',...
    'norm_jerk', 'norm_jerk_c', 'norm_jerk_down_st', 'norm_jerk_up_st',...
    'rmse', 'rmse_c', 'rmse_down_st', 'rmse_up_st',...
    'velPeak', 'velPeak_c', 'velPeak_down_st', 'velPeak_up_st',...
    'velPeakTime', 'velPeakTime_c', 'velPeakTime_down_st', 'velPeakTime_up_st',...
    'RT', 'RT_c', 'RT_down_st', 'RT_up_st')