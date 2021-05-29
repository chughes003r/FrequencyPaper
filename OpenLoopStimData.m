classdef OpenLoopStimData < matlab.mixin.Heterogeneous
    % class to store data for open loop stimulation experiments
    
    properties
        trialType
        
        sessionInfo
        set
        block
        trialID
        rep = 0
        pathname
        pathname2
        
        channel
        amplitude
        frequency
        duration
        
        reportedData % substructure will vary for each trial type
        
        trialSkipped = false % invalid trials will be skipped
        trialMarkedBad = false % marked bad, typically after trial has ended via "Mark Last Trial Bad" button
        base_class_version
    end
    
    methods
        
        function obj = OpenLoopStimData(varargin)
            %obj = OpenLoopStimData(sessionInfo,set,channel,amplitude,frequency,duration,trialID,block,trialType)
            
            obj.base_class_version = 1.1; % first version with a version number (added trialMarkedBad)
            
            % apply any inputs
            props = {'sessionInfo' 'set' 'channel' 'amplitude' 'frequency' 'duration' 'trialID' 'block' 'trialType','rep', 'pathname', 'pathname2'};
            for iArg = 1:nargin % if there are no inputs this won't run
                temp = varargin{iArg};
                if ~isempty(temp)
                    obj.(props{iArg}) = temp;
                end
            end
            obj.reportedData.comments = ' ';
        end
        
        function tldata = LoadTestLogData(obj)
            sessnum     = obj.sessionInfo.session_num;
            setnum      = obj.set;
            trialtype   = obj.trialType;
            subjName = obj.sessionInfo.subject_name;
            if ~isempty(strfind(subjName,'Lab'))
                subjName(end-2:end) = []; % remove 'Lab' from end of subject name
            end
            [~,session] = searchAllLogs(trialtype,'sessnum',sessnum,'subject',subjName);
            tldata      = session.sets(setnum);
        end
        function yamlData = loadYamlData(obj)
            sessnum     = obj.sessionInfo.session_num;
            setnum      = obj.set;
            trialnum    = obj.trialID;
            repnum      = obj.rep;
            subjName = obj.sessionInfo.subject_name;
            subjShort = subjName;
            if ~isempty(strfind(subjShort,'Lab'))
                subjShort(end-2:end) = []; % remove 'Lab' from end of subject name
            elseif ~isempty(strfind(subjShort,'Home'))
                subjShort(end-3:end) = []; % remove 'Home' from end of subject name
            end
            if isunix
                drivePath = '/Volumes/RnelShare/data_raw';
            else
                drivePath = '\\192.168.0.227\RnelShare\data_raw';
            end
            stimDataPath = [drivePath filesep 'human' filesep 'crs_array' filesep subjShort filesep 'OpenLoopStim' filesep];
            sessionPath = [stimDataPath subjName '.data.' num2str(sessnum,'%.5d') filesep];
            fileroot = ['Resp.Set' num2str(setnum,'%.4d') '.Trial' num2str(trialnum,'%.4d') '.Rep' num2str(repnum,'%.4d') '_'];
            fullFileRoot = [sessionPath fileroot];
            
            try
                yamlData.radioCheckSlider = ReadYaml([fullFileRoot 'RadioCheckSlider.yml']);
            catch ME
                warning('Error reading radio check slider yaml')
                yamlData.radioCheckSlider = [];
            end
            try
                yamlData.imPixel = ReadYaml([fullFileRoot 'imPixel.yml']);
            catch ME
                warning('Error reading imPixel yaml')
                yamlData.imPixel = [];
            end
            try
                yamlData.dirPixel = ReadYaml([fullFileRoot 'dirPixel.yml']);
            catch ME
                warning('Error reading dirPixel yaml')
                yamlData.dirPixel = [];
            end
            
        end
        function im = loadProjectedFieldDrawings(obj)
            sessnum     = obj.sessionInfo.session_num;
            setnum      = obj.set;
            trialnum    = obj.trialID;
            repnum      = obj.rep;
            subjName = obj.sessionInfo.subject_name;
            subjShort = subjName;
            if ~isempty(strfind(subjShort,'Lab'))
                subjShort(end-2:end) = []; % remove 'Lab' from end of subject name
            elseif ~isempty(strfind(subjShort,'Home'))
                subjShort(end-3:end) = []; % remove 'Home' from end of subject name
            end
            if isunix
                drivePath = '/Volumes/RnelShare/data_raw';
            else
                drivePath = '\\192.168.0.215\RnelShare\data_raw';
            end
            stimDataPath = [drivePath filesep 'human' filesep 'crs_array' filesep subjShort filesep 'OpenLoopStim' filesep];
            sessionPath = [stimDataPath subjName '.data.' num2str(sessnum,'%.5d') filesep];
            fileroot = ['Resp.Set' num2str(setnum,'%.4d') '.Trial' num2str(trialnum,'%.4d') '.Rep' num2str(repnum,'%.4d') '_'];
            fullFileRoot = [sessionPath fileroot];
            
            fileTypes = {'palmer.png' 'dorsum.png' 'arms.png'};
            im = {};
            for iFile = 1:length(fileTypes)
               fullFileName = [fullFileRoot fileTypes{iFile}];
               if exist(fullFileName,'file')
                   im{end+1} = imread(fullFileName);
                   figure;imshow(im{end})
               end
            end
            
        end
        function vmdata = LoadVMData(obj)
            vmdata = [];
            datadir = obj.sessionInfo.session_lastdir;
            subjname = regexprep(obj.sessionInfo.subject_name,'Lab',''); %deletes Lab suffix if exists
            
            % condense this
            setnum         = rename(obj.set,'Set');
            block_ID       = rename(obj.block,'Block');
            trial_ID       = rename(obj.trialID,'Trial');
            repnum         = rename(obj.rep,'Rep');
            
            pathStr    = ['\\192.168.0.215\RnelShare\analysis\crs_array' filesep subjname filesep 'DataConversion\' datadir filesep];
            file   = dir([pathStr '\*.mat']);
            file   = {file.name};
            runlabel= [setnum block_ID trial_ID repnum];
            i_targ  = ~cellfun(@isempty, regexp(file,runlabel));
            file   = file(i_targ);
            if ~isempty(file)
                file = char(strcat(pathStr,file));
                vmdata    = load(file);
            else
                warning('No voltage monitor data was found for: %s',runlabel);
            end
        end
        function loadReceptiveFields(obj)
            if isfield(obj.reportedData,'RF')
                if any(obj.reportedData.RF.handp)
                    picdir     = fullfile(getHstPath,'ImageBank\ReceptiveFields\Large Images\Hand Palmer',filesep);
                    loadpics(picdir,obj.reportedData.RF.handp,'handp');
                end
                if any(obj.reportedData.RF.handd)
                    picdir     = fullfile(getHstPath,'ImageBank\ReceptiveFields\Large Images\Hand Dorsum',filesep);
                    loadpics(picdir,obj.reportedData.RF.handd,'handd');
                end
                if any(obj.reportedData.RF.arms)
                    picdir     = fullfile(getHstPath,'ImageBank\ReceptiveFields\Large Images\Arms',filesep);
                    loadpics(picdir,obj.reportedData.RF.arms,'arms');
                end
                if any(obj.reportedData.RF.head)
                    picdir     = fullfile(getHstPath,'ImageBank\ReceptiveFields\Large Images\Head',filesep);
                    loadpics(picdir,obj.reportedData.RF.head,'head');
                end
            end
            if ~isempty(obj.sessionInfo) && isfield(obj.sessionInfo,'subjStimMapFile') && ~isempty(obj.sessionInfo.subjStimMapFile)
                stimmap = load(obj.sessionInfo.subjStimMapFile);
                antped  = stimmap.stimMapData(1).cerestimChan;
                postped = stimmap.stimMapData(2).cerestimChan;
                cmap = colormap(jet(100));
                figure('name','Cerestim Stimulation Amplitude Config','position',[1207 92 314 840]);
                hmed = subplot(2,1,1);
                hlat = subplot(2,1,2);
                a_hm = heatmap(antped,[],[],'%0.0f%','parent',hlat,'Colormap',cmap,'NaNColor',[0 0 0]);
                p_hm   = heatmap(postped,[],[],'%0.0f%','parent',hmed,'Colormap',cmap,'NaNColor',[0 0 0]);
                title(hlat,'Lateral Array');
                title(hmed,'Medial Array');
                postamp = []; l_Pchans = false(size(postped));
                antamp  = []; l_Achans = false(size(antped));
                for i = 1:length(obj.channel)
                    pflag = postped  == obj.channel(i);
                    if any(any(pflag,1))
                        postamp(end + 1)    = obj.amplitude(i);
                        l_Pchans = pflag | l_Pchans;
                        postped(pflag)   = obj.amplitude(i);
                    end
                    aflag = antped  == obj.channel(i);
                    if any(any(aflag))
                        antamp(end + 1)     = obj.amplitude(i);
                        l_Achans = aflag | l_Achans;
                        antped(aflag)   = obj.amplitude(i);
                    end
                end
                % Posterior
                blankind = find(~l_Pchans & ~isnan(postped));
                blankind = [blankind blankind+numel(postped)  blankind+(numel(postped)*2)];
                p_hm.CData(blankind) = ones(size(blankind,1),3);
                actind = find(l_Pchans);
                if ~isempty(actind)
                    actind = [actind actind+numel(postped)  actind+(numel(postped)*2)];
                    p_hm.CData(actind) = cmap(postamp,:);
                end
                % Anterior
                blankind = find(~l_Achans & ~isnan(antped));
                blankind = [blankind blankind+numel(postped)  blankind+(numel(postped)*2)];
                a_hm.CData(blankind) = ones(length(blankind),3);
                actind = find(l_Achans);
                if ~isempty(actind)
                    actind = [actind actind+numel(postped)  actind+(numel(postped)*2)];
                    a_hm.CData(actind) = cmap(antamp,:);
                end
                hc = colorbar('location','NorthOutside','position',[0.1304    0.5073    0.7750    0.0317]);
                xtick = get(hc,'xtick');
                set(hc,'xtick',[xtick(1)-2 xtick(end)+4],'xticklabel',{'0','100'});
            end
            display(sprintf('comments:\n%s',obj.reportedData.comments))
        end
    end
    
    methods (Static)
        consolidateStimData(sessionNum,subjectID,local,overwrite)
    end
    
end
function loadpics(picdir,rfdata,rfloc)
filenames   = dir(fullfile(picdir,'*.png'));
picnames    = {filenames.name};
figure('name',rfloc,'position',[724 528 396 420]); h_ax = gca; hold on;
cellcutoff  = find(not(cellfun('isempty', regexp(picnames,'TopLayer'))));
corelayers  = picnames(cellcutoff:length(picnames));
%picnames(cellcutoff:length(picnames)) = [];
switch rfloc
    case 'handp'
        picnames = {'Pt4','P8','P4','P3','P2','Pi7','Pi8','Pi6','Pi5','Pm5','Pm6','Pt3','Pr7','Pr8','Pr6','Pr5','Pl8','Pl7','Pl5','Pl6','Pt2','P5','Pt5','Pi3','Pi4','Pi1','Pm1','Pm2','Pm4','Pr3','Pr4','Pr2','Pr1','Pt6','Pl4','Pl3','Pl2','Pt1','Pi2','Pm3','Pm8','Pm7','Pl1','P10','P9','P1','P6','P7'}; % defined in this order for (stupid) historical reasons
        picnames = strcat(picnames,'.png');
    case 'handd'
        picnames = {'Dl1','Dl2','D3','Dm2','Dm1','Di3','Di1','Dt1','Dt2','Di2','Dl3','D2','D4','Dr1','Dr2','Dr3','Dm3','D1'};
        picnames = strcat(picnames,'.png');
    case 'arms'
        picnames = {'B8' 'B7' 'F5' 'F4' 'F3' 'F2' 'F7' 'F8' 'F9' 'B9' 'B11' 'B10' 'B6' 'B5' 'B4' 'B3' 'B1' 'B2' 'F1' 'F6'};
        picnames = strcat(picnames,'.png');
    case 'head'
        picnames = {'H2' 'H1' 'H8' 'H10' 'H11' 'H3' 'H4' 'H9' 'H7' 'H6' 'H13' 'H12' 'H5'};
        picnames = strcat(picnames,'.png');
    
end
picnames = picnames(logical(rfdata));
%Display contours
[img,~,alpha] = imread(strcat(picdir,corelayers{1}));
image(img,'Parent',h_ax,'AlphaData',alpha);
for i=1:length(picnames)
    [img,~,alpha] = imread(strcat(picdir,picnames{i}));
    image(img,'Parent',h_ax,'Visible','on','AlphaData',alpha);
end
clim = size(img(:,:,1));
set(h_ax,'XLim',[0 clim(2)],'YLim',[0 clim(1)],'YDir','reverse','XTickLabel',[],'YTickLabel',[],'DataAspectRatio',[1 1 1]);
end
function nameout = rename(namein,type)
nameout   = '0000';
num       = num2str(namein);
i_num     = 5-length(num);
nameout(i_num:end) = num2str(num);
nameout    = [type nameout '.'];
end