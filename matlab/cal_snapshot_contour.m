% bao'code more clear than xie
% run setpath;
% run read_para.m
% figure(18)

[C,h]=contourf(x,y,f,100);hold on;colormap('jet')
set(h,'linecolor','none');
set(gca,'dataaspectratio',[1,1,1]);
colorbar;
set(gca,'fontsize',16,'linewidth',2);
xlabel('$X/R_0$','interpreter','latex','fontsize',20)
ylabel('$Z/R_0$','interpreter','latex','fontsize',20)
hold on
plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
legend('','$q_{min}$','interpreter','latex','fontsize',10)
hold off
