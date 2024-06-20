function rotation = Calculate_Desired_Rotation(trial_num, rotate_type, rotation_amount, block_size, test_angle, exclude_range)
% This block supports an embeddable subset of the MATLAB language.
% See the help menu for details.

%This block was modified by IEB, Sept 24, 2008
%It updates the desired amount of rotation

% NOTE ALL ROTATIONS ARE CURRENTLY IN DEGREES IN THE FUNCTION

% create a persistent variable to remember the rotation amount from one time-step to the next
persistent rotation_memory

if isempty(rotation_memory), rotation_memory = 0; end

if rotate_type == 0
    %set the rotation = 0
    rotation = 0;
elseif rotate_type ==1
    %set the rotation = specified amount
    rotation = rotation_amount;
elseif rotate_type == 2
    %set the rotation to change by specified amount
    rotation = rotation_memory + rotation_amount;
elseif rotate_type ==3
    %set the rotation = a random integer between +/- specified amount
    if mod(trial_num,block_size)-1 == 0 % if you hit a trial which occupies a new block of 'block_size' trials (specified in TP table), generate a new random rotation
        rotation = -randi([-rotation_amount rotation_amount],1); % Generate random integer within range
        while rotation >= -(test_angle+exclude_range) && rotation <= -(test_angle-exclude_range) || rotation >= (test_angle-exclude_range) && rotation <= (test_angle+exclude_range) % Keep generating random numbers if those previously calculted fall too close to test rotation
            rotation = randi([-rotation_amount rotation_amount],1);
        end
    else % else you maintain the current block's rotation amount
        rotation = rotation_memory;
    end
else
    %do nothing
    rotation = rotation_memory;
end

% save the rotation amount for the next time-step
rotation_memory = rotation;