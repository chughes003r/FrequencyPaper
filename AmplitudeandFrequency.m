%magnitude estimation freq and amp
load('AmpandFreq_data.mat');

groups{1} = [2 12 42 49 63]; %low frequency
groups{2} = [14 16 19 22 26 54 58]; %intermediate
groups{3} = [3 8 13 20 34 36 41 45]; %high

group_names = [{'LFP'}, {'IFP'}, {'HFP'}];

freqs = [20 100 300];
amps = [20 50 80];

intensities_groups{1} = cell(3,3);
intensities_groups{2} = cell(3,3);
intensities_groups{3} = cell(3,3);
chans = cell(1,3);
for session_num = 1:size(data_all,1)
    for set_num = 1:size(data_all,2) 
        data = data_all{session_num, set_num};
        chan = data(1,1).channel;
        if any(groups{1} == chan)
            sort_idx = 1;
            chans{1} = [chans{1} chan];
        elseif any(groups{2} == chan) 
            sort_idx = 2;
            chans{2} = [chans{2} chan];
        elseif any(groups{3} == chan) 
            sort_idx = 3;
            chans{3} = [chans{3} chan];
        else
            sort_idx = [];
        end
        if ~isempty(sort_idx) %only pulls data if electrode falls into a frequency category
            intensities = cell(3,3);
            all_intensities = [];
            for trial = 10:length(data) %start at 10 to skip first trial
                curr_amp = data(trial).amplitude;
                curr_freq = data(trial).frequency;
                if ~isempty(data(trial).reportedData.magnitude) && length(intensities{amps == curr_amp, freqs == curr_freq}) < 5
                    intensities{amps == curr_amp, freqs == curr_freq} = [intensities{amps == curr_amp, freqs == curr_freq}, data(trial).reportedData.magnitude];
                    all_intensities = [all_intensities, data(trial).reportedData.magnitude]; %so we can find median
                end
            end
            for i = 1:size(intensities,1)
                for j = 1:size(intensities, 2)
                    %intensities{i,j} = intensities{i,j}/nanmedian(all_intensities); %normalize
                    intensities_groups{sort_idx}{i,j} = [intensities_groups{sort_idx}{i,j}, intensities{i,j}];
                end
            end
        end   
        %disp('')
    end
end

x_points = [1,2,3]; %to make axis categorical
for group = 1:length(intensities_groups)
    figure('units','normalized','outerposition',[0 0 1 1])
    hold on
    color_map = colormap('parula');
    colors = [color_map(81,:); color_map(148,:); color_map(196,:)];
    jitter = [-1, 0, 1];
    intensities = intensities_groups{group};
    for amp = 1:size(intensities,1)
        for freq = 1:size(intensities,2)
            scatter(x_points(freq), mean(intensities{amp,freq}), 'MarkerEdgeColor', colors(amp,:), 'MarkerFaceColor', colors(amp,:)); %freqs(freq)+jitter(amp)
            x_val(freq) = mean(intensities{amp,freq});
            x_err(freq) = std(intensities{amp,freq})/sqrt(length(intensities{amp,freq}));
        end
        subset(amp) = errorbar(x_points, x_val, x_err, 'Color', colors(amp,:), 'LineWidth', 2); %freqs+jitter(amp)
    end

    legend(subset, {'20 uA', '50 uA', '80 uA'})
    tit = group_names{group};
    title(tit)
    axis([0.5 3.5 0 4]) %320
    ax = gca;
    ax.XTick = [1,2,3];
    ax.XTickLabels = freqs;
    ax.FontName = 'Arial';
    ax.FontSize = 28;
    ax.FontWeight = 'bold';
    xlabel('Frequency comparisons (Hz)')
    ylabel('Reported Intensity (a.u.)')
    if isfile([tit '.png'])
         tit = [tit, '_2'];
    end
%     saveas(gcf, tit, 'svg')
%     saveas(gcf, [tit '.png'])
end

return

%test residuals for normality and perform kruskal-wallis tests for
%significant differences between frequencies
for curr_group = 1:3
    for curr_amp = 1:3
        clear anova_vec
        for curr_freq = 1:3
            [h{curr_group}(curr_amp,curr_freq)] = adtest(intensities_groups{curr_group}{curr_amp, curr_freq});
            anova_vec(:,curr_freq) = intensities_groups{curr_group}{curr_amp, curr_freq}';
        end
        norm_fac(curr_group,curr_amp) = max(max(anova_vec)); %normalize to max so we don't get zeros
        [p(curr_group, curr_amp), tbl, stats] = kruskalwallis(anova_vec, [], 'off');
        mult_compares{curr_group, curr_amp} = multcompare(stats);
    end
end

%also test different amplitudes being significantly different in terms of
%shape (have to normalize)
colors = {'r', 'b', 'g'};
for curr_group = 1:3
    figure
    hold on
    friedman_vec = [];
    for curr_amp = 1:3
        friedman_cell{curr_amp} = [];
        for curr_freq = 1:3
            curr_int = intensities_groups{curr_group}{curr_amp, curr_freq}'/norm_fac(curr_group,curr_amp);
            friedman_cell{curr_amp} = [friedman_cell{curr_amp}; curr_int]; 
            plot(freqs(curr_freq), mean(curr_int), 'o', 'Color', colors{curr_amp}, 'MarkerFaceColor', colors{curr_amp});
        end
        friedman_vec = [friedman_vec, friedman_cell{curr_amp}];
    end
    [p2(curr_group), tbl, stats] = friedman(friedman_vec, 3);
    mult_compares_2{curr_group} = multcompare(stats);
end

