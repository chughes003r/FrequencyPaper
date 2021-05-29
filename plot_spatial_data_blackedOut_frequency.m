function plot_spatial_data_blackedOut_frequency(data_vector, tit, colormapping) 
% data_vector = values per channel (1x64) 
% colormapping = 'somatotopic' or 'intensity' 
%specifically for the frequency preference stuff

if ~exist('colormapping','var')
   %colormapping = parula(3);
   colormapping = [31,120,180; 106,61,154; 51,160,44];
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
              nan	nan	nan	18	nan	30;
                5	15	12	nan	24	nan;
              nan	2	nan	20	nan	29;
                7	nan	14	nan	25	nan;
              nan	4	nan	19	nan	32;
                9	nan	16	nan	26	nan;
              11	6	nan	22	nan	31 ];
          
stimChanM = stimChanM + 32; 
                    
% stimChanM  = rot90(stimChanM, 2);
% stimChanL  = rot90(stimChanL, 2);
stimChans = [stimChanL; zeros(1,6); stimChanM];
%%
stimData = zeros(size(stimChans));
figure;
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


subplot(2,1,2)

% img = imagesc(stimData(1:10,:));
% daspect([1 1 1])

p = pcolor([stimData(1:10,:) nan(10,1); nan(1,size(stimData,2)+1)]);
shading flat;
daspect([1 1 1])
set(gca, 'Color', [0.7 0.7 0.7])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
p.EdgeColor = [0 0 0];
set(gca, 'ydir', 'reverse'); 


 
%trying to align bottom title correctly
% if strcmp(tit, 'Day 1000')
%     xpos = 2;
% else
%     xpos = 2.5;
% end
 
%title('Lateral Array');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
%hcb=colorbar('southoutside');
%greaterThan = max( max(stimData));
%set(hcb,'YTick',[0, 20, 40, 60, 80, greaterThan])
%set(hcb,'YTickLabel',{'Not Connected', 20, 40, 60, 80, '> Max'})
colormap(colormapping);
%t = text(xpos, 0, tit, 'FontSize', 16, 'FontWeight', 'bold');
%set(t, 'HorizontalAlignment', 'center')
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 14;%20;
ax.FontWeight = 'bold';
% ax.CLim = [0,70]; 
c = colorbar;
% c.Ticks = [0, 10:10:70];
% c.TickLabels = ([{'Not tested'} {'<10'} {20} {30} {40} {50} {60} {'>70'}]);
c.Ticks = [0:3];
c.TickLabels = [{'Not tested'}, {'Type I'}, {'Type II'}, {'Type III'}];

%des_ticks = ([0 log([2 5 10 20 40 80])]);
% c = colorbar; 
%c.Ticks = des_ticks;%min(c.Ticks):(max(c.Ticks)-min(c.Ticks))/5:max(c.Ticks);
% ticks = c.Ticks;
% ticks = round(exp(ticks), -1);
% c.TickLabels = ([{'Not tested'}, {2}, {5}, {10}, {20}, {40}, {'>80'}]);
% c.Limits = [0,max(c.Ticks)];

%caxis([0 16])

subplot(2,1,1)


%imagesc(stimData(12:end,:))
p = pcolor([stimData(12:end,:) nan(10,1); nan(1,size(stimData,2)+1)]);
shading flat;
daspect([1 1 1])
set(gca, 'Color', [0.7 0.7 0.7])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
p.EdgeColor = [0 0 0];
set(gca, 'ydir', 'reverse'); 


colormap(colormapping);
%caxis([0 16])
%title('Medial Array');
set(gca, 'XTick', []);
set(gca, 'YTick', []);
ax = gca;
ax.FontName = 'Arial';
ax.FontSize = 14;%20;
ax.FontWeight = 'bold';
% ax.CLim = [0,70]; 
c = colorbar;
% c.Ticks = [0, 10:10:70];
% c.TickLabels = ([{'Not tested'} {'<10'} {20} {30} {40} {50} {60} {'>70'}]);
c.Ticks = [0:3];
c.TickLabels = [{'Not tested'}, {'Type I'}, {'Type II'}, {'Type III'}];

% des_ticks = ([0 log([2 5 10 20 40 80])]);
% c = colorbar; 
% c.Ticks = des_ticks;%min(c.Ticks):(max(c.Ticks)-min(c.Ticks))/5:max(c.Ticks);
% % ticks = c.Ticks;
% % ticks = round(exp(ticks), -1);
% c.TickLabels = ([{'Not tested'}, {2}, {5}, {10}, {20}, {40}, {'>80'}]);
% c.Limits = [0,max(c.Ticks)];
