%code for detection at different frequencies
load('allData_detection')

%% calculate success for each frequency on each tested electrode
box_plot = zeros(size(allData_detection,2),3);
for data_cnt = 1:length(allData_detection)
    curr_data = allData_detection{data_cnt}; %, curr_set+1
    chan = curr_data(1,1).channel;

    %calculate success for current set
    clear success
    test_freq = [20,100,300];
    for curr_freq = 1:length(test_freq)
        freq = test_freq(curr_freq);
        cnt = 1;
        for data_cnt2 = 1:length(curr_data)
            if curr_data(1,data_cnt2).compareVal == freq
                success(curr_freq,cnt) = curr_data(1,data_cnt2).success;
                cnt = cnt + 1;
            end
        end
    end

    for freq = 1:size(test_freq,2)
        box_plot(data_cnt, freq) = mean(success(freq,:)*100);
    end
end

%work around for plotting mean and std with boxplot
box_plot_mean(1,:) = max(box_plot);
box_plot_mean(2,:) = mean(box_plot)+std(box_plot);
box_plot_mean(3,:) = mean(box_plot);
box_plot_mean(4,:) = mean(box_plot)-std(box_plot);
box_plot_mean(5,:) = min(box_plot);

%% plot boxplot with means and std
figure('OuterPosition',[0 0 1680 1050]);
hold on
b1 = bar(box_plot_mean(3,:));
b2 = errorbar(box_plot_mean(3,:), std(box_plot), 'b', 'LineStyle','none', 'LineWidth', 2);
jitter = [0, 0.05, -0.05, 0.1];
for i = 1:size(box_plot,1)
    scatter([1,2,3]+jitter(i), box_plot(i,:), 'ko', 'MarkerFaceColor', 'k')
end
xlabel('Tested Frequencies');
ylabel('Percent Correct')
ax = gca;
ax.FontName = 'Arial';
ax.FontWeight = 'bold';
ax.FontSize = 18;
boxes = ax.Children.Children;
set(boxes, 'LineWidth', 2)
ax.YLim = [0, 100];
ax.XLim = [0, 4];
ax.XTick = [1,2,3];
ax.XTickLabel = [{'20 Hz'}, {'100 Hz'}, {'300 Hz'}];
yline(50, 'r--')
axis square

%% Stats
%anova with multiple comparisons to compare outcome for each frequency
[p tbl stats] = anova1(box_plot);
[c,m,h,nms] = multcompare(stats);

