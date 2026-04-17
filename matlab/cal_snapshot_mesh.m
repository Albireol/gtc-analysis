% bao'code more clear than xie
% run setpath;
% run read_para.m
mesh(x,y,f);
colormap('jet');colorbar
set(h,'linecolor','none');
xlabel('$X/R_0$','interpreter','latex','fontsize',20)
ylabel('$Z/R_0$','interpreter','latex','fontsize',20)
% hold on
% plot(x(:,diag_flux),y(:,diag_flux),'--k','linewidth',1);
% hold on
% plot(x(:,q_min_flux),y(:,q_min_flux),'-.k','linewidth',1);

% title('$\delta \phi$','interpreter','latex','fontsize',16)



