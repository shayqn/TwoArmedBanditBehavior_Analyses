function [ blockStats ] = calcBlockStats(trials)
%CALCBLOCKSTATS
% blockStats = calcBlockStats(trials)
% Inputs: trials (as calculated by extractTrials)
% Outputs: blockStats is a # of blocks by 4 matrix where:
    %col1 = start point in terms of trials (duration)
    %col2 = blockID (left (2) or right (1))
    %col3 = Mouse's accuracy within the block
    %col4 = Number of errors committed before the first reward
    %col5 = Number of errors committed after first reward
    %col6 = Number of rewards in each block
%NOTE:Deletes the last block of the session if there is more than one block
    %because, since the session can end at any time, the metrics of the last
    %block don't accurately reflect to the mouse's accurate behavior


numTrials = size(trials,1); %usefull to have around.

%% Calculate total number of left and right rewards
%Creates a logic vector for when the correct port was the left one
leftTrialIndices = (trials(:,2) == 2);
%Creates a logic vector for when the correct port was the right one
rightTrialIndices = (trials(:,2) == 1);
%adds up the number of times the mouse received a reward from the left port
leftPortRewards = sum(trials(leftTrialIndices,5));
%adds up the number of times the mouse received a reward from the right port
rightPortRewards = sum(trials(rightTrialIndices,5));
%% Calculate blocks (BlockID)
%initializes matrix
blockID = zeros(numTrials,1);
%initializes matrix with all of the ports chosen
portIndex = trials(:,2);
%initilizes matrix with the probability of the port chosen
probIndex = zeros(numTrials,1);
probIndex(rightTrialIndices) = trials(rightTrialIndices,3);
probIndex(leftTrialIndices) = trials(leftTrialIndices,4);

%iterates over the number of trials performed during this session
for i = 1:numTrials
    if trials(i,3) > trials(i,4)
        blockID(i) = 1;
    else
        blockID(i) = 2;
    end     
end

%% ratio of correct for right blocks vs. left blocks
%calculates the total number of times the left and right ports were set as
%the correct one throughout the duration of the session respectively

%% Create an array of average accuracy for each block
%finds where the blocks changed and matches them up with the trial numbers
blockStarts = find(diff(blockID)) + 1;
%add 1 because the first block start was the first trial, which was not included in the line above
blockStarts = [1;blockStarts];
numBlocks = length(blockStarts);

%% Create an array with the accuracy per block,num errors to first reward, num errors after first reward for left/right

%blockStats will be a matrix of size # blocks by 6 where:
%col1 = start point in terms of trials
%col2 = blockID (left (2) or right (1))
%col3 = Mouse's accuracy within the block
%col4 = Number of trials it takes the mouse to get the first reward
%col5 = Number of errors committed after first reward
%col6 = number of rewards given in the block

blockStats = zeros(length(blockStarts), 6); %initialize matrix

%COL2: fill first col with blockIDs
blockStats(:,2) = blockID(blockStarts);

for i = 1:numBlocks
    %COL3: fills the second column with block accuracy
    %%determining the beginning, end, and duration of the block
    blockBegins = blockStarts(i);
    
    %deal with when i == numBlocks, there is i+1.
    if i == numBlocks
        blockEnds = numTrials;
    else
        blockEnds = blockStarts(i + 1) - 1;
    end
    
    blockDuration = blockBegins:blockEnds;
    blockRewards = sum(trials(blockDuration, 5));
    %blockAccuracy = the number of times the mouse chose the right port /
    %the duration of the block
    accuracyMatrix = (blockID(blockDuration) == trials(blockDuration,2));
    blockAccuracy = sum(accuracyMatrix) / length(blockDuration);
    
    %Adds the accuracy over the course of each block to the matrix
    blockStats(i,3) = blockAccuracy;
    %COL1: fills the first column with the range of the block
    %first col will be the range of trials in this block [start,end]
    blockStats(i,1) = blockBegins;
    
    
    
    %COL4: fills the fourth column with num of trials before reward
    firstReward = find(trials(blockDuration, 5) == 1, 1);
    %Adds the instance of the first reward over the course of each block to
    %the matrix
    %Shay - added a conditional statement to handle the case where there
    %were no rewards awarded in the block (this happens, for example, if
    %the last block was only a couple trials long).
    if isempty(firstReward)
        blockStats(i,4) = nan;
    else
        blockStats(i,4) = firstReward-1;
    end
    
    
    %COL5: fills the fourth column with the num of incorrect trials after
    %the first reward
    durationPostFirst = (blockBegins + firstReward):blockEnds;
    accuracyMatrixPostFirst = (blockID(durationPostFirst) == trials(durationPostFirst,2));
    incorrectTrialsPostFirst = sum(accuracyMatrixPostFirst == 0);
    %%incorrectTrialsPostFirst = sum(trials(durationPostFirst,4) == 0);
    %Adds the number of incorrect trials over the course of the block to
    %the matrix
    blockStats(i,5) = incorrectTrialsPostFirst;
    
    %&COL6: fills the sixth column witht he num of rewards in each block
    blockStats(i,6) = blockRewards;
    
    %Deletes the last block of the session if there is more than one block
    %because, since the session can end at any time, the metrics of the last
    %block don't accurately reflect to the mouse's accurate behavior
    if numBlocks>1
        blockStats = blockStats(1:numBlocks-1,:);
    end
    
   
end

end

