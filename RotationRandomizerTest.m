% A version of this function is used in the KINARM Simulink model for the
% UURAF 2019 Structural Learning and Transfer task. The goal is to generate
% a random number within some limit (in this case [-90 90]), EXCLUDING
% those numbers that fall within range of the test rotation (60) and its
% inverse (-60). See Braun 2009 or Bond & Taylor 2017.
clear all; close all;

%% Pseudorandomizer Code used in Simulink Model
%clear all; close all;
num_sim = 240; % Number of simulations to run
rotation_test = zeros(num_sim,1); % Initalize array used to visualize simulation result
rotate_type = 3; % Force the randomizer
rotation_amount = 90; % Range of structure
block_size = 4; % Number of consecutive trials at a given randomized value
test_angle = 60; % Angle around which "exclude_range" prevents generation of values
exclude_range = 10; %excludes angles +/1 10 from the test_angle, which is 60 in this experiment 
for i = 1:num_sim
    rotation_test(i) = Calculate_Desired_Rotation(i, rotate_type, rotation_amount, block_size, test_angle, exclude_range);
end
histogram(rotation_test,[-rotation_amount:exclude_range:rotation_amount]) % Visualize result of simulation

%Note: You can see the first code section has numeric entries that must match the TP table and Task Wide Parameters table in Dexterit-E. The numbers in there right now match my experiments (block size = 4, test angle +/-60, exclude range +/-10)

%% Collect some data using KINARM and test the rotations!
clear all; close all;
fname = 'STRUCT_STR_01_train.zip'; % You must use this name for the exported data from database
unZip = zip_load(fname);
data = unZip.c3d;
filename = unZip.filename;
rawData = KINARM_add_hand_kinematics(data(:)); % this adds kinematics to c3d files
filtData = c3d_filter_dblpass(rawData, 'enhanced', 'fc', 10, 'fs', 1000); % 'fc' = cutoff freq, 'fs' = sample rate (don't change fs)
numTrials = size(rawData,1); % Number of Trials

% Find trial numbers
trialNumber = zeros(numTrials,1);
for i = 1:numTrials
    trialNumber(i) = filtData(i).TRIAL.TRIAL_NUM;
end

% Find correct trial order
trialOrder = zeros(numTrials,1);
for i = 1:numTrials
    trialOrder(i) = find(trialNumber == i);
end
% reorders the data to reflect trial number, not TP number
for i = 1:numTrials
    sortData(i) = filtData(trialOrder(i));
end
sortData = sortData';

for i = 1:numTrials
    angles(i) = sortData(i).rotation_amount(end);
end
angles = angles';
% Plot only the exposure trials (which is 17:256 in this study)
histogram(angles(17:256),[-90:10:90]) % NOTE: the binning must match the range of the rotations (-90 - +90 in this study) (TP Table "Rotation") and excluding range (which is +/1 10 in this study) (Task Wide Parameters "exclude_range")

% Plot Time-Series of rotation schedule
figure
plot(angles, 'LineWidth', 2.5)
xlabel('Trial Number', 'FontSize', 20, 'FontWeight', 'bold')
ylabel('Rotation Amount (deg)', 'FontSize', 20, 'FontWeight', 'bold')
% 
% for i = 1:numTrials
%     figure(i)
%     plot(sortData(i).rotation_amount);
%     ylim([-90 90])
% end