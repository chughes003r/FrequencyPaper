dbstop if error

% alternative to plot by frequency 
%code to count reported percepts from comments on surveys

%this code has to be run for each frequency of surveys separately

%% Loading data and initializing variables
%load in data
%load('R:\users\clh180\Project data and analysis\Paper Mag Est\channel_percepts')
load('P:\users\clh180\Project data and analysis\Magnitude Estimation\Qualities\channel_percepts')
load('P:\users\clh180\Project data and analysis\Magnitude Estimation\Qualities\channel_stim')

%set data of interest
%these were supposed to only be the ones that were "significantly"
%modulated
low = [2 12 15 42 49 63];
middle = [14 16 19 22 26 54 58];
high = [3 8 13 20 34 36 41 45];

channel_percepts_all{1} = channel_percepts_20;
channel_percepts_all{2} = channel_percepts_100;
channel_percepts_all{3} = channel_percepts_300;

channel_stim_all{1} = channel_stim_20;
channel_stim_all{2} = channel_stim_100;
channel_stim_all{3} = channel_stim_300;

for curr_perc = 1:3 %3 different frequencies
    channel_percepts_low{curr_perc} = channel_percepts_all{curr_perc}(:,low);
    channel_percepts_mid{curr_perc} = channel_percepts_all{curr_perc}(:,middle);
    channel_percepts_high{curr_perc} = channel_percepts_all{curr_perc}(:,high);
    channel_stim_low{curr_perc} = channel_stim_all{curr_perc}(:,low);
    channel_stim_mid{curr_perc} = channel_stim_all{curr_perc}(:,middle);
    channel_stim_high{curr_perc} = channel_stim_all{curr_perc}(:,high);
end

normalize_input = inputdialog({'Low frequency preferring', 'Intermediate frequency preferring', 'High frequency preferring'}, 'Which electrode type would you like to plot?');
if strcmp(normalize_input, 'Low frequency preferring')
    channel_percepts = channel_percepts_low;
    channel_stim = channel_stim_low;
elseif strcmp(normalize_input, 'Intermediate frequency preferring')
    channel_percepts = channel_percepts_mid;
    channel_stim = channel_stim_mid;
elseif strcmp(normalize_input, 'High frequency preferring')
    channel_percepts = channel_percepts_high;
    channel_stim = channel_stim_high;
end

%if we want to combine across types, can just add all together
% for curr_freq = 1:3
%     channel_percepts{curr_freq} = [channel_percepts_low{curr_freq}, channel_percepts_mid{curr_freq}, channel_percepts_high{curr_freq}];
%     channel_stim{curr_freq} = [channel_stim_low{curr_freq}, channel_stim_mid{curr_freq}, channel_stim_high{curr_freq}];
% end

clear low_percepts mid_percepts high_percepts 
%set percept names
int_percepts = {'tingle', 'pressure', 'warm', 'sharp', 'vibration', [], [], 'spark', 'touch', []}; %removed the percepts with their own algorithms to remove repeats
%percept_ch = zeros(size(channel_percepts,2), 10);

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

%alternative where we consider how many times each was stimulated
for curr_perc = 1:3
    stim_cnt(curr_perc,:) = sum(channel_stim{curr_perc},1);
end

