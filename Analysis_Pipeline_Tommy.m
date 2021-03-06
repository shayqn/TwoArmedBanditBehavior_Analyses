% Behavior Analysis Pipeline

%% Load in the data (speficially the stats data structure)
[fileName,pathName] = uigetfile('MultiSelect','on');
cd(pathName);
for i = 1:length(fileName)
    load(fileName{i});
end

%% Extract Trials and plot
trials = extractTrials(stats,pokeHistory);

%% calculate block stats
blockStats = calcBlockStats(trials);
%sessionStats = calcSession(blockStats);
sessionStats = calcSessionStats;