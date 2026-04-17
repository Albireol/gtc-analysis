% myh ustc GTC snapshot to movie, v4.6
% snapmovie.m, 2D moive
close all;clear;clc;

run setpath;
run read_para;
%% read history.out
hsty_data=load([path,'history.out']);

ndstep=hsty_data(1);nspecies=hsty_data(2);mpdiag=hsty_data(3);
nfield=hsty_data(4);modes=hsty_data(5);mfdiag=hsty_data(6);
tstep=hsty_data(7); % tstep*ndiag
ndata=nspecies*mpdiag+nfield*(2*modes+mfdiag);

% ntime=ndstep;
ntime=floor(length(hsty_data)/ndata);
xtime=(1:ntime)';

% set movie range, read "snap(nt0).out", "snap(nt0+nplot).out", ...
nt0=1000; nt=10000; nplot=1000; % modify here !!!

figure('position',[50 50 800 600]);
set(gca,'nextplot','replacechildren');
set(gcf,'DefaultAxesFontSize',15);



%% read snap*.out and plot
jp=1;

for ip=nt0:nplot:nt
    
    snap_data=load([path,'snap00',num2str(ip,'%5.5d'),'.out']);
    
    if(ip==nt0)
        nspecies=snap_data(1);
        nfield=snap_data(2);
        nvgrid=snap_data(3);
        mpsi=snap_data(4)-1; % snap_data(4)=mpsi+1
        mtgrid=snap_data(5)-1; % snap_data(5)=mtgrid+1
        mtoroidal=snap_data(6);
        tmax=snap_data(7); % snap_data(7)=1.0/emax_inv

        mmode=round(mtgrid/5);
        pmode=round(mtoroidal/5);
        cutoff=-1.0;    
    
        % read profile, pdf, poloidata, fluxdata data1d from snapshot file
        ind1=7;
        ind2=7+(mpsi+1)*nspecies*6;   
    
%         for k=1:nspecies
%             for j=1:6
%                 for i=1:mpsi+1
%                     ind=ind1+((j-1)+(k-1)*6)*(mpsi+1)+i;
%                     profile(i,j,k)=snap_data(ind);
%                 end
%             end
%             for j=1:4
%                 for i=1:nvgrid
%                     ind=ind2+((j-1)+(k-1)*4)*nvgrid+i;
%                     pdf(i,j,k)=snap_data(ind);
%                 end
%             end
%         end

        ind3=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies;
        ind4=7+(mpsi+1)*6*nspecies+nvgrid*4*nspecies+(mtgrid+1)*(mpsi+1)*(nfield+2); 
    end
    
    for i=1:mtgrid+1
        for j=1:mpsi+1
            for k=1:nfield+2
                ind=ind3+((j-1)+(k-1)*(mpsi+1))*(mtgrid+1)+i;
                poloidata(i,j,k)=snap_data(ind);
            end
        end
%         for j=1:mtoroidal
%             for k=1:nfield
%                 ind=ind4+((j-1)+(k-1)*mtoroidal)*(mtgrid+1)+i;
%                 fluxdata(i,j,k)=snap_data(ind);
%             end
%         end
    end
    x=poloidata(:,:,nfield+1);
    y=poloidata(:,:,nfield+2);
    
    subplot(221);    
    f=poloidata(:,:,1);
    pcolor(x,y,f); axis equal; axis tight; shading('interp');
    title('Snapshot \phi');
%     [C,h]=contourf(x,y,f,100);hold on;colormap('jet')
%     set(h,'linecolor','none');
%     set(gca,'dataaspectratio',[1,1,1]);
%     colorbar;
%     set(gca,'fontsize',16,'linewidth',2);
%     xlabel('$X/R_0$','interpreter','latex','fontsize',20)
%     ylabel('$Z/R_0$','interpreter','latex','fontsize',20)
%     hold on
%     plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
%     hold on
%     plot(x(:,q_min_flux),y(:,q_min_flux),'-.k','linewidth',1);
%     
%     
% 

    
    subplot(222);
    f=poloidata(:,:,2);
    pcolor(x,y,f); axis equal; axis tight; shading('interp');
    title('Snapshot A_{||}');
    
    subplot(223);
    f=poloidata(:,:,3);
    pcolor(x,y,f); axis equal; axis tight; shading('interp');
    title('Snapshot fluid n_e');
    
    subplot(224);
    cla;
    semilogy(xtime,ya3,'--',xtime,ya4,'--',xtime,ya5,'--','LineWidth',2);
    title('Amplitude history \phi'); xlabel('t step');
%     legend('m3','m4','m5',4);
legend('m3','m4','m5');
    legend('boxoff');
    hold on;
    ip1=floor(ip/ndiag);
    semilogy(xtime(1:ip1),ya3(1:ip1),'-',xtime(1:ip1),ya4(1:ip1),'-',xtime(1:ip1),ya5(1:ip1),'-','LineWidth',2);
    hold on;
    plot([ip1,ip1],[1e-13,1e0],'m--','LineWidth',2); axis tight;
    
    F(jp)=getframe(gcf,[0,0,800,600]);
    jp=jp+1;
end

%%

% save([path,'snap_F.mat']);

%%
% movie(F(220:320));
writegif([path,'snap_movie_','nt=',num2str(nt),'_nplot=',num2str(nplot),'.gif'],F,0.1);
% writegif([path,'snap_movie_','nt=',num2str(nt),'_nplot=',num2str(nplot),'_mid.gif'],F(200:350),0.1);
close all;
 

