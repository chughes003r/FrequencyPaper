%code to count reported percepts from comments on surveys

%this code has to be run for each frequency of surveys separately

%% Loading data and initializing variables 
load('channel_percepts.mat')
load('channel_stim.mat')

%set data of interest
normalize_input = inputdialog({'20 Hz', '100 Hz', '300 Hz'}, 'Which frequency would you like to plot?');
if strcmp(normalize_input, '20 Hz')
    channel_percepts = channel_percepts_20;
    channel_stim = channel_stim_20;
elseif strcmp(normalize_input, '100 Hz')
    channel_percepts = channel_percepts_100;
    channel_stim = channel_stim_100;
elseif strcmp(normalize_input, '300 Hz')
    channel_percepts = channel_percepts_300;
    channel_stim = channel_stim_300;
end



clear low_percepts mid_percepts high_percepts 
%set percept names
int_percepts = {'tingle', 'pressure', 'warm', 'sharp', 'vibration', [], [], 'spark', 'touch', []}; %removed the percepts with their own algorithms to remove repeats
percept_ch = zeros(size(channel_percepts,2), 10);

%these were supposed to only be the ones that were "significantly"
%modulated
low = [2 12 42 49 63];
middle = [14 16 19 22 26 54 58];
high = [3 8 13 20 34 36 41 45];

%% Counting percepts by report

% percept_ch will contain the counts for each percept (columns) across all
% channels (rows) for all included surveys

%would be good to have some count of how many times the electrode was
%tested or actually had an induced percept

