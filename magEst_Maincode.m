dbstop if error
%% User inputs
%Enter the desired paradigm:
%all = all experiments done with freq range 20-300 Hz - would never use
%this for normal analysis because it combines a lot of different variations
%in the paradigm
%norm = the basic paradigm (1-s train duration) used for paper figures
%long = 3-s train durations
%low = low amplitudes
%amp = amplitude estimation
%dur = train duration estimation
%new = 2019 data

%add path of relevant functions - will need to modify this based on where
%you save the code
addpath(genpath('C:\Users\clh180\Desktop\eLife Paper code and data\Code'))

%specify if you want to save images and where images should be saved
print_imgs = true;

%have user select folder for loading data
disp('Please select the folder to load data from')
dirs = 'C:\Users';
cd(dirs)
selpath = uigetdir;
load_directory = selpath;

%have user select folder for saving figures
disp('Please select the folder to save figures to')
dirs = 'C:\Users';
cd(dirs)
selpath = uigetdir;
save_directory = selpath;

style = inputdialog({'norm', 'long', 'low', 'amp', 'dur', 'new'}, 'Please select the trial type');

% 'true' if you want data to be normalized within days; 'false' otherwise
% we used normalization for amplitude and train duration plots but not for
% frequency plots
normalize_input = inputdialog({'Yes', 'No'}, 'Would you like to normalize data to the set in which it was collected?');
if strcmp(normalize_input, 'Yes')
    normalize = true;
else
    normalize = false;
end

% 'true' if we want to divide into frequency intensity relationships or
% combine all amplitude and train duration data on a single plot
group_input = inputdialog({'Yes', 'No'}, 'Would you like to group data based on categorization?');
if strcmp(group_input, 'Yes')
    grouping = true;
else
    grouping = false;
end

% in addition to grouping, need term to decide if we are aggregating all
% data together for one line or plotting separately
agg_input = inputdialog({'Yes', 'No'}, 'Would you like to aggregate data across electrodes?');
if strcmp(agg_input, 'Yes')
    aggregate = true;
else
    aggregate = false;
end

%choose if we want fit or lines
%1 for some fit 2 for piecewise connections
fit_input = inputdialog({'Function', 'Piecewise'}, 'Please select a fit type');
if strcmp(fit_input, 'Function')
    fit_type = 1;
else
    fit_type = 2;
end

%specify if you want error bars
%1 = no error bars
%2 = error bars with std
%3 = error bars with sem
%4 = filled area for sem
error_type = inputdialog({'No Error Bars', 'STD Bars', 'SEM Bars', 'SEM shaded'}, 'Please select an error bar type');
if strcmp(error_type, 'No Error Bars')
    error_bars = 1;
elseif strcmp(error_type, 'STD Bars')
    error_bars = 2;
elseif strcmp(error_type, 'SEM Bars')
    error_bars = 3;
else
    error_bars = 4;
end

%if we only want to plot example electrodes
%write in electrodes we want to use as example for each group
%can define electrodes of interest for each group
elec_type = inputdialog({'All', '2'}, 'Please select how many electrodes you would like to plot');

if strcmp(elec_type, 'All')
    for elec = 1:29
        elecs_int{elec} = 0;
    end
else
    if strcmp(style, 'amp')
        elecs_int{1} = [19 41];
    elseif strcmp(style, 'dur')
        elecs_int{1} = [2 19];
    elseif strcmp(style, 'norm')
        elecs_int{1} = [19 58];
        elecs_int{2} = [12 49];
        elecs_int{3} = [3 36];
    end
end

stats_input = inputdialog({'Yes', 'No'}, 'Do you want to do stats?');
if strcmp(stats_input, 'Yes')
    do_stats = true;
else
    do_stats = false;
end

%% Compile Magnitude Estimation Data
if ~exist('allLT') %don't need it to do this if it is already in workspace
    cd(load_directory)
    load('consolidatedMagEst.mat');
    cd(save_directory)
    for i = 1:length(metamagdata)
        mag_check(i) = ~isempty(metamagdata(i).reportedData.magnitude);
    end
    metamagdata = metamagdata(mag_check);
    sesh = [metamagdata.sessionInfo];
    sets = [metamagdata.set];
    idxLT = zeros(size(metamagdata));
    tempsets = [metamagdata.set];
    %this loop finds the idx for the sets of interest
    for session = unique([sesh.session_num])    
        for set = unique(tempsets([sesh.session_num] == session))
            medata = [];
            metaIdx = ([sesh.session_num] == session) & (tempsets == set);
            medata = metamagdata(metaIdx);
            testAmps = [];
            testFreq = [];
            testAmps = unique([medata.amplitude]);
            testFreq = unique([medata.frequency]);
            testDur = unique([medata.duration]); 
            %if ~isempty(find(testFreq==80,1)) %this limits the paradigm to the most recent version
                idxLT = idxLT | metaIdx; 
            %end
        end
    end
    allLT = metamagdata(idxLT); 
    temp = [sesh.session_num];
    allLTsessions = temp(idxLT); 
    allLTsets = sets(idxLT);
    r2s = [];
    pvals = [];
    slopes = [];
    regcount = 0;
    clear toFit;
