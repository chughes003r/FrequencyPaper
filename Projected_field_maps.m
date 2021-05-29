%code that will plot spatial map for surveys
for curr_survey = 1:length(aggYaml)
    for curr_chan = 1:length(aggYaml(curr_survey).channel_unq)
        curr_field = aggYaml(curr_survey).RF_unq{curr_chan};
        if ~isempty(curr_field)
            PFs{curr_survey, aggYaml(curr_survey).channel_unq(1,curr_chan)} = curr_field{1};
        end
    end
end

%go through each channel and find out a)how many times a percept was
%reported and b) which projected fields were reported on at least 25% of
%those reports

for curr_chan = 1:size(PFs,2)
    PF_labels{curr_chan} = {};
    PFs_all = [];
    report_cnt = 0;
    for curr_survey = 1:size(PFs,1)
        if ~isempty(PFs{curr_survey,curr_chan})
            PFs_all = [PFs_all PFs{curr_survey,curr_chan}];
            report_cnt = report_cnt + 1;
        end
    end
    if report_cnt > 0
        [unq_PF, ~, idx] = unique(PFs_all);
        %find the most reported location
        max_PF = mode(idx);
        PF_labels{curr_chan} = unq_PF{max_PF};
%         for curr_PF = 1:length(unq_PF)
%             if sum(idx == curr_PF) > report_cnt/4
%                 PF_labels{curr_chan} = [PF_labels{curr_chan}, unq_PF{curr_PF}];
%             end
%         end
    end
end

%we are going to generalize to index, P2, P3, P4, or P5
for curr_elec = 1:length(PF_labels)
    if ~isempty(PF_labels{curr_elec})
        if strfind(PF_labels{curr_elec}, 'i')
            color_label(curr_elec) = 1; %for index
        elseif strfind(PF_labels{curr_elec}, '2')
            color_label(curr_elec) = 2; %for P2
        elseif strfind(PF_labels{curr_elec}, '3')
            color_label(curr_elec) = 3; %for P3
        elseif strfind(PF_labels{curr_elec}, '4')
            color_label(curr_elec) = 4; %for P4
        elseif strfind(PF_labels{curr_elec}, '5')
            color_label(curr_elec) = 5; %for P5
        end
    end
end

%now that we have color_labels, we can produce spatial plots
color_scheme = [0,0,0; 166,206,227; 31,120,180; 178,223,138; 51,160,44; 251,154,153]; %taken from colorbrewer
color_scheme = color_scheme/255; %scaling for MATLAB
color_map = colormap(color_scheme);

color_label(color_label == 0) = nan;

plot_spatial_data_blackedOut_survey(color_label', 'Projected Fields', color_map)

        
        