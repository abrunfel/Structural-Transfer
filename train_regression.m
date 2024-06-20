clear all; close all;
%% File import
% This will read in all files from the specified folder. NOTE: if an ".xdf"
% files exists in the folder, it will be included in the exported
% dataframe!
if strcmp(computer, 'MACI64')
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper/Post_Step_2_resub')
    files = dir('*train*');
else
    cd('\\35.8.175.161\mnl\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\struct_learn_paper\Post_Step_2_resub') % Z-drive
    files = dir('*train*');
end

%% Regressions
% To quantify learning during the exposure to the random rotations in the
% training phase, we are adapting a technique from Bond & Taylor, 2017. We
% regress the outcome variable (IDE, RMSE, etc...) on the rotation amount
% during the first 40 and last 40 trials of exposure (exact number subject
% to change).
earlyTrials = 17:56;
lateTrials = 217:256;

for i = 1:length(files)
%for i = 5
    % Load in subject data
    if strcmp(computer, 'MACI64')
        cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper/Post_Step_2_resub')
        load(files(i).name);
    else
        cd('\\35.8.175.161\mnl\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\struct_learn_paper\Post_Step_2_resub') % Z-drive
        load(files(i).name);
    end
  
    % re-calculate theta (not saved over from step 2)
    vbTrials = 1:16;
    exTrials = 17:256;
    peTrials = 257:272;
    numTrials = length(ide);
    rot = zeros(numTrials,1);
    for j = 1:numTrials
        rot(j) = sortData(j).rotation_amount(1); % Change to theta after this loop runs
    end
    % fix issue with index shift
    theta = rot;
    theta(peTrials) = 0;
    theta(exTrials) = theta(exTrials+1);
    theta(256) = theta(255);
    theta(end) = 0;

    % Perform linear model fits
    lm.ide = fitlm(theta(exTrials), theta(exTrials)-ide(exTrials)); % NOTE: we are taking theta-ide to regress hand direction at peak velocity into theta. See labbook 12/8/22 !!! (on OneDrive)
    lm.ide_early = fitlm(theta(earlyTrials), theta(earlyTrials)-ide((earlyTrials)));
    lm.ide_late = fitlm(theta(lateTrials), theta(lateTrials)-ide((lateTrials)));
    
    lm.rmse = fitlm(theta(exTrials), fbrmse(exTrials));
    lm.rmse_early = fitlm(theta(earlyTrials), fbrmse((earlyTrials)));
    lm.rmse_late = fitlm(theta(lateTrials), fbrmse((lateTrials)));
    
    lm.MT = fitlm(theta(exTrials), fbMT(exTrials));
    lm.MT_early = fitlm(theta(earlyTrials), fbMT((earlyTrials)));
    lm.MT_late = fitlm(theta(lateTrials), fbMT((lateTrials)));
    
    lm.mov_int = fitlm(theta(exTrials), fbmov_int(exTrials));
    lm.mov_int_early = fitlm(theta(earlyTrials), fbmov_int((earlyTrials)));
    lm.mov_int_late = fitlm(theta(lateTrials), fbmov_int((lateTrials)));
    
    lm.norm_jerk = fitlm(theta(exTrials), fbnorm_jerk(exTrials));
    lm.norm_jerk_early = fitlm(theta(earlyTrials), fbnorm_jerk((earlyTrials)));
    lm.norm_jerk_late = fitlm(theta(lateTrials), fbnorm_jerk((lateTrials)));
    
    % Create new dataframe with subject id number, Beta coefficients, and its
    % associated pValue.
    regData = [str2num(subID(12:13)) lm.ide.Coefficients.Estimate(2), lm.ide.Coefficients.pValue(2),...
        lm.rmse.Coefficients.Estimate(2), lm.rmse.Coefficients.pValue(2),...
        lm.MT.Coefficients.Estimate(2), lm.MT.Coefficients.pValue(2),...
        lm.mov_int.Coefficients.Estimate(2), lm.mov_int.Coefficients.pValue(2),...
        lm.norm_jerk.Coefficients.Estimate(2), lm.norm_jerk.Coefficients.pValue(2)];
    
    % Create a new dataframe with subject id number, time (early = 1; late =
    % 2), Beta coefficient, and its associate pValue.
    regDataEL = [str2num(subID(12:13)) 1 lm.ide_early.Coefficients.Estimate(2), lm.ide_early.Coefficients.pValue(2),...
        lm.rmse_early.Coefficients.Estimate(2), lm.rmse_early.Coefficients.pValue(2),...
        lm.MT_early.Coefficients.Estimate(2), lm.MT_early.Coefficients.pValue(2),...
        lm.mov_int_early.Coefficients.Estimate(2), lm.mov_int_early.Coefficients.pValue(2),...
        lm.norm_jerk_early.Coefficients.Estimate(2), lm.norm_jerk_early.Coefficients.pValue(2);...
        str2num(subID(12:13)) 2 lm.ide_late.Coefficients.Estimate(2) lm.ide_late.Coefficients.pValue(2),...
        lm.rmse_late.Coefficients.Estimate(2) lm.rmse_late.Coefficients.pValue(2),...
        lm.MT_late.Coefficients.Estimate(2) lm.MT_late.Coefficients.pValue(2),...
        lm.mov_int_late.Coefficients.Estimate(2) lm.mov_int_late.Coefficients.pValue(2),...
        lm.norm_jerk_late.Coefficients.Estimate(2) lm.norm_jerk_late.Coefficients.pValue(2)];
    %% Save data to file
    asdkfjagaegaega % hard break so you don't override existing data.
    if strcmp(computer,'MACI64') == 1
        cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper') % Mac
    else
        cd('\\35.8.175.161\mnl\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\struct_learn_paper') % Z-drive PC
    end
    writematrix(regData,'regData.xls','WriteMode','append')
    writematrix(regDataEL,'regDataEL.xls','WriteMode','append')
end