%% This part will then calculate how many times each percept was reported on each channel
clear percept_stim percept_stim_pref percept_stim_both percept_stim_ch
%percept_stim = zeros(size(channel_percepts, 1)*size(channel_percepts, 2), length(int_percepts));
cnt = 1;
cnt2 = 1;
% for tingle, pressure, warm, sharp, vibration, sparkly, touch
for curr_freq = 1:length(channel_percepts)
    percept_ch{curr_freq} = zeros(size(channel_percepts{curr_freq},2), 10);
    for survey = 1:size(channel_percepts{curr_freq}, 1)
        for chan = 1:size(channel_percepts{curr_freq}, 2)
            for percept = 1:length(int_percepts) 
                if ~isempty(channel_percepts{curr_freq}{survey,chan}) && ~isempty(int_percepts{percept})
                    if contains(channel_percepts{curr_freq}{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                        percept_ch{curr_freq}(chan,percept) = percept_ch{curr_freq}(chan,percept) + 1; %don't need trig when there is only one possibility
                        percept_stim{curr_freq}(cnt,percept) = 1; %this was added to keep track of all stimuli individually
                    end
                end
            end
            cnt = cnt + 1; %this will iterate by total stimuli instead of overlapping the same channels from different surveys
        end
    end
end

%need to make same changes to the rest of the code

%Drilly-buzzy
cnt = 1;
int_percepts = {'buzz', 'drill'};
for curr_freq = 1:length(channel_percepts)
    for survey = 1:size(channel_percepts{curr_freq}, 1)
        for chan = 1:size(channel_percepts{curr_freq}, 2)
            trig = 0;
            for percept = 1:length(int_percepts) 
                if ~isempty(channel_percepts{curr_freq}{survey,chan}) && ~isempty(int_percepts{percept})
                    if contains(channel_percepts{curr_freq}{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                        trig = 1;
                        percept_stim{curr_freq}(cnt,6) = 1; %this was added to keep track of all stimuli individually
                    end
                end
            end
            if trig
                percept_ch{curr_freq}(chan,6) = percept_ch{curr_freq}(chan,6) + 1; %don't need trig when there is only one possibility
            end
            cnt = cnt + 1; %this will iterate by total stimuli instead of overlapping the same channels from different surveys
        end
    end
end

%Pin-pointy
cnt = 1;
int_percepts = {'pin-point','pinpoint', 'prick', 'pin point', 'pok'};
for curr_freq = 1:length(channel_percepts)
    for survey = 1:size(channel_percepts{curr_freq}, 1)
        for chan = 1:size(channel_percepts{curr_freq}, 2)
            trig = 0;
            for percept = 1:length(int_percepts) 
                if ~isempty(channel_percepts{curr_freq}{survey,chan}) && ~isempty(int_percepts{percept})
                    if contains(channel_percepts{curr_freq}{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                        trig = 1;
                        percept_stim{curr_freq}(cnt,10) = 1; %this was added to keep track of all stimuli individually
                    end
                end
            end
            if trig
                percept_ch{curr_freq}(chan,10) = percept_ch{curr_freq}(chan,10) + 1; %don't need trig when there is only one possibility
            end
            cnt = cnt + 1; %this will iterate by total stimuli instead of overlapping the same channels from different surveys
        end
    end
end

%Rapid tapping/pulsing
cnt = 1;
int_percepts = {'tapp', 'puls'};
for curr_freq = 1:length(channel_percepts)
    for survey = 1:size(channel_percepts{curr_freq}, 1)
        for chan = 1:size(channel_percepts{curr_freq}, 2)
            trig = 0;
            for percept = 1:length(int_percepts) 
                if ~isempty(channel_percepts{curr_freq}{survey,chan}) && ~isempty(int_percepts{percept})
                    if contains(channel_percepts{curr_freq}{survey,chan}, int_percepts(percept), 'IgnoreCase', true)
                        trig = 1;
                        percept_stim{curr_freq}(cnt,7) = 1; %this was added to keep track of all stimuli individually
                    end
                end
            end
            if trig
                percept_ch{curr_freq}(chan,7) = percept_ch{curr_freq}(chan,7) + 1; %don't need trig when there is only one possibility
            end
            cnt = cnt + 1; %this will iterate by total stimuli instead of overlapping the same channels from different surveys
        end
    end
end

%% dividing percept reports by frequency preference and plotting
%finds all percepts for the selected channels
low_freq = percept_ch{1};
mid_freq = percept_ch{2};
high_freq = percept_ch{3};

%sums percepts across all channels 
low_freq_sum = nansum(low_freq, 1);
mid_freq_sum = nansum(mid_freq, 1);
high_freq_sum = nansum(high_freq, 1);

%amount a percept was reported for each group
% percepts_size{1} = sum(percept_cnt(low));
% percepts_size{2} = sum(percept_cnt(middle));
% percepts_size{3} = sum(percept_cnt(high));

%alternative using how many times things were stim'd
percepts_size{1} = sum(stim_cnt(1,:));
percepts_size{2} = sum(stim_cnt(2,:));
percepts_size{3} = sum(stim_cnt(3,:));

percepts_sum = [(low_freq_sum/percepts_size{1})', (mid_freq_sum/percepts_size{2})', (high_freq_sum/percepts_size{3})'];

%make a spider plot
figure
int_percepts = {'Tingle*', 'Pressure*', 'Warm', 'Sharp', 'Vibration', 'Buzzing', 'Tapping',  'Sparkle', 'Touch', 'Prick*'};
%array has to be organized in weird way for this function
legend_str = {'20 Hz', '100 Hz', '300 Hz'};
spider_plot((percepts_sum)', int_percepts, 10, 2, legend_str)
%cd('R:\users\clh180\Project data and analysis\Paper Mag Est\Figures\Qualities')

%% Statistics
for quality = 1:length(int_percepts)
    tbl{quality}(1,:) = sum([percept_ch{1}(:,quality), stim_cnt(1,:)'-percept_ch{1}(:,quality)], 1);
    tbl{quality}(2,:) = sum([percept_ch{2}(:,quality), stim_cnt(2,:)'-percept_ch{2}(:,quality)], 1);
    tbl{quality}(3,:) = sum([percept_ch{3}(:,quality), stim_cnt(3,:)'-percept_ch{3}(:,quality)], 1);
end

%fishers exact test for all groups
for quality = 1:size(tbl,2)
    [h(quality), p(quality)] = FisherExactTest(tbl{quality});
end
p(p>1) = 1;
h = fdr_bh(p);

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
%have to correct for multiple comparisons - probably Benjamani-Hochberg
