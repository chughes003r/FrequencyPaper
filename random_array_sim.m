%Code for simulating random distribution of freq relationships
%have to do each array at a time

%% Select which array to analyze
array_inp = inputdialog({'Lateral', 'Medial'}, 'Please select array to plot');
if strcmp(array_inp, 'Lateral')
    array = 1;
else
    array = 2;
end

%% Calculate actual ratio from data_vector
load('C:\Users\clh180\Desktop\eLife Paper code and data\Data\category_locations.mat')
data_vector = category_locations;

%plot heatmaps
plot_spatial_data_blackedOut_frequency(data_vector', '') %need to get this to plot insignificant ones as well

data_vector = data_vector + 2; %need to recenter
%set up array that holds frequency preference information
stimChanL =  [  1	nan	8	nan	21	27;
              nan   13	nan	17	nan	28;
               3	nan	10	nan	23	nan;
              nan	15	nan	18	nan	30;
               5	nan	12	nan	24	nan;
              nan	2	nan	20	nan	29;
               7	nan	14	nan	25	nan;
              nan	4	nan	19	nan	32;
                9	nan	16	nan	26	nan;
              11	6	nan	22	nan	31 ];

stimChanM =    [1	nan	8	nan	21	27;
              nan	13	nan	17	nan	28;
                3	nan	10	nan	23	nan;
              nan	nan	nan	18	nan	30;
                5	15	12	nan	24	nan;
              nan	2	nan	20	nan	29;
                7	nan	14	nan	25	nan;
              nan	4	nan	19	nan	32;
                9	nan	16	nan	26	nan;
              11	6	nan	22	nan	31 ];
          
stimChanM = stimChanM + 32; 

stimChans = [stimChanL; zeros(1,6); stimChanM];
stimData = zeros(size(stimChans));
for i = 1:size(data_vector, 2) 
     [r, c] = find(stimChans == i);
        stimData(r,c) = data_vector(i);         
end
stimData(stimData == 0) = -1; %make disconnected channels -1
stimData(isnan(stimData)) = 0; %make no data 0
stimData(stimData == -1) = nan; %make disconnected channels nan

%find the number of matchings neighbors and the total number of neighbors
cnt = 1;
cnt2 = 1;
for i = 1:size(stimData, 1)
    for j = 1:size(stimData,2)
        curr_neigh = [];
        if stimData(i,j) > 0
            %check neighbors
            for i2 = -1:1
                for j2 = -1:1
                    if i+i2 > 0 && i+i2 < size(stimData,1) && j+j2 > 0 && j+j2 < size(stimData,2) && ~all([i2,j2] == 0)
                        if stimData(i+i2,j+j2) > 0
                            curr_neigh = [curr_neigh stimData(i+i2,j+j2)];
                        end
                    end
                end
            end
            if i < 11
                total_cnt_lat(cnt) = length(curr_neigh);
                total_matches_lat(cnt) = sum(curr_neigh == stimData(i,j));
                cnt = cnt + 1;
            else
                total_cnt_med(cnt2) = length(curr_neigh);
                total_matches_med(cnt2) = sum(curr_neigh == stimData(i,j));
                cnt2 = cnt2 + 1;
            end
        end
    end
end

%% Simulate array based on distribution of frequency preferences
%divide channels by frequency preference
low_chs = [2 12 42 49 63];
middle_chs = [14 16 19 22 26 54 58];
high_chs = [3 8 13 20 34 36 41 45];

chans = sort([low_chs, middle_chs, high_chs]);
chansL = chans(chans < 33);
chansM = chans(chans > 32);

for chan = 1:length(chansL)
    [geo_locs_lat(chan,2), geo_locs_lat(chan,1)] = find(stimChanL == chansL(chan));
    geo_locs_lat(chan,2) = 11 - geo_locs_lat(chan,2); %had to do this to get in the correct format
end

for chan = 1:length(chansM)
    [geo_locs_med(chan,2), geo_locs_med(chan,1)] = find(stimChanM == chansM(chan));
    geo_locs_med(chan,2) = 11 - geo_locs_med(chan,2); %had to do this to get in the correct format
end

clear geo_locs vec diff_mat prob
if array == 1
    geo_locs = geo_locs_lat;
    low = sum(low_chs<33); 
    high = sum(high_chs<33);
    intr = sum(middle_chs<33);
else
    geo_locs = geo_locs_med;
    low = sum(low_chs>32); 
    high = sum(high_chs>32);
    intr = sum(middle_chs>32);
end

%1 = low, 2 = intr, 3 = high
vec_length = low+high+intr;
vec = zeros(1,vec_length);
vec(1:low) = 1;
vec(low+1:intr+low) = 2;
vec(intr+low+1:intr+low+high) = 3;

reps = 100000;
for m = 1:reps 

    vec_rand = vec(randperm(length(vec)));

    geo_locs(:,3) = vec_rand';

    %color by frequency group
    % grp{1} = [20, 40];
    % grp{2} = [60, 80, 100];
    % grp{3} = [150, 200, 250, 300];

    colors = {'b', 'r', 'y'};

%     figure
%     for i = 1:3
%         idx = geo_locs(:,3) == i; 
%         plot(geo_locs(idx,1), geo_locs(idx,2), '.', 'MarkerSize', 32, 'MarkerEdgeColor', colors{i})
%         hold on
%     end

%quantify distance
    total_matches = 0;
    total_count = 0;
    for i = 1:size(geo_locs,1)
        x = geo_locs(i,1);
        y = geo_locs(i,2);
        diff_mat(:,1) = abs(geo_locs(:,1) - x);
        diff_mat(:,2) = abs(geo_locs(:,2) - y);
        diff_mat(:,3) = diff_mat(:,1) + diff_mat(:,2);
        log_idx = diff_mat(:,1) < 2 & diff_mat(:,2) < 2 & diff_mat(:,3) ~= 0;
        base_type = geo_locs(i,3);
        near_types = geo_locs(log_idx,3);
        matches = near_types == base_type;
        total_matches = total_matches + sum(matches);
        total_count = total_count + sum(log_idx);
    end
    if total_matches > 0
        prob(m) = total_matches/total_count;
    else
        prob(m) = 0;
    end
end
mean(prob)

%% Find pseudo p-values by comparing real and simulated data

if array == 1
    ratio_lat = sum(total_matches_lat)/sum(total_cnt_lat);
    %pseudo p-value
    pval = (sum(prob>=ratio_lat)+1)/(reps+1);
else
    ratio_med = sum(total_matches_med)/sum(total_cnt_med);
    %pseudo p-value
    pval = (sum(prob>=ratio_med)+1)/(reps+1);
end

%% Make plots of probability distributions
pd = fitdist(prob', 'Gamma');
x = [0:0.01:1];
y = pdf(pd, x);
figure
plot(x,y, 'LineWidth', 2)
if array == 1
    %vline_lim(ratio_lat,x,y)
    xline(ratio_lat, 'r--')
    title('Lateral array outcome distribution') 
else
    %vline_lim(ratio_med,x,y)
    xline(ratio_med, 'r--')
    title('Medial array outcome distribution')
end
ylabel('pdf')
xlabel('Ratio of matching neighbors to total neighbors')
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 18;
ax.FontWeight = 'bold';
dim = [0.75 0.5 0.3 0.3];
annotation('textbox',dim,'String','p < 0.05','FitBoxToText','on', 'FontSize', 18)

