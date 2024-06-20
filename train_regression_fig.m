clear all; close all;
%% File import
% This will read in all files from the specified folder. NOTE: if an ".xdf"
% files exists in the folder, it will be included in the exported
% dataframe!
if strcmp(computer, 'MACI64')
    cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper/Post_Step_2_resub')
    files = dir('*train*');
else
    %cd('Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\struct_learn_paper\Post_Step_2_resub') % Z-drive
    cd('C:\Users\Alex\Desktop\STRXFER training plots\Post_Step_2_resub') % Local
    files = dir('*train*');
end

%% Load in Data
    vbTrials = 1:16;
    exTrials = 17:256;
    peTrials = 257:272;
    numTrials = 272;
    rot = zeros(numTrials,3);
    ihd = zeros(numTrials,3);
    k = 1; % Column indexer for rot and initial hand direction (ihd) matricies
for i = [5 3 6]
    % Load in subject data
    if strcmp(computer, 'MACI64')
        cd('/Volumes/mnl/Data/UURAF Projects/UURAF 2019 Structural Learning and Transfer/struct_learn_paper/Post_Step_2_resub')
        load(files(i).name);
    else
        %cd('Z:\Data\UURAF Projects\UURAF 2019 Structural Learning and Transfer\struct_learn_paper\Post_Step_2_resub') % Z-drive
        cd('C:\Users\Alex\Desktop\STRXFER training plots\Post_Step_2_resub') % Local
        load(files(i).name);
    end
    
    % re-calculate theta (not saved over from step 2)

    for j = 1:numTrials
        rot(j,k) = sortData(j).rotation_amount(1); % Change to theta after this loop runs
    end
    % fix issue with index shift
    theta(:,k) = rot(:,k);
    theta(peTrials,k) = 0;
    theta(exTrials,k) = theta(exTrials+1,k);
    theta(256,k) = theta(255,k);
    theta(end,k) = 0;
    
    ihd(:,k) = theta(:,k) - ide;
    k = k+1; % inc the indexer to next column
end

%% Plots
t = tiledlayout(3,1);
ylabel(t,'Angle (deg)', 'FontSize', 20)
xlabel(t,'Trial', 'FontSize', 20)

% Tile 1
nexttile
plot(theta(:,1),'LineWidth',2); hold on; plot(ihd(:,1),'.r', 'MarkerSize',15)
xlim([0 272])
ylim([-200 200])
% Tile 2
nexttile
plot(theta(:,2),'LineWidth',2); hold on; plot(ihd(:,2),'.r', 'MarkerSize',15)
xlim([0 272])
ylim([-200 200])
% Tile 3
nexttile
plot(theta(:,3),'LineWidth',2); hold on; plot(ihd(:,3),'.r', 'MarkerSize',15)
xlim([0 272])
ylim([-200 200])