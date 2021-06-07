%code that generalizes magnitude estimation stuff for any parameters
%replaced all vars named "set" with sett because of function named set
%idx will select data for a specific session, set, and frequency (which
%necessarily also limits it to one electrode)

%resps_org will organize the responses into cells by either electrode or
%group and by parameter. Within the cell, each value will be a mean from a
%different session/set. 

%resps_org_2 is similar to resps_org but all data is maintained (the mean
%is not calculated)

%resps_org_3 instead organizes the data into cells by electrode. Within a
%cell, the columns are different frequencies and the rows are groups for a
%given session. For each session, there should be 6 reps of the frequency
%presentation meaning the input for anova2 reps should be size('',1)/6. 



function [resps_org, peak_param, resps_org_2, resps_avg, coeffs, max_intensities, resps_org_3, val] = magEst_responses(resps, params, groups, chans, allLTsessions, allLTsetts, master_idx, grouping, print_imgs, error_bars, mode, aggregate, fit_type, elecs_int)
color_scheme = [166,206,227; 31,120,180; 178,223,138; 51,160,44; ...
251,154,153; 227,26,28; 253,191,111; 255,127,0; 202,178,214; ...
106,61,154; 255,255,153; 177,89,40]; %taken from colorbrewer
color_scheme = color_scheme/255; %scaling for MATLAB
color_bar = colormap(color_scheme);

if mode == 2
    unq_param = unique(params);
    unq_param = unq_param(2:end);
else
    unq_param = unique(params);
end

unq_sessions = unique(allLTsessions);
unq_setts = unique(allLTsetts);

%can maybe integrate cb_idx better
cb_idx = floor(length(color_bar)/length(groups)); %for breaking up colors
group_idx = 1; %will have to use this for saving instead of group with addition of elec_cnt
if aggregate %have to make figure here if we want all data on same plot
    figure('OuterPosition',[0 0 1680 1050]);
    hold on
