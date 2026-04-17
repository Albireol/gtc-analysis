%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cal_omega, unit=R_0/c_s, run this when use history.m
% plot at panel subplot(223) for mode 1-8

subplot(235);

% auto_simp = 5;   % 找峰值，auto=1是谢华生的代码求解，auto=2使用包健的代码求解
% % auto=3使用MATLAB自带找极值的函数进行寻找 找实部
% % auto=4使用MATLAB自带找极值的函数进行寻找 找虚部
if(auto_simp==1) % this may wrong when signal periodicity is not well
    
    % modify here to set time step range
    %     it0=floor(0.052*nt); it1=floor(0.1492*nt);
    %     it0=floor(cut0*nt); it1=floor(cut1*nt);
    it0 = ind1;it1 = ind2; %来自计算gamma的文件
    tt_cut0 = t(it0:it1);
    yti0=yi(it0:it1)./exp(gamma*(t(it0:it1))');
    ytr0=yr(it0:it1)./exp(gamma*(t(it0:it1))');
    %插值处理
    %     tt_cut = linspace(tt_cut0(1),tt_cut0(end),2*length(tt_cut0));
    %     yti = interp1(tt_cut0,yti0,tt_cut,'spline');
    %     ytr = interp1(tt_cut0,ytr0,tt_cut,'spline');
    %滤波处理
    tt_cut = tt_cut0;
    yti = smoothdata(yti0);
    ytr = smoothdata(ytr0);
    
    % Find the corresponding indexes of the extreme max values
    extrMaxIndex=find(diff(sign(diff(yti)))==-2)+1;
    nT=length(extrMaxIndex)-1;
    if(nT<1)
        omega_simple=0;
    else
        tt_cut1=tt_cut(1+extrMaxIndex(1)); tt_cut2=tt_cut(1+extrMaxIndex(end));
        yt1=yti(extrMaxIndex(1)); yt2=yti(extrMaxIndex(end));
        
        plot(tt_cut,ytr,tt_cut,yti,[tt_cut1,tt_cut2],[yt1,yt2],'r*--','Linewidth',2);
        legend('real','imag','Location', 'Best');
        %         hold on
        %         plot(tt_cut0,ytr0,tt_cut0,yti0,'o');
        xlim([0,max(t)]);
        omega_simple=2*pi*nT/(tt_cut2-tt_cut1);
    end
    title('amplitude normalized by growth rate');
    ylabel(['\omega=',num2str(omega_simple),', nT=',num2str(nT)]);
    grid on
elseif (auto_simp == 2)
        it0 = ind1;it1 = ind2; %来自计算gamma的文件
        tt_cut0 = t(it0:it1);
        yti0=yi(it0:it1)./exp(gamma*(t(it0:it1))');
        ytr0=yr(it0:it1)./exp(gamma*(t(it0:it1))');
        %滤波处理
        tt_cut = tt_cut0;
        yti = smoothdata(yti0);
        ytr = smoothdata(ytr0);
        
        npeak = 0;
        xpeak = [];
        for k=2:length(tt_cut)-1
            if yti(k)>=yti(k-1) && yti(k) > yti(k+1)
                npeak=min(10,npeak+1);
                xpeak(npeak)=k;
            end
        end
        omega_simple = 2*pi*(npeak-1)/(tt_cut(xpeak(npeak))-tt_cut(xpeak(1)));
        plot(tt_cut,ytr,tt_cut,yti,tt_cut(xpeak),yti(xpeak),'r*--','Linewidth',2);
        legend('real','imag','Location', 'Best');
        xlim([0,max(t)]);
        xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
        ylabel('amplitude normalized','Interpreter','latex','fontsize',16);
        title(['npeak=',num2str(npeak), ' $\omega=$',num2str(omega_simple(end))],'Interpreter','latex','fontsize',16);
        grid on; 
elseif(auto_simp==3)
        it0 = ind1;it1 = ind2; %来自计算gamma的文件
        tt_cut0 = t(it0:it1);
        yti0=yi(it0:it1)./exp(gamma*(t(it0:it1))');
        ytr0=yr(it0:it1)./exp(gamma*(t(it0:it1))');
        %插值处理
        %     tt_cut = linspace(tt_cut0(1),tt_cut0(end),2*length(tt_cut0));
        %     yti = interp1(tt_cut0,yti0,tt_cut,'spline');
        %     ytr = interp1(tt_cut0,ytr0,tt_cut,'spline');
        %滤波处理
        tt_cut = tt_cut0;
        yti = smoothdata(yti0);
        ytr = smoothdata(ytr0);
        
 %       TF1 = islocalmax(ytr, 'FlatSelection', 'first');
        TF1 = islocalmax(ytr, 'FlatSelection', 'first');
        xpeak = tt_cut(TF1);
        npeak = length(xpeak);
        if npeak>=2
            omega_simple = 2*pi./(diff(xpeak));
            disp(['real frequency (R0/Cs) = ', num2str(omega_simple)]);
            disp(['real frequency (rad/s) = ', num2str(omega_simple*frequency_gtc_axis)]);            
        else
            omega_simple = 0;
            disp('wrong the frequency use the period method!');
        end
%         omega_simple = 1./(diff(xpeak))
        plot(tt_cut,ytr,tt_cut,yti,tt_cut(TF1),ytr(TF1),'r*--','Linewidth',2);
        legend('real','imag','Location', 'Best');
        xlim([0,max(t)]);
        xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
        ylabel('amplitude normalized','Interpreter','latex','fontsize',16);
        title(['npeak=',num2str(npeak), ' $\omega=$',num2str(omega_simple(end))],'Interpreter','latex','fontsize',16);
        grid on; 
elseif (auto_simp == 4)
        it0 = ind1;it1 = ind2; %来自计算gamma的文件
        tt_cut0 = t(it0:it1);
        yti0=yi(it0:it1)./exp(gamma*(t(it0:it1))');
        ytr0=yr(it0:it1)./exp(gamma*(t(it0:it1))');
        
        tt_cut = tt_cut0;
        yti = smoothdata(yti0);
        ytr = smoothdata(ytr0);
        
        TF1 = islocalmax(yti, 'FlatSelection', 'first');
%         TF1 = islocalmin(yti, 'FlatSelection', 'first');
        xpeak = tt_cut(TF1);
        npeak = length(xpeak);
        
        if npeak>=2
            omega_simple = 2*pi./(diff(xpeak));
            disp(['real frequency (R0/Cs) = ', num2str(omega_simple)]);
           disp(['real frequency (rad/s) = ', num2str(omega_simple*frequency_gtc_axis)]);    

        else
            omega_simple = 0;
            disp('wrong the frequency use the period method!');
        end
%         omega_simple = 1./(diff(xpeak))
        plot(tt_cut,ytr,tt_cut,yti,tt_cut(TF1),yti(TF1),'r*--','Linewidth',2);
        legend('real','imag','Location', 'Best');
        xlim([0,max(t)]);
        xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
        ylabel('amplitude normalized','Interpreter','latex','fontsize',16);
        title(['npeak=',num2str(npeak), ' $\omega=$',num2str(omega_simple(end))],'Interpreter','latex','fontsize',16);
        grid on

elseif (auto_simp == 5)
        it0 = ind1;it1 = ind2; %来自计算gamma的文件
        tt_cut0 = t(it0:it1);
        yti0=yi(it0:it1)./exp(gamma*(t(it0:it1))');
        ytr0=yr(it0:it1)./exp(gamma*(t(it0:it1))');
        
        tt_cut = tt_cut0;
        yti = smoothdata(yti0);
        ytr = smoothdata(ytr0);
        
%         omega_c  = 4/(2*pi)/(1/dt);
%         [omega_cb,omega_ca]    = butter(4,omega_c,'low');             % 四阶的巴特沃斯高通滤波
%         yti=filter(omega_cb,omega_ca,yti);
%         ytr=filter(omega_cb,omega_ca,ytr);


        TFrmax = islocalmax(ytr, 'FlatSelection', 'first');
        TFrmin = islocalmin(ytr, 'FlatSelection', 'first');
        TFimax = islocalmax(yti, 'FlatSelection', 'first');
        TFimin = islocalmin(yti, 'FlatSelection', 'first');  

        xpeakr = [tt_cut(TFrmax) tt_cut(TFrmin)];
        npeakr = length(xpeakr);

        xpeaki = [tt_cut(TFimax) tt_cut(TFimin)];
        npeaki = length(xpeaki);       

        omega_simpler = min( abs(pi./(diff(xpeakr))) )
        omega_simplei = min( abs(pi./(diff(xpeaki))) )        

        plot(tt_cut,ytr,tt_cut,yti,'-','Linewidth',2);
        hold on
        plot(xpeaki,[yti(TFimax);yti(TFimin)],'k*','Linewidth',2);
        hold on
        plot(xpeakr,[ytr(TFrmax);ytr(TFrmin)],'r*','Linewidth',2);       
        legend('real','imag','peaki','peakr','Location', 'Best');
        xlim([0,max(t)]);
        xlabel('$t[R_0/C_s]$','Interpreter','latex','fontsize',16);
        ylabel('amplitude normalized','Interpreter','latex','fontsize',16);
        title(['npeak=',num2str(npeakr)],'Interpreter','latex','fontsize',16);
        grid on
else

    disp('Wrong in omega_simple')

end
    
    
