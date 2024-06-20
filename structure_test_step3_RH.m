% This program save data to do MANOVA analysis
clear all
close all

% Select the subject file
str = computer;
if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/Post_Step_2_RH');
else
    cd('Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\Post_Step_2_RH'); % Lab PCs
end

dir_list = dir('*test*.mat');    %Store subject *mat data file names in variable (struct array).

dir_list = {dir_list.name}; % filenames
dir_list = sort(dir_list);  % sorts files

A2 = length(dir_list);      % how many files to process?

numTrials = 72;
tstamp_start=zeros(numTrials,1); % allocate space
tstamp_end=zeros(numTrials,1);
target_theta = zeros(numTrials,1);
MT_st = zeros(numTrials,1);
rmse_st = zeros(numTrials,1);
ide_st = zeros(numTrials,1);
norm_jerk_st = zeros(numTrials,1);
mov_int_st = zeros(numTrials,1);
velPeak_st = zeros(numTrials,1);
velPeakTime_st = zeros(numTrials,1);
RT_st = zeros(numTrials,1);


for B = 1:1:A2
   load(char(dir_list(B)));
   subject1 = str2num(subID(12:14));
   if strcmp(subID(8:10),'CON') == 1
       group1 = 1;
   elseif strcmp(subID(8:10),'STR') == 1
       group1 = 2;
   else
       error('Group not assigned, check filename for correct naming convention')
   end
       
   
   for trials = 1:1:numTrials
       subject2(trials,:)=subject1;
       group2(trials,:)=group1;
       if wrong_trial(trials) == 0
           tstamp_start(trials,:) = sortData(trials).Right_FS_TimeStamp(onset(trials)); %pulls timestamp of movement onset from time matrix
           tstamp_end(trials,:) = sortData(trials).Right_FS_TimeStamp(offset(trials));  %pulls timestamp of movement offset from time matrix
           end_X_pos(trials) = sortData(trials).Left_HandX(offset(trials));
           end_Y_pos(trials) = sortData(trials).Left_HandY(offset(trials));
       else
           tstamp_start(trials) = NaN; % if trial thrown out, set all to NaN
           tstamp_end(trials) = NaN;
           end_X_pos(trials) = NaN;
           end_Y_pos(trials) = NaN;
       end
   end
   trial = [1:1:numTrials]';
   
   target_theta(downTrials) = 3*pi/2;
   target_theta(upTrials) = pi/2;
   MT_st(downTrials) = MT_down_st;
   MT_st(upTrials) = MT_up_st;
   rmse_st(downTrials) = rmse_down_st;
   rmse_st(upTrials) = rmse_up_st;
   ide_st(downTrials) = ide_down_st;
   ide_st(upTrials) = ide_up_st;
   norm_jerk_st(downTrials) = norm_jerk_down_st;
   norm_jerk_st(upTrials) = norm_jerk_up_st;
   mov_int_st(downTrials) = mov_int_down_st;
   mov_int_st(upTrials) = mov_int_up_st;
   velPeak_st(downTrials) = velPeak_down_st;
   velPeak_st(upTrials) = velPeak_up_st;
   velPeakTime_st(downTrials) = velPeakTime_down_st;
   velPeakTime_st(upTrials) = velPeakTime_up_st;
   RT_st(downTrials) = RT_down_st;
   RT_st(upTrials) = RT_up_st;

ALL_subjects=[group2 subject2 trial target_theta...
    MT MT_c MT_st...
    rmse rmse_c rmse_st...
    ide ide_c ide_st...
    norm_jerk norm_jerk_c norm_jerk_st...
    mov_int mov_int_c mov_int_st...
    end_X_pos' end_Y_pos'...
    tstamp_start tstamp_end...
    velPeak velPeak_c velPeak_st...
    velPeakTime velPeakTime_c velPeakTime_st...
    RT RT_c RT_st...
    wrong_trial]; %You store the current matrix

if strcmp(str,'MACI64') == 1
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/Post_Step_3_RH');
    dlmwrite('test_raw', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/Post_Step_2_RH');
else
    cd(['Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\Post_Step_3_RH']); % Lab PCs
    dlmwrite('test_raw', ALL_subjects, '-append', 'delimiter', ',', 'precision','%.6f');
    cd(['Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\Post_Step_2_RH']); % Lab PCs
end
% the notation '%.6f' writes each variable out to six decimal places, should get rid of engineering notation

end