else
    allLT = allLT_ALL;
    allLTsessions = allLTsessions_ALL;
    allLTsets = allLTsets_ALL;
end
     
%% Limit to dates of interest
%this will create an array 'mag_days' with all magnitude estimation dates with updated paradigm (80 Hz)       
cnt = 1;
mag_days{cnt} = 'Start';
for i = 1:length(metamagdata)
    curr_day = metamagdata(1,i).sessionInfo.date;
    if ~strcmp(mag_days{cnt}, curr_day)
        cnt = cnt + 1;
        mag_days{cnt} = curr_day;
    end
end
mag_days = mag_days(2:end); 

%this part limits to selected paradigm style
if all(strcmp(style, 'all')) 
    mag_days = {'17-Oct-2016','20-Feb-2017','28-Feb-2017',...
        '02-Mar-2017','13-Mar-2017','25-Apr-2017','08-May-2017',...
        '22-May-2017','25-Jul-2017','22-Jun-2015','13-Jul-2015',...
        '16-Jul-2015','07-Aug-2015','30-Nov-2015','12-Jan-2016',...
        '11-Feb-2016','28-Mar-2016','29-Mar-2016','12-Jan-2017',...
        '16-Jan-2017','21-Feb-2017','14-Mar-2017','03-Apr-2017',...
        '04-Apr-2017','11-Apr-2017','13-Apr-2017','18-Apr-2017',...
        '20-Apr-2017','24-Apr-2017','27-Apr-2017','09-May-2017',...
        '16-May-2017','18-May-2017','25-May-2017','01-Jun-2017',...
        '06-Jun-2017','08-Jun-2017','13-Jun-2017','19-Jun-2017',...
        '20-Jun-2017','27-Jun-2017','27-Jul-2017','07-Aug-2017',...
        '09-Oct-2017','16-Oct-2017','02-Nov-2017','20-Nov-2017',...
        '28-Nov-2017','04-Dec-2017','07-Dec-2017','19-Dec-2017',...
        '02-Jan-2018','04-Jan-2018'};
    amp = unique(amps);
    dur = unique(durs); %not sure if this works but also no reason we would ever want to use all data together
    mode = 1; %1 for frequency
elseif all(strcmp(style, 'norm')) 
    mag_days = {'25-Jul-2017','27-Jul-2017','07-Aug-2017','09-Oct-2017',...
        '16-Oct-2017','02-Nov-2017','28-Nov-2017','04-Dec-2017'...
        '19-Dec-2017','02-Jan-2018', '04-Jan-2018', '26-Feb-2018'};
    amp = 60; %to weed out low amplitude tests
    dur = 1; %to weed out short train durations
    mode = 1; %1 for frequency
elseif all(strcmp(style, 'low')) 
    mag_days = {'19-Dec-2017','02-Jan-2018','04-Jan-2018'};
    dur = 1;
    mode = 1; %1 for frequency
elseif all(strcmp(style, 'long')) 
    mag_days = {'18-May-2017', '22-May-2017', '25-May-2017', ...
        '01-Jun-2017', '06-Jun-2017','08-Jun-2017','13-Jun-2017', ...
        '19-Jun-2017','20-Jun-2017','27-Jun-2017'};
    amp = 60;
    dur = 3;
    mode = 1; %1 for frequency
elseif all(strcmp(style, 'amp')) 
   mag_days = {'13-Jul-2015', '16-Jul-2015', '30-Nov-2015' ...
    '12-Jan-2016', '11-Feb-2016', '20-Feb-2016', '20-Nov-2017'};  
    %mag_days = {'20-Nov-2017'};
    dur = 1;
    freq = 100;
    mode = 2; %2 for amplitude
elseif all(strcmp(style, 'dur')) 
    mag_days = {'20-Nov-2017', '20-Jan-2020'} ; %may need to only use two channels with higher intensity on second day 
    amp = 60;
    freq = 100;
    mode = 3; %3 for duration
elseif all(strcmp(style, 'new')) 
    mag_days = {'21-Jan-2020'} ; %may need to only use two channels with higher intensity on second day
    amp = 60;
    dur = 1;
    mode = 1; %1 for frequency
end

% %thing just for paper
% mag_days = {'20-Nov-2017'};
% dur = 1;
% freq = 100;
% mode = 2; %2 for amplitude

allLT_ALL = allLT;
allLTsessions_ALL = allLTsessions;
allLTsets_ALL = allLTsets;
clear allLT allLTsessions allLTsets
cnt = 1;
for i = 1:length(mag_days)
    for j = 1:length(allLT_ALL)
        curr_trial = allLT_ALL(1,j).sessionInfo.date;
        if strcmp(curr_trial,mag_days{i})
            allLT(cnt) = allLT_ALL(1,j);
            allLTsessions(cnt) = allLTsessions_ALL(j);
            allLTsets(cnt) = allLTsets_ALL(j);
            cnt = cnt + 1; 
        end
    end
end
 
