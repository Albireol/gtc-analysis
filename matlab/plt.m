%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc,clear;close all; 
plt_panel=figure('Unit','normalized',...
   'Position',[0.01 0.85 0.42 0.05], ...
   'Resize','on','menubar','none',...
   'numbertitle','off','name','GTC Data Processing GUI -- Main');

plt_str={'Exit','History','Snapshot','Equilibrium','Radil-time','Fieldm'};

for i=1:6
    plt_btm(i) = uicontrol(plt_panel,'style','pushbutton','units','normalized',...
        'position',[0.04+(i-1)*0.16,0.1,0.15,0.8],'string',plt_str(i));
end

set(plt_btm(1),'callback','close all; clear all; clc;');
set(plt_btm(2),'callback','history');
set(plt_btm(3),'callback','snapshot');
set(plt_btm(4),'callback','equilibrium');
set(plt_btm(5),'callback','rtime');
set(plt_btm(6),'callback','fieldm; plt;');

% 2011-10-23 20:39, version1.0 is OK, which is just the same framework of
% the idl version. plt.m, equilibrium.m, rtime.m, history.m, snapshot.m.
% v1.3, 2014-03-27 09:05
% fieldm.m, snapmovie.m, tracking.m ... , should be run separately
% % Shortcut summary goes here
% path='D:\cluster\TH-1A\gtc\gtc_gui\v1.3\';
% edit([path,'setpath.m']);
% edit([path,'history.m']);
% edit([path,'cal_gamma.m']);
% edit([path,'cal_omega.m']);
% edit([path,'snapmovie.m']);
% edit([path,'fieldm.m']);
% edit([path,'snapshot.m']);
% edit([path,'open_gtcin.m']); 
% edit([path,'rtime.m']);
% edit([path,'equilibrium.m']);
