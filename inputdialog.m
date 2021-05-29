function [opt]=inputdialog(options,dialog)
hfig=figure('CloseRequestFcn',@close_req_fun,'menu','none');
opt_list=options;
%set defaults
str1=dialog;
opt=opt_list{1};
%create GUI
set(hfig,'menu','none')
field1=uicontrol('Style', 'Edit', 'String', str1, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.1, .75, .8, .15]);
dropdown=uicontrol('Style', 'popupmenu', 'String', opt_list, ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.1, .35, .8, .15]);
uicontrol('Style', 'pushbutton', 'String', 'OK', ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.1 .1 .35 .2],...
    'Callback','close(gcbf)');
cancel=uicontrol('Style', 'pushbutton', 'String', 'cancel', ...
    'Parent',hfig,'Units','Normalized', ...
    'Position', [.55 .1 .35 .2],...
    'Tag','0','Callback',@cancelfun);
%wait for figure being closed (with OK button or window close)
uiwait(hfig)
%figure is now closing
if strcmp(cancel.Tag,'0')%not canceled, get actual inputs
    str1=field1.String;
    opt=opt_list{dropdown.Value};
end
%actually close the figure
delete(hfig)
end
function cancelfun(h,~)
set(h,'Tag','1')
uiresume
end
function close_req_fun(~,~)
uiresume
end