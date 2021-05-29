classdef MagnitudeEstimationData < OpenLoopStimData
    
    properties
        discardedTrial = false
    end
    
    methods
        function obj = MagnitudeEstimationData(varargin) 
            obj@OpenLoopStimData(varargin{:}); % explicitly call superclass constructor w/ args
            obj.trialType = 'Magnitude Estimation';
            
            obj.reportedData.magnitude = [];
            
        end
    end 
end