end
for group = 1:length(groups) %elec = unique(chans) %
    jit_par = unq_param(1)/2; %put it here when aggregating
    if rem(group,2) == 0 %even
        jitter = -1*jit_par*(ceil(group/2)); %so error bar doesn't cover points
    else %odd
        jitter = jit_par*(ceil(group/2)); %so error bar doesn't cover points
    end
    max_vals = [];
    if ~aggregate
        clear subset legend_idx
    end
    if grouping 
        cb = color_bar(1,:);
        if ~aggregate %if we are not aggregating, elec_cnt becomes the same as group
            elecs = groups{group};
        else
            elecs{1} = groups{group}; %only make elecs a cell if aggregating
        end
    else
        cb = color_bar((1)*cb_idx+1,:); %group-1
        elecs = groups{group};
    end
    if ~aggregate %have to make figure here if we are plotting indiviual electrodes
        figure('OuterPosition',[0 0 1680 1050]);
        hold on
    end
    for elec_cnt = 1:length(elecs)
        if ~aggregate
            if length(elecs) > 1
                cb_idx = 1;
                cb = color_bar((elec_cnt-1)*cb_idx+1,:); %want different colors if not aggregating
            else
                cb_idx = 1; %doesn't matter because it is going to go to 1
                cb = color_bar((elec_cnt-1)*cb_idx+1,:); %want different colors if not aggregating
            end
        else
            cb_idx = floor(length(color_bar)/(length(groups)))-1; %for breaking up colors
            cb = color_bar((group-1)*cb_idx+1,:); %want different colors if not aggregating
        end      
        if ~aggregate
            elec = elecs(elec_cnt); %will be multiple electrodes if grouping
        else
            elec = elecs{1};
        end
        if elecs_int{group} == 0 %if we didn't define electrodes of interest  %changed these to group_idx from group 8/14/20
            if ~aggregate
                elecs_int{group} = elecs; %this is for when we are aggregating data  %changed these to group_idx from group 8/14/20
            else
                elecs_int{group} = elecs{1};  %changed these to group_idx from group 8/14/20
            end
        end
        if any(elecs_int{group} == elec) %can limit electrodes we want to plot  %changed these to group_idx from group 8/14/20
            elec_log = zeros(1, length(chans)); %this bit of code specific for grouping but should also work for individual channels
            %resps_org_3{group} = zeros(6*length(unq_sessions),length(unq_param)); %will have to remove zeros
            for elec_idx = elec 
                elec_log = elec_log + (chans == elec_idx);
            end
            for param_cnt = 1:length(unq_param)
                param = unq_param(param_cnt);
                rng('shuffle')
                resps_org{group_idx,param_cnt} = double.empty(length(unq_sessions),0);
                resps_org_2{group_idx,param_cnt} = [];
                resps_sum{group_idx,param_cnt} = double.empty(length(unq_sessions),0);
                resps_sett{group_idx,param_cnt} = double.empty(length(unq_sessions),0);
                for session_cnt = 1:length(unq_sessions)
                    session = unq_sessions(session_cnt);
                    for sett_cnt = 1:length(unq_setts) %added setts so that if parameters are repeated within days there isn't confusion
                        sett = unq_setts(sett_cnt);
                        idx = [params == param] & elec_log & [allLTsessions == session] & [allLTsetts == sett] & master_idx; %idx pulls out the trials from a given set
                        if ~aggregate %if we are not aggregating need to jitter different electrodes
                            jit_par = unq_param(1)/5;
                            mult = find(elecs_int{group} == elec); %switch between group and group_idx depending on data - need to fix this issue
                            if rem(mult,2) == 0 %even
                                jitter = -1*jit_par*(ceil(mult/2)); %so error bar doesn't cover points
                            else %odd
                                jitter = jit_par*(ceil(mult/2)); %so error bar doesn't cover points
                            end
                            %jitter = jit_par*mult; %so error bar doesn't cover points
                        else
                            jitter = 0;
                        end
                        if sum(idx) > 0%~isempty(find(idx)==1)
                            temp = resps(idx);
                            temp(temp==0) = 0.00001; %don't remove as zeros because these are real zeros
                            resps_org{group_idx,param_cnt}(session_cnt, sett_cnt) = nanmean(temp);
                            resps_org_2{group_idx,param_cnt} = [resps_org_2{group_idx,param_cnt}, temp];
                            %resps_org_3{group}((session_cnt-1)*6+1:session_cnt*6,param_cnt) = temp'; 
                            resps_sett{group_idx,param_cnt}(session_cnt, sett_cnt) = sett; %save sett so we know which data to use
                            resps_sum{group_idx,param_cnt}(session_cnt, sett_cnt) = nansum(temp);
                            std_session(group_idx, param_cnt) = nanstd(temp);
                        end
                    end
                end
                if ~isempty(resps_org{group_idx,param_cnt}) %don't want it to try to evaluate if it is empty 
                    zero_idx = resps_org{group_idx,param_cnt} == 0; 
                    resps_org{group_idx,param_cnt} = resps_org{group_idx,param_cnt}(~zero_idx); %remove zeros
                    zero_idx = resps_sett{group_idx,param_cnt} == 0; 
                    resps_sett{group_idx,param_cnt} = resps_sett{group_idx,param_cnt}(~zero_idx); %remove zeros
                    idx = [params == param] & elec_log & master_idx;
                    ax = gca;
                    resps_avg{group_idx}(1,param_cnt) = nanmean(resps_org_2{group_idx,param_cnt});
                    resps_avg{group_idx}(2,param_cnt) = param;
                    %the way the code is currently organized, resps_org_2
                    %should always be greater than 1 (includes all trials)
                    if length(resps_org_2{group_idx,param_cnt}) > 1 %use std from single session if there is not more than one
                        std_resps(group_idx, param_cnt) = nanstd(resps_org_2{group_idx,param_cnt});
                    else
                        std_resps(group_idx, param_cnt) = std_session(group_idx, param_cnt);
                    end
                    %this will get rid of extra measures at certain
                    %parameters
                    %this could still mess up if the first parameter has
                    %the most measures
                    if exist('resps_org_3', 'var')
                        if length(resps_org_3) == group_idx
                            if length(resps_org_2{group_idx,param_cnt}) == size(resps_org_3{group_idx},1)
                                resps_org_3{group_idx}(:,param_cnt) = resps_org_2{group_idx,param_cnt};
                            else
                                %resps_org_2{group_idx,param_cnt} = resps_org_2{group_idx,param_cnt}(1:size(resps_org_3{group_idx},1));
                                resps_org_3{group_idx}(:,param_cnt) = resps_org_2{group_idx,param_cnt}(1:size(resps_org_3{group_idx},1));
                            end
                        else
                            resps_org_3{group_idx}(:,param_cnt) = resps_org_2{group_idx,param_cnt};  
                        end
                    else
                        resps_org_3{group_idx}(:,param_cnt) = resps_org_2{group_idx,param_cnt};
                    end
                    if error_bars == 3
                        errorbar(param+jitter, resps_avg{group_idx}(1,param_cnt), std_resps(group_idx, param_cnt)/sqrt(length(resps_org_2{group_idx,param_cnt})), 'Color', cb, 'LineWidth', 2);
                        hold on
                    elseif error_bars == 2
                        errorbar(param+jitter, resps_avg{group_idx}(1,param_cnt), std_resps(group_idx, param_cnt), 'LineWidth', 2, 'Color',  cb);
                        hold on
                    end
                    plot(param+jitter, resps_avg{group_idx}(1,param_cnt), 'o', 'MarkerSize', 4, 'LineWidth', 2, 'MarkerFaceColor', cb, 'Color', cb) %mean(resps(idx)) elec, + jitter
                    max_vals = [max_vals resps_avg{group_idx}(1,param_cnt)+std_resps(group_idx,:)/sqrt(length(resps_org_2{group_idx,param_cnt}))];
                    hold on
                end
            end
        
            if fit_type == 1 %fitting the data with a function
                if mode == 1
                    %frequency
                    degree = 3;
                    xfit = [20 300 280];
                elseif mode == 2
                    %amplitude
                    degree = 1;
                    xfit = [20 80 60];
                elseif mode == 3
                    %train duration
                    degree = 3;
                    xfit = [0.1 2];
                end
                if mode == 3
 
                    
                    %add in the point [0,0] to make fit better (partcipant
                    %would report 0 with no stimulation)
                    resps_avg{group_idx} = horzcat([0;0], resps_avg{group_idx});
                    unq_param = [0, unq_param];
                    
                    max_resp = max(resps_avg{group_idx}(1,:));
                    %this will help in evaluating R^2
                    mdl = fitglm(unq_param, resps_avg{group_idx}(1,:)./max(resps_avg{group_idx}(1,:)),'Distribution','binomial');
                    
                    %this will be used for actually plotting
                    y = [resps_avg{group_idx}(1,:)', repmat(max_resp, size(resps_avg{group_idx},2), 1)];
                    [b, dev, stats] = glmfit(unq_param', y, 'binomial');
                    xfit = [0.1:0.01:2];
                    yfit = glmval(b,xfit,'logit', 'size', max_resp);
                    
                    
                    coeffs{group_idx} = b; %temporary solution
                    max_intensities(group_idx) = 0;
                    val = 0;
                else
                    %test different function types and find best fit
                    %according to AICc - for frequency and amplitude
                    mdl_func = {'power2', 'power1', 'exp1', 'exp2', 'poly3', 'poly2', 'poly1'}; 
                    for curr_mdl = 1:length(mdl_func)
                        [mdl, f] = non_linear_fit(unq_param',resps_avg{group_idx}(1,:)',  mdl_func{curr_mdl});
                        AIC(curr_mdl) = mdl.ModelCriterion.AIC;
                    end
                    if mode == 1
                        [min_val, des_mdl] = min(AIC);
                    elseif mode == 2
                        des_mdl = 7; %always use linear fit for amplitude
                    end
                    [mdl, f] = non_linear_fit(unq_param',resps_avg{group_idx}(1,:)', mdl_func{des_mdl});
                    coeffs{1,group_idx} = table2array(mdl.Coefficients);
                    coeffs{2,group_idx} = des_mdl;

                    x1 = linspace(xfit(1),xfit(2),xfit(3)); 
                end

                [null_val, loc] = max(resps_avg{group_idx}(1,:));
                peak_param(group_idx) = unq_param(loc);
                if mode == 3 %train duration
                    %h = plot(f, (unq_param+jitter)', resps_avg{group_idx}(1,:)'); %'LineWidth', 4
                    %h = plot(unq_params, resps_avg{group_idx}(1,:),'o',[0:0.01:2.5],yfit,'-','LineWidth',2)
                    h = plot(xfit+jitter,yfit);
                    set(h, 'Color' , cb, 'LineWidth', 2, 'MarkerEdgeColor', cb)
                    l = legend(h);
                    set(l, 'visible', 'off')
                    %subset(elec_cnt) = h(2);
                    subset(elec_cnt) = h;
                else
                    if ~aggregate
                        subset(elec_cnt) = plot(x1+jitter, f(coeffs{1,group_idx}(:,1),x1), 'Color', cb, 'LineWidth', 2);
                    else
                        subset(group) = plot(x1+jitter, f(coeffs{1,group_idx}(:,1),x1), 'Color', cb, 'LineWidth', 2);
                    end
                    [val(group_idx), max_intensities(group_idx)] = max(f(coeffs{1,group_idx}(:,1),x1));
                end
            elseif fit_type == 2 %connecting data with piecewise 
                    if ~aggregate
                        subset(elec_cnt) = plot(unq_param+jitter, resps_avg{group_idx}(1,:), 'Color', cb, 'LineWidth', 2);
                    else
                        subset(group) = plot(unq_param+jitter, resps_avg{group_idx}(1,:), 'Color', cb, 'LineWidth', 2);
                    end
                    [val(group_idx), max_intensities(group_idx)] = max(resps_avg{group_idx}(1,:));
                    peak_param(group_idx) = unq_param(max_intensities(group_idx));
                    coeffs{group_idx} = 0; %no coeffs
            end
            if error_bars == 4 % for filled areas for error
                if mode == 3
                    est_err = [0, std_resps(group_idx,:)/sqrt(length(resps_org))];
                else
                    est_err = [std_resps(group_idx,:)/sqrt(length(resps_org))];
                end
                fill([unq_param+jitter, unq_param(end:-1:1)+jitter, unq_param(1)+jitter],[resps_avg{group_idx}(1,:)+est_err, resps_avg{group_idx}(1,end:-1:1)-est_err(1,end:-1:1), est_err(1,1)], cb ,'EdgeColor','none');
                alpha(0.25);
            end
            group_idx = group_idx + 1;
            legend_idx{elec_cnt} = ['Electrode ' num2str(elec)];
        end
    end
    ax = gca;
    ax.FontName = 'Arial';
    ax.FontWeight = 'bold';
    ax.FontSize = 18;
    if mode == 1
        xlabel('Stimulation Frequency (Hz)')
        if ~aggregate
            ymax = max(max_vals);
        else
            ymax = max(val);
        end
        axis([0 320 0 ymax]) %max_plot
    elseif mode == 2
        xlabel('Stimulation Amplitude (\muA)')
        ymax = max(max_vals);
        %ymax = 3.1241; %from results
        ymin = 0;
        axis([10 90 ymin ymax]) %max_plot
    elseif mode == 3
        xlabel('Train Duration (s)')
        ymax = max(max_vals);
        ymin = 0;
        %ymax = 1.4618;
        axis([0 2.1 ymin ymax]) %max_plot
    end
    ylabel('Reported Magnitude (a.u.)')
    num_setts = length(resps_org{group,2});
    if num_setts == 1
        word = 'set';
    else
        word = 'sets';
    end
    if grouping
        if mode == 1
            add_name = 'Frequency';
        elseif mode == 2 
            add_name = 'Amplitude';
        elseif mode == 3
            add_name = 'Duration';
        end
        tit = strcat(['Group ', num2str(group), ' ', add_name]);
    else
        tit = strcat(['Electrode ', num2str(elec), ' (', num2str(num_setts), ' ', word, ')']);
    end
    %title(tit)
    %legend_idx{group} = ['Electrode ' num2str(elec)];
    axis square
    %max_plot = max(resps_avg{group}(1,:))+max(std_resps(group, :))
    %hold off - disable for aggregate
    if ~aggregate
        clear leg_idx
        for curr_leg = 1:length(legend_idx)
            if ~isempty(legend_idx{curr_leg}) 
                leg_idx(curr_leg) = true;
            else
                leg_idx(curr_leg) = false;
            end
        end
        legend_idx = legend_idx(leg_idx);
        subset = subset(leg_idx);
        legend(subset, legend_idx, 'Location', 'northeastoutside')
        %axis([unq_param(1)-unq_param(1)/2 unq_param(end)+unq_param(1)/2 0 max(max_vals)+0.1])
    end
    if print_imgs && ~aggregate
        print(tit, '-dpng')
    end
end
if aggregate && mode == 1
    legend(subset, [{'Intermediate Frequency Preferring'}, {'Low Frequency Preferring'}, {'High Frequency Preferring'}], 'Location', 'northeastoutside')
    %print('All median trends', '-dpng')
elseif aggregate && mode == 2
    %print('All median trends amplitude', '-dpng')
elseif aggregate && mode == 3
    %print('All median trends duration', '-dpng')
end
end


