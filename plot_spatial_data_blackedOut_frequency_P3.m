function plot_spatial_data_blackedOut_frequency_P3(data_vector, tit, colormapping) 
% data_vector = values per channel (1x64) 
% colormapping = 'somatotopic' or 'intensity' 
%specifically for the frequency preference stuff

if ~exist('colormapping','var')
   %colormapping = parula(3);
    colormapping = [51,160,44; 106,61,154];%taken from colorbrewer   
    colormapping = colormapping/255;
    colormapping = [0 0 0; colormapping];
end
%% define the spatial layout
%A map of how each of the NeuroPort connectors should be connected to the
%CereStim output channels. This is defined by us.  The orientation is the
%same as above. Electrodes that are not wired to the Cerestim connector
%are identified as NaN.
%Should reflect how electrode array gets mapped to bank C connector
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
%%
stimData = zeros(size(stimChans));
figure
for i = 1:size(data_vector, 1) 
     [r, c] = find(stimChans == i);
        stimData(r,c) = data_vector(i);         
end

%at this point, disconnected channels are 0 and no data is NaN
%stimData(stimData ~= 0) = log(stimData(stimData ~= 0)); %if we want to log
%transform  - doesn't seem to work well for detection data
stimData(stimData == 0) = -1; %make disconnected channels -1
stimData(isnan(stimData)) = 0; %make no data 0
stimData(stimData == -1) = nan; %make disconnected channels nan

curr_plot = stimData(1:10,:);
unq_vals = unique(curr_plot);
unq_vals = unq_vals(~isnan(unq_vals));
curr_colormap = colormapping(unq_vals+1,:);
for group = 1:length(unq_vals)
    curr_plot(curr_plot == unq_vals(group)) = group - 1;
end

p = pcolor([curr_plot nan(10,1); nan(1,size(stimData,2)+1)]);

shading flat;
daspect([1 1 1])
set(gca, 'Color', [0.7 0.7 0.7])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
p.EdgeColor = [0 0 0];
set(gca, 'ydir', 'reverse'); 
 
title('Lateral Array');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
colormap(curr_colormap);
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 14;%20;
ax.FontWeight = 'bold';
c = colorbar;
tick_labels{1} = 'Not tested';
for curr_tick = 2:length(unq_vals)
    tick_labels{curr_tick} = ['Group ', num2str(unq_vals(curr_tick))];
end
numticks = c.Ticks(end);
inc = numticks/(length(tick_labels)*2);
c.Ticks = inc:inc*2:length(tick_labels);
c.TickLabels = tick_labels;

figure

%having issues with color mapping
curr_plot = stimData(12:end,:);
unq_vals = unique(curr_plot);
unq_vals = unq_vals(~isnan(unq_vals));
curr_colormap = colormapping(unq_vals+1,:);
for group = 1:length(unq_vals)
    curr_plot(curr_plot == unq_vals(group)) = group - 1;
end

p = pcolor([curr_plot nan(10,1); nan(1,size(stimData,2)+1)]);

shading flat;
daspect([1 1 1])
set(gca, 'Color', [0.7 0.7 0.7])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
p.EdgeColor = [0 0 0];
set(gca, 'ydir', 'reverse'); 

colormap(curr_colormap);
title('Medial Array');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 14;%20;
ax.FontWeight = 'bold';
c = colorbar;
tick_labels{1} = 'Not tested';
for curr_tick = 2:length(unq_vals)
    tick_labels{curr_tick} = ['Group ', num2str(unq_vals(curr_tick))];
end
numticks = c.Ticks(end);
inc = numticks/(length(tick_labels)*2);
c.Ticks = inc:inc*2:length(tick_labels);
c.TickLabels = tick_labels;