%want to remove the low intensity sets from the train duration results
%because they add a lot of variance
if all(strcmp(style, 'dur'))
    allLT = allLT(allLTsets ~= 11 & allLTsets ~= 13);
    allLTsessions = allLTsessions(allLTsets ~= 11 & allLTsets ~= 13);
    allLTsets = allLTsets(allLTsets ~= 11 & allLTsets ~= 13);
end

%% Calculates the responses for the selected dates and normalizes (if specified) and plots

clear resps_avg resps_org resps_org_ind resps_sess resps_mean
%for session = unique(allLTsessions)
%not explicitly looping over sets because the same electrode wouldn't
%be tested in the same session. This is probably poor form... 
%stimdata = allLT(allLTsessions == session);
stimdata = allLT;
%date = [stimdata(1,1).sessionInfo.date]; %since all sessions come from the same day should be able to just use the first one
sessions = [stimdata.reportedData];
resps = [sessions.magnitude];
chans = [stimdata.channel];
amps = [stimdata.amplitude];
freqs = [stimdata.frequency];
for i = 1:length(stimdata)
    durs(i) = unique(stimdata(i).duration);  %for some reason durations is sometimes saved multiple times so had to write this a bit differently
end
blocks = [stimdata.block]; 
%get rid of nans and trials that were mark as discarded
allLTsessions(isnan(amps)) = [];
allLTsessions([stimdata.discardedTrial]) = [];
allLTsets(isnan(amps)) = [];
allLTsets([stimdata.discardedTrial]) = [];
freqs(isnan(amps)) = [];
freqs([stimdata.discardedTrial]) = [];
chans(isnan(amps)) = [];
chans([stimdata.discardedTrial]) = [];
blocks(isnan(amps)) = [];
blocks([stimdata.discardedTrial]) = [];
amps([stimdata.discardedTrial]) = [];
amps(isnan(amps)) = [];
durs([stimdata.discardedTrial]) = [];
durs(isnan(durs)) = [];


if mode == 1 %only for frequency mode
    if ~exist('amp') %if amp or dur isn't specified, we assume we want non-normal values
        amp_idx = amps ~= 60; %this doesn't work for decreasing amplitude
    else
        amp_idx = amps == amp;
    end
    if ~exist('dur')
        dur_idx = durs ~= 1;
    else
        dur_idx = durs == dur;
    end
    %create a master idx (specify values that will be used in all indexes)
    master_idx = amp_idx & dur_idx & blocks > 1; %blocks > 1 takes out first block
elseif mode == 2
    freq_idx = freqs == freq; %should always be 100
    dur_idx = durs == dur; %should always be 1
    master_idx = freq_idx & dur_idx & blocks > 1;
elseif mode == 3
    freq_idx = freqs == freq; %should always be 100
    amp_idx = amps == amp; %should always be 60
    master_idx = freq_idx & amp_idx & blocks > 1;
end
    
%this will be used later for normalized magnitude data for all sets
clear stimdata_max
for session = unique(allLTsessions)
    for set = unique(allLTsets)
        for channel = unique(chans)
            idx = allLTsessions == session & allLTsets == set & chans == channel & blocks ~= 1 & master_idx; %removed first block here
            stimdata_lim = resps(idx);
            if ~isempty(stimdata_lim)
                stimdata_max(channel, session) = nanmax(stimdata_lim);
                stimdata_median(channel, session) = nanmedian(stimdata_lim);
                if normalize
                    resps(idx) = resps(idx)./stimdata_median(channel, session); %will normalize for an electrode/set
                end
            end
        end
    end
end

%figure
%make this so that it averages intensity relationship of each group
clear groups
if grouping
    if mode == 1
        groups{2} = [2 12 42 49 63]; %Low frequency preference
        groups{1} = [14 16 19 22 26 54 58]; %Intermediate frequency preference
        groups{3} = [3 8 13 20 34 36 41 45]; %High frequency preference
    else
        groups{1} = unique(chans); 
    end
else
    unq_chans = unique(chans);
    for elec = 1:length(unq_chans)
        groups{elec} = unq_chans(elec); %each group is just a single electrode here
    end
end

if mode == 1
    params = freqs;
elseif mode == 2
    params = amps;
elseif mode == 3
    params = durs;
end

[resps_org, peak_param, resps_org_2, resps_avg, coeffs, max_intensities, resps_org_3, val] = magEst_responses(resps, params, groups, chans, allLTsessions, allLTsets, master_idx, grouping, print_imgs, error_bars, mode, aggregate, fit_type, elecs_int);
 
%% STATS stuff

if do_stats
    %check for normality
    %most channels have at least one residual that is not normal - use
    %nonparametric tests
    for i = 1:size(resps_org_3,2)
        for j = 1:size(resps_org_3{1,i},2)
            [ad_h(i,j), ad_results(i,j)] = adtest(resps_org_3{1,i}(:,j));
        end
    end

    %check for homoscedasticity
    for i = 1:size(resps_org_3,2)
        var_results(i) = vartestn(resps_org_3{1,i});
    end

    %perform friedman for nonparametric and repeated measures
    clear p tbl stats c
    for i = 1:length(resps_org_3)
        [p(i) tbl{i} stats{i}] = friedman(resps_org_3{i}, size(resps_org_3{i},1)/5);
    end
end


