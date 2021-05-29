classdef DiscriminationData < OpenLoopStimData
    properties
        testedParameter
        compareVal
        interStimulusInterval % duration between two stimuli
        success
        sequenceOrder % 1: [std amp, comp amp], 2: [comp amp, std amp]
        discardedTrial = false
    end
    
    methods
        function obj = DiscriminationData(varargin)
            obj@OpenLoopStimData(varargin{:}); % explicitly call superclass constructor w/ args
            obj.trialType = 'Discrimination';
            
%             if isempty(obj.amplitude)
%                 obj.amplitude.standardAmp = []; % aka amplitude 1
%                 obj.amplitude.comparisonAmp = []; % aka amplitude 2
%             end
            
            obj.reportedData.strongerStimulus = []; % 1 or 2
            obj.reportedData.relativeLocation = []; % for location discrimination 'Up','Down','Left','Right'
            
        end
    end
    
end