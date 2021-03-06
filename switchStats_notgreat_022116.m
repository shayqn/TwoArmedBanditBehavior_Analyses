%% switching stats 02_21_16 by shay

%using pokeHistory which is a  n by 3 matrix where the first column is
%time, the second is which port was poked, and third is the port the
%reward was delivered to. If no reward, this entry is zero. 

%run pokeStats first.
rewardPort = 2;
nonrewardPort = 3;
timevecs = datevec(pokeHistory(:,1));
timenums = datenum(pokeHistory(:,1));
timediffs = etime(timevecs(2:end,:),timevecs(1:end-1,:));
trialBool = zeros(size(pokeHistory,1),1);
trials = zeros(1,3);


%% one attempt
k = 1;
figure
hold on
for i = 2:size(pokeHistory,1)

    if pokeHistory(i-1,2) == 1 && (timediffs(i-1) < 1)
        trials(k,:) = pokeHistory(i,:);
        k = k+1;
        currPoke = pokeHistory(i,2);
        currRewardBool = (pokeHistory(i,3) ~= 0);
        
        if currRewardBool
            plot(timenums(i),currPoke,'.r')
            hold on
        else
            plot(timenums(i),currPoke,'.b')
            hold on
        end
    end
end
datetick('x',13)

%%
figure
trialTimeNums = datenum(trials(:,1));
plot(trialTimeNums,trials(:,2));
datetick('x',13)
title('Pokes')

figure
plot(trialTimeNums,trials(:,3));
datetick('x',13)
title('Rewards')



%% Block 1
j = 1;
rewardBool = trials(3,:) ~= 0;
blockLengthAdd = 0;

for iBlock = 15:15:177
    blockLengthTemp = find(trials(:,3),iBlock,'first');
    blockIndex(j) = blockLengthTemp(end);
    blockLength(j) = blockIndex(j) - blockLengthAdd;
    blockLengthAdd = blockIndex(j);

    rightPokes = trials(:,2) == 2;
    leftPokes = trials(:,2) == 3;
    rightRewards = trials(:,3) == 2;
    leftRewards = trials(:,3) == 3;
    
    if j == 1
        rightFrac(j) = sum(rightPokes(1:blockIndex(j)))/blockIndex(j);
        leftFrac(j) = sum(leftPokes(1:blockIndex(j)))/blockIndex(j);
        rightRewardFrac(j) = sum(rightRewards(1:blockIndex(j)))/15;
        leftRewardFrac(j) = sum(leftRewards(1:blockIndex(j)))/15;
    else
        rightFrac(j) = sum(rightPokes(blockIndex(j-1):blockIndex(j)))/blockLength(j);
        leftFrac(j) = sum(leftPokes(blockIndex(j-1):blockIndex(j)))/blockLength(j);
        rightRewardFrac(j) = sum(rightRewards(blockIndex(j-1):blockIndex(j)))/15;
        leftRewardFrac(j) = sum(leftRewards(blockIndex(j-1):blockIndex(j)))/15;
    end
    j = j+1;
    
    
end

% calculate error trials. for every trial there is a center poke, so to
% calculate error trials, the calculation is size(pokeHistory) - size(trials)*2
numErrorTrials = size(pokeHistory,1) - (size(trials,1)*2);

%% plot that shit

figure
plot(rightFrac,'k')
hold on
plot(leftFrac,'r')
title('Poke Fraction')

figure
plot(rightRewardFrac,'k')
hold on
plot(leftRewardFrac,'r')
title('Reward Fraction')