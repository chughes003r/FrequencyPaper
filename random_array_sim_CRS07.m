%Code for simulating random distribution of freq relationships
%have to do each array at a time

%% Calculate actual ratio from data_vector
load('CRS07_locations.mat')

data_vector = category_locations;

%plot heatmaps
plot_spatial_data_blackedOut_frequency_CRS07(data_vector', '')

%also plot median with SEM
figure
colormapping = [106,61,154; 51,160,44];
colormapping = colormapping/255;
subplot(1) = errorbar(mean(vector_3D(idx==1,:)),std(vector_3D(idx==1,:))/sqrt(sum(idx==1)), 'LineWidth', 2, 'Color', colormapping(2,:));
hold on
subplot(2) = errorbar(mean(vector_3D(idx==2,:)),std(vector_3D(idx==2,:))/sqrt(sum(idx==2)), 'LineWidth', 2, 'Color', colormapping(1,:));
ax = gca;
xlim([0.5 3.5])
ax.XTick = [1,2,3];
ax.XTickLabels = [20,100,300];
ax.FontName = 'Arial';
ax.FontSize = 16;
ax.FontWeight = 'bold';
xlabel('Frequency comparisons (Hz)')
ylabel('Reported Intensity (a.u.)')
legend(subplot, {'HFP', 'LFP'})


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
              nan	15	nan	18	nan	30;
                5	nan	12	nan	24	nan;
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
            for i2 = -1:1 %x-dimension neighbors
                for j2 = -1:1 %y-dimension neighbors
                    if i+i2 > 0 && i+i2 < size(stimData,1) && j+j2 > 0 && j+j2 < size(stimData,2) && ~all([i2,j2] == 0)
                        if stimData(i+i2,j+j2) > 0
                            curr_neigh = [curr_neigh stimData(i+i2,j+j2)]; %put all neighbors of current electrode into an array
                        end
                    end
                end
            end
            if i < 11
                total_cnt_lat(cnt) = length(curr_neigh); %how many neighbors there are 
                total_matches_lat(cnt) = sum(curr_neigh == stimData(i,j)); %how many neighbors are matching
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
low_chs = [33,34,40,44,45,46,47];
high_chs = [1,2,3,5,8,10,12,13,14,19,20,26,35,42,57];

chans = sort([low_chs, high_chs]);
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
geo_locs_med(:,1) = geo_locs_med(:,1) + 6; %putting stacking medium and lateral
geo_locs_med(:,2) = geo_locs_med(:,1) + 10; %putting stacking medium and lateral

geo_locs = [geo_locs_lat; geo_locs_med]; %geo_locs marks the geometric location of each tested electrode


low = length(low_chs);
high = length(high_chs);

%1 = low, 2 = high
vec_length = low+high;
vec = zeros(1,vec_length);
vec(1:low) = 1;
vec(low+1:low+high) = 2; %vec marks the total number of each electrode (1 or 2)

reps = 100000;
for m = 1:reps 

    vec_rand = vec(randperm(length(vec))); %randomizes the order of the electrode types i.e. no organization

    geo_locs(:,3) = vec_rand'; %labels each electrode as a random group

    colors = {'b', 'r'};

%quantify distance
    total_matches = 0;
    total_count = 0;
    for i = 1:size(geo_locs,1)
        x = geo_locs(i,1);
        y = geo_locs(i,2);
        diff_mat(:,1) = abs(geo_locs(:,1) - x);
        diff_mat(:,2) = abs(geo_locs(:,2) - y);
        diff_mat(:,3) = diff_mat(:,1) + diff_mat(:,2);
        log_idx = diff_mat(:,1) < 2 & diff_mat(:,2) < 2 & diff_mat(:,3) ~= 0; %find electrodes that are at most one space away in both the x and y directions (and makes sure it isn't counting itself)
        base_type = geo_locs(i,3);
        near_types = geo_locs(log_idx,3);
        matches = near_types == base_type;
        total_matches = total_matches + sum(matches); %adds total matching neighbors
        total_count = total_count + sum(log_idx); %adds total neighbors
    end
    if total_matches > 0
        prob(m) = total_matches/total_count;
    else
        prob(m) = 0;
    end
end
mean(prob)

%% Find pseudo p-values by comparing real and simulated data

ratio_lat = sum([total_matches_lat, total_matches_med])/sum([total_cnt_lat, total_cnt_med]);
%pseudo p-value
pval = (sum(prob>=ratio_lat)+1)/(reps+1);

%% Make plots of probability distributions
pd = fitdist(prob', 'Gamma');
x = [0:0.01:1];
y = pdf(pd, x);
figure
plot(x,y, 'LineWidth', 2)
xline(ratio_lat)
title('Outcome distribution') 
ylabel('pdf')
xlabel('Ratio of matching neighbors to total neighbors')
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 18;
ax.FontWeight = 'bold';
dim = [0.75 0.5 0.3 0.3];
annotation('textbox',dim,'String','p < 0.05','FitBoxToText','on', 'FontSize', 18)
