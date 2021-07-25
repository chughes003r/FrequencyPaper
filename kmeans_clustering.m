%k-means clustering

%have user select which participant's data they want to plot
participant = inputdialog({'P2', 'P3'}, 'Please select the desired participant');
if strcmp(participant, 'P2')
    load('all_resps_notnorm.mat') %all intensity responses
    load('chans.mat') %channel labels
    load('percept_ch_all.mat') %all quality responses
    num_clust = 3;
    non_sig_chs = [10, 15, 18, 25, 46, 48, 51, 52, 57];
    data = resp;
    vector_3D = [data(:,1), data(:,5), data(:,9)]; %only looking at 20 100 and 300 Hz
    [data, vector_3D, sig_chs] = rmv_chans(data, vector_3D, unq_chans, non_sig_chs);
    initial_centers = [vector_3D(sig_chs==13,:); vector_3D(sig_chs==19,:); vector_3D(sig_chs==2,:)]; %starting coordinates
else
    load('P3_respsandchans.mat') %all intensity responses and channel labels
    num_clust = 2;
    non_sig_chs = [52];
    data = resp;
    vector_3D = data;
    [data, vector_3D, sig_chs] = rmv_chans(data, vector_3D, unq_chans, non_sig_chs);
    initial_centers = [vector_3D(sig_chs==2,:); vector_3D(sig_chs==45,:)]; %starting coordinates
end

%% cluster based on intensity responses

%use only responses at 20, 100, and 300 Hz
[idx C sumd] = kmeans(vector_3D, num_clust, 'Start', initial_centers);

plot_clusters(vector_3D, idx, participant)

%% cluster based on perceptual qualities - only have data for this in CRS02b
if strcmp(participant, 'P2')
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

    plot_clusters(vector_3D, idx2, participant)
end

%% function for removing undesired channels
function [data, vector_3D, sig_chs] = rmv_chans(data, vector_3D, unq_chans, non_sig_chs)
    sig_chs = unq_chans;
    for ch = length(non_sig_chs):-1:1
        data(unq_chans == non_sig_chs(ch), :) = [];
        vector_3D(unq_chans == non_sig_chs(ch), :) = [];
        sig_chs(unq_chans == non_sig_chs(ch)) = [];
    end
end

%% plot clusters in intensity space
function plot_clusters(vector_3D, idx, participant)
    figure
    color_scheme = [51,160,44; 31,120,180; 106,61,154;];
    color_scheme = color_scheme/255; %scaling for MATLAB
    color_map = colormap(color_scheme);

    for j = 1:size(vector_3D,2)
        jitter(:,j) = [0,0,0] + [0.1,0.1,0.1]*(j-1);
    end

    for pt = 1:size(vector_3D,1)
        if idx(pt) == 1
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(1,:);
            subset(1) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(1,:));
            hold on
        end
        if idx(pt) == 3
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(2,:);
            subset(3) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(3,:));
            hold on
        end
        if idx(pt) == 2
            vector_3D(pt,:) = vector_3D(pt,:) + jitter(3,:);
            subset(2) = plot3(vector_3D(pt,1),vector_3D(pt,2),vector_3D(pt,3), 'k.','MarkerSize',40, 'Color', color_map(2,:));
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
    if strcmp(participant, 'CRS02b')
        legend(subset, [{'HFP'}, {'IFP'}, {'LFP'}])
    else
        legend(subset, [{'HFP'}, {'LFP'}])
    end
    axis square
end

