%k-means clustering

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

cd(load_directory)
load('all_resps_notnorm.mat') %all intensity responses
load('chans.mat') %channel labels
load('percept_ch_all.mat') %all quality responses

%% cluster based on intensity responses
num_clust = 3;
data = resp;
vector_3D = [data(:,1), data(:,5), data(:,9)]; %only looking at 20 100 and 300 Hz

%if we only want to use sig channels
non_sig_chs = [10, 15, 18, 25, 46, 48, 51, 52, 57];
sig_chs = unq_chans;
for ch = length(non_sig_chs):-1:1
    data(unq_chans == non_sig_chs(ch), :) = [];
    vector_3D(unq_chans == non_sig_chs(ch), :) = [];
    sig_chs(unq_chans == non_sig_chs(ch)) = [];
end

%use only responses at 20, 100, and 300 Hz
initial_centers = [vector_3D(sig_chs==13,:); vector_3D(sig_chs==19,:); vector_3D(sig_chs==2,:)]; %these starting coordinates are good ; vector_3D(sig_chs==54,:)
[idx C sumd] = kmeans(vector_3D, num_clust, 'Start', initial_centers);

plot_clusters(vector_3D, idx)

%% cluster based on perceptual qualities
%use percepts to cluster
percept_ch_all = [percept_ch_20, percept_ch_100, percept_ch_300];
percept_ch_all = percept_ch_all(sig_chs,:);

%adding across frequencies
for i = 1:10
    percept_ch_all(:,i) = percept_ch_all(:,i) + percept_ch_all(:,i+10) + percept_ch_all(:,i+20);
    percept_ch_all(:,i) = percept_ch_all(:,i)./max(percept_ch_all(:,i)); %normalize so all qualities have the same weight
end
percept_ch_all = percept_ch_all(:,1:10);

initial_centers = [percept_ch_all(sig_chs==3,:); percept_ch_all(sig_chs==26,:); percept_ch_all(sig_chs==12,:)]; %these starting coordinates are good ; vector_3D(sig_chs==54,:)
[idx2 C sumd] = kmeans(percept_ch_all, num_clust, 'Start', initial_centers);

plot_clusters(vector_3D, idx2)

%% plot clusters in intensity space
function plot_clusters(vector_3D, idx)
    figure
    color_scheme = [31,120,180; 106,61,154; 51,160,44;];
    color_scheme = color_scheme/255; %scaling for MATLAB
    color_map = colormap(color_scheme);

    for j = 1:size(vector_3D,2)
        jitter(:,j) = [0,0,0] + [0.1,0.1,0.1]*(j-1);
    end

    for pt = 1:size(vector_3D,1)
        if idx(pt) == 4
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(4,:);
            subset(1) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(4,:));
            hold on
        end
        if idx(pt) == 1
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(1,:);
            subset(3) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(3,:));
            hold on
        end
        if idx(pt) == 3
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(2,:);
            subset(2) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(2,:));
            hold on
        end
        if idx(pt) == 2
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(3,:);
            subset(1) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(1,:));
            hold on
        end
    end
    grid on
    xlabel('20 Hz')
    ylabel('100 Hz')
    zlabel('300 Hz')
    ax= gca;
    ax.FontSize = 18;
    ax.FontWeight = 'bold';
    ax.GridAlpha = 1;
    legend(subset, [{'IFP'}, {'LFP'}, {'HFP'}])
    axis square
end

