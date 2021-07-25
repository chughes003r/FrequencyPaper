%% Code for single magnitude estimation set

%specify if you want to save images and where images should be saved

%load in data structure with data for all significant channels
load('allData_sigChans.mat')

%define the color scheme for the plots
color_scheme = [166,206,227; 31,120,180; 178,223,138; 51,160,44; ...
251,154,153; 227,26,28; 253,191,111; 255,127,0; 202,178,214; ...
106,61,154; 255,255,153; 177,89,40]; %taken from colorbrewer
color_scheme = color_scheme/255; %scaling for MATLAB
color_bar = colormap(color_scheme);

%identify the channels tested in each session
for curr_sess = 1:length(allData)
    channels(curr_sess) = allData{curr_sess}(1,1).channel;
end

unq_chs = unique(channels);

max_resp = 0;
cidx = 1;

jitters = [0 2 -2 4 -4 6];

for curr_ch = 1:length(unq_chs)
    clear subset labels
    figure('OuterPosition',[0 0 1680 1050]);
    sess_use = find(channels == unq_chs(curr_ch)); %logical that indicates the relevant sessions to use
    for curr_sess = 1:length(sess_use)
        jitter = jitters(curr_sess);
        curr_data = allData{sess_use(curr_sess)};
        for trial = 1:length(curr_data)
            freqs(trial) = curr_data(1,trial).frequency;
            blocks(trial) = curr_data(1,trial).block;
            resps{curr_ch,curr_sess}(trial) = curr_data(1,trial).reportedData.magnitude;
        end

        freqs = freqs(blocks ~= 1);
        resps{curr_ch,curr_sess} = resps{curr_ch,curr_sess}(blocks ~= 1); %remove first block
        
        date = curr_data(1,1).sessionInfo.date;

        unq_freqs = unique(freqs);

        cb = color_bar(curr_sess*cidx+1,:); 
        norm_fac = median(resps{curr_ch,curr_sess}); %use the median of the responses for normalization
        if norm_fac == 0
            norm_fac = mean(resps{curr_ch,curr_sess}); %can't normalize to zero
        end
        for freq_cnt = 1:length(unq_freqs)
            curr_freq = unq_freqs(freq_cnt);
            resps_org{curr_ch,curr_sess}(freq_cnt,:) = (resps{curr_ch,curr_sess}(freqs == curr_freq)/norm_fac)';
            resp_avg{curr_ch,curr_sess}(freq_cnt,1) = median(resps{curr_ch,curr_sess}(freqs == curr_freq))/norm_fac;
            resp_avg{curr_ch,curr_sess}(freq_cnt,2) = std(resps{curr_ch,curr_sess}(freqs == curr_freq)./norm_fac)./sqrt(5);
        end

        plot(unq_freqs+jitter, resp_avg{curr_ch,curr_sess}(:,1), 'o', 'MarkerSize', 4, 'LineWidth', 2, 'MarkerFaceColor', cb, 'Color', cb) %mean(resps(idx)) elec, + jitter
        hold on
        
        est_err = resp_avg{curr_sess}(:,2)';
        fill([unq_freqs+jitter, unq_freqs(end:-1:1)+jitter, unq_freqs(1)+jitter],[resp_avg{curr_ch,curr_sess}(:,1)'+est_err, resp_avg{curr_ch,curr_sess}(end:-1:1,1)'-est_err(1,end:-1:1), est_err(1,1)], cb ,'EdgeColor','none');
        alpha(0.25);


        temp = max(resp_avg{curr_ch,curr_sess}(:,1)) + max(resp_avg{curr_ch,curr_sess}(:,2));
        if temp > max_resp
            max_resp = temp;
        end

        subset(curr_sess) = plot(unq_freqs+jitter, resp_avg{curr_ch,curr_sess}(:,1), 'Color', cb, 'LineWidth', 2);
        labels{curr_sess} = num2str(datenum(date) - datenum('5/04/2015'));
    end
    ax = gca;
    ax.FontName = 'Arial';
    ax.FontWeight = 'bold';
    ax.FontSize = 18;
    xlabel('Stimulation Frequency (Hz)')
    axis([0 320 0 2.5]) %max_plot 4.3317 max_resp
    ylabel('Normalized Magnitude (a.u.)')
    tit = strcat(['Electrode ', num2str(unq_chs(curr_ch))]);
    title(tit)
    axis square
    hold off
    legend(subset, labels)
end

%% Stats 

%can determine which electrodes have 3 or more samples
sig_chans = unq_chs(~cellfun(@isempty, resps(:,3)));

%compare magnitude at specific frequency aross collected sessions to look
%for significant differences
for curr_ch = 1:length(sig_chans)
    for curr_freq = 1:9 % nine tested frequencies
        resps_org_2{curr_freq, curr_ch} = [];
        for curr_sess = 1:size(resps_org,2)
            ch_chk = unq_chs == sig_chans(curr_ch);
            if ~isempty(resps_org{ch_chk,curr_sess})
                resps_org_2{curr_freq,curr_ch} = [resps_org_2{curr_freq, curr_ch}, resps_org{ch_chk,curr_sess}(curr_freq,:)'];
            end
        end
        [p(curr_freq,curr_ch)] = friedman(resps_org_2{curr_freq,curr_ch}, 1, 'off');
    end
end