% percept_stim counts all channels on all surveys individually (size on
% vertical dimension will be # of surveys multipled by channels

% percept_stim_ch will contain the corresponding channels for the percept_stim

% percept_stim_pref indicates the frequency preference of the channels in
% percept_stim_ch

%if there is a known frequency preference, the perference will be saved to
%groups_chi and the quality information will be saved to percepts_chi for
%statistical testing

%% This first part will simply find how many times each electrode had any percept reported
% This will be used to calculate the ratio of times a certain percept was
% reported
emptyCells = cellfun(@isempty,channel_percepts);
percept_cnt = sum(~emptyCells, 1)';

%alternative where we consider how many times each was stimulated
stim_cnt = sum(channel_stim,1)';

%% This part will then calculate how many times each percept was reported on each channel
clear percept_stim percept_stim_pref percept_stim_both percept_stim_ch
percept_stim = zeros(size(channel_percepts, 1)*size(channel_percepts, 2), length(int_percepts));
cnt = 1;
cnt2 = 1;
% for tingle, pressure, warm, sharp, vibration, sparkly, touch
for survey = 1:size(channel_percepts, 1)
    for chan = 1:size(channel_percepts, 2)
        for percept = 1:length(int_percepts) 
            if ~isempty(channel_percepts{survey,chan}) && ~isempty(int_percepts{percept})
                if contains(channel_percepts{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                    percept_ch(chan,percept) = percept_ch(chan,percept) + 1; %don't need trig when there is only one possibility
                    percept_stim(cnt,percept) = 1; %this was added to keep track of all stimuli individually
                end
            end
        end
        cnt = cnt + 1; %this will iterate by total stimuli instead of overlapping the same channels from different surveys
    end
end

%Drilly-buzzy
cnt = 1;
int_percepts = {'buzz', 'drill'};
for survey = 1:size(channel_percepts, 1) %number of surveys included
    for chan = 1:size(channel_percepts, 2) %number of channels
        trig = 0;
        for percept = 1:length(int_percepts) %number of possible reports
            if ~isempty(channel_percepts{survey,chan})
                if contains(channel_percepts{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                    trig = 1; %trig used so we don't double count percepts
                    percept_stim(cnt,6) = 1; %this was added to keep track of all stimuli individually
                end
            end
        end
        if trig
            percept_ch(chan,6) = percept_ch(chan,6) + 1; %always going to be placed at 6 because that is where "drilly buzzy" sensations are recorded
        end
        cnt = cnt + 1;
    end
end

%Pin-pointy
cnt = 1;
int_percepts = {'pin-point','pinpoint', 'prick', 'pin point', 'pok'};
for survey = 1:size(channel_percepts, 1)
    for chan = 1:size(channel_percepts, 2)
        trig = 0;
        for percept = 1:length(int_percepts)
            if ~isempty(channel_percepts{survey,chan})
                if contains(channel_percepts{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                    trig = 1;
                    percept_stim(cnt,10) = 1; %this was added to keep track of all stimuli individually
                end
            end
        end
        if trig
            percept_ch(chan,10) = percept_ch(chan,10) + 1; %always going to be placed at 10 because that is where "pin-point" sensations are recorded
        end
        cnt = cnt + 1;
    end
end

%Rapid tapping/pulsing
cnt = 1;
int_percepts = {'tapp', 'puls'};
for survey = 1:size(channel_percepts, 1)
    for chan = 1:size(channel_percepts, 2)
        trig = 0;
        for percept = 1:length(int_percepts)
            if ~isempty(channel_percepts{survey,chan})
                if contains(channel_percepts{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                    trig = 1;
                    percept_stim(cnt,7) = 1; %this was added to keep track of all stimuli individually
                end
            end
        end
        if trig
            percept_ch(chan,7) = percept_ch(chan,7) + 1; %always going to be placed at 7 because that is where "rapid tappy" sensations are recorded
        end
        cnt = cnt + 1;
    end
end

%% dividing percept reports by frequency preference and plotting
%finds all percepts for the selected channels
low_percepts = percept_ch(low,:);
mid_percepts = percept_ch(middle,:);
high_percepts = percept_ch(high,:);

%sums percepts across all channels 
low_percepts_sum = nansum(low_percepts, 1);
mid_percepts_sum = nansum(mid_percepts, 1);
high_percepts_sum = nansum(high_percepts, 1);

%alternative using how many times things were stim'd
percepts_size{2} = sum(stim_cnt(low));
percepts_size{1} = sum(stim_cnt(middle));
percepts_size{3} = sum(stim_cnt(high));

percepts_sum = [(mid_percepts_sum/percepts_size{1})', (low_percepts_sum/percepts_size{2})', (high_percepts_sum/percepts_size{3})'];

%make a spider plot
figure
int_percepts = {'Tingle', 'Pressure', 'Warm', 'Sharp', 'Vibration', 'Buzzing', 'Tapping',  'Sparkle', 'Touch', 'Prick'};
%array has to be organized in weird way for this function
legend_str = {'IFP', 'LFP', 'HFP'};
spider_plot((percepts_sum)', int_percepts, 10, 2, legend_str)
%cd('R:\users\clh180\Project data and analysis\Paper Mag Est\Figures\Qualities') 

%% Statistics
for quality = 1:length(int_percepts)
    tbl{quality}(1,:) = sum([percept_ch(low,quality), stim_cnt(low)-percept_ch(low,quality)], 1);
    tbl{quality}(2,:) = sum([percept_ch(middle,quality), stim_cnt(middle)-percept_ch(middle,quality)], 1);
    tbl{quality}(3,:) = sum([percept_ch(high,quality), stim_cnt(high)-percept_ch(high,quality)], 1);
end

%fishers exact test for all groups
for quality = 1:size(tbl,2)
    [h(quality), p(quality)] = FisherExactTest(tbl{quality});
end
p(p>1) = 1;
h = fdr_bh(p); %correct for multiple comparisons

%fisher's exact test for post hoc
for quality = 1:length(tbl)
    if size(tbl{quality},2) > 1
        %compare low to int
        x = table([tbl{quality}(1,1);tbl{quality}(2,1)],[tbl{quality}(1,2);tbl{quality}(2,2)], 'VariableNames', {'Sensation', 'NoSensation'});
        [h2(1,quality), p2(1,quality), stats{1,quality}] = fishertest(x);
        %compare low to high
        x = table([tbl{quality}(1,1);tbl{quality}(3,1)],[tbl{quality}(1,2);tbl{quality}(3,2)], 'VariableNames', {'Sensation', 'NoSensation'});
        [h2(2,quality), p2(2,quality), stats{2,quality}] = fishertest(x);
        %compare int to high
        x = table([tbl{quality}(2,1);tbl{quality}(3,1)],[tbl{quality}(2,2);tbl{quality}(3,2)], 'VariableNames', {'Sensation', 'NoSensation'});
        [h2(3,quality), p2(3,quality), stats{3,quality}] = fishertest(x);
    end
end
    