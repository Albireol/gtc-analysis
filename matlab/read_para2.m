%读取所有gtc.out中平衡网格设置的数据
%包括诊断位置或者平衡位置处的剖面信息
%profile_gtcout1作为整个的文件保存住
% i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q
%profile_gtcout2作为整个的文件保存住
% i  r   psipol  psitor  meshte  meshti  meshne  meshni
% !Write out key profiles before modifying the simulation profile according to
% !iload
% ! constant to convert Te and Ti from GTC units back to normalized values
% ! iload==1 : artificially use a flat profile, use the density and temperature
% ! values at eq_flux, but keep the effective gradient by recalculating kappas
%% read the gtc.out file
% read the q profile 
run setpath;
file1=[path,'gtc.out'];
file0=[path,'gtc0.out'];
if(exist(file1,'file'))
    fid1 = fopen(file1);
elseif(exist(file0,'file'))
    fid1 = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
s1 = fgetl(fid1);
jj = 1;
while (jj<800 && ischar(s1))
    % s = fgets(fid);
    jj=jj+1;
    if(strfind(s1,[' i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q ']) )
        break
    end
    s1 = fgetl(fid1);
end
FormatString1=repmat('%f',1,6);
profile_gtcout1 = cell2mat(textscan(fid1,FormatString1,mpsi));
fclose(fid1);
%% 读取关键的温度密度等剖面信息
%读取所有gtc.out中平衡网格设置的数据
%包括诊断位置或者平衡位置处的剖面信息
%profile_gtcout作为整个的文件保存住
%  No Radial Boundary Decay.
%  Key profiles on radial mesh:
%  i  r   psipol  psitor  meshte  meshti meshtf  meshne  meshni  meshnf
if(exist(file1,'file'))
    fid2 = fopen(file1);
elseif(exist(file0,'file'))
    fid2 = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
s2 = fgetl(fid2);
jj = 1;
while (jj<10000 && ischar(s2))
    % s = fgets(fid);
    jj=jj+1;

    if(strfind(s2,[' i  r  psipol  psitor  meshte  meshti  meshtf  meshne  meshni  meshnf']) )
        break
    end
    %         if(strfind(s,[' i  r   psipol  psitor  meshte  meshti  meshne  meshni']) )
    %         break
    %     end
    %     if(strfind(s,[' i  r   psipol  psitor  meshte  meshti  meshne  meshni']) )
    %         break
    %     end
    %       if(strfind(s,[' i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q ']) )
    %             break
    %        end

    s2 = fgetl(fid2);
end
FormatString2=repmat('%f',1,10);
profile_gtcout2 = cell2mat(textscan(fid2,FormatString2,mpsi+1));
fclose(fid2);

%%gtc4.6 处理meshnf 直接对原始数据进行处理
% 4.6 eqdata.F90 1856-1865
% fload==0 普通的线性插值会使得nf Tf的剖面出现阶梯型的数据格式
% fload>0  会对快离子剖面进行处理，construct spline
if (fload==0)
    profile_gtcout2(:,10) = profile_gtcout2(:,10)./eden0;
end
%% 读取修改后的关键的温度密度梯度
%读取所有gtc.out中平衡网格设置的数据
%包括诊断位置或者平衡位置处的剖面信息
%profile_gtcout作为整个的文件保存住
%  have the Radial Boundary Decay.
%  Key Gradient profiles after modify radial mesh:
%  i  r  psipol  psitor  kapate  kapati  kapatf  kapane  kapani  kapanf
if(exist(file1,'file'))
    fid3 = fopen(file1);
elseif(exist(file0,'file'))
    fid3 = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
s3 = fgetl(fid3);
jj = 1;
while (jj<10000 && ischar(s3))
    % s = fgets(fid);
    jj=jj+1;

    if(strfind(s3,[' i  r  psipol  psitor  kapate  kapati  kapatf  kapane  kapani  kapanf']) )
        break
    end

    s3 = fgetl(fid3);
end
FormatString3=repmat('%f',1,10);
profile_gtcout_grad = cell2mat(textscan(fid3,FormatString3,mpsi+1));
fclose(fid3);
%% 读取各个径向位置的mtheta极向格点数目
%   i    mtheta;
if(exist(file1,'file'))
    fid4 = fopen(file1);
elseif(exist(file0,'file'))
    fid4 = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
s4   = fgetl(fid4);
jj   = 1;
while (jj<10000 && ischar(s4))
    % s = fgets(fid);
    jj=jj+1;

    if(strfind(s4,[' i  mtheta']) )
        break
    end

    s4 = fgetl(fid4);
end
FormatString4=repmat('%f',1,2);
mtheta_mpsi = cell2mat(textscan(fid4,FormatString4,mpsi+1));
fclose(fid4);
%%读取网格数据 mtheta igrid
igrid(1,1)= 1;
for i=2:mpsi+1
    igrid(i,1)=igrid(i-1,1)+mtheta_mpsi(i-1,2)+1;
end

if(fem>0)
    igrid_fem(1,1)=0;
    for i=2:mpsi+1
        igrid_fem(i,1)=igrid_fem(i-1,1)+mtheta_mpsi(i-1,2); %does not include poloidal BC
    end
end
%% 读取几何张量雅可比等 gpsi200 b2m00
%读取所有gtc.out中平衡网格设置的数据
%Key Geometric Tensors:
if(exist(file1,'file'))
    fid5 = fopen(file1);
elseif(exist(file0,'file'))
    fid5 = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
s5 = fgetl(fid5);
jj = 1;
while (jj<10000 && ischar(s5))
    % s = fgets(fid);
    jj=jj+1;

    if(strfind(s5,[' i  gpsi200  b2m00']) )
        break
    end

    s5 = fgetl(fid5);
end
FormatString5         = repmat('%f',1,3);
profile_gtcout_tensor = cell2mat(textscan(fid5,FormatString5,mpsi+1));
fclose(fid5);

%% read the equilibrium.out
%obatin the equilibrium eg.. lsp profile
file3=[path,'equilibrium.out'];
if(exist(file3,'file'))
    tmp = load(file3);
else
    error('Could not find the equilibrium.out file ');
end

n1D         = (1+tmp(1))*tmp(2);     %tmp(1) is the nrplot;tmp(2) is the lsp from the spdata
n2D         = (tmp(n1D+3)+2)*tmp(n1D+4)*tmp(n1D+5);
tmppr       = reshape(tmp(3:n1D+2), [tmp(2) tmp(1)+1]);
tmpsp       = reshape(tmp(n1D+6:n1D+5+n2D), [tmp(n1D+4) tmp(n1D+5) tmp(n1D+3)+2]);
torpsi_psiw = tmppr(tmp(2),25);
%% profile_gtcout3 is the normalized radial mesh
%  i  r   psipol  psitor  meshte  meshti meshtf  meshne  meshni  meshnf
%  in gtc, i is the mpsi index range 0-100, so in matlab matrix will 1-101
%  r is r/R0 ---->r/a_minor---->r/a
%  psiplol   ---->psiplol/ped--->psip_hat
%  psitor    ---->psitor/torpsi_ped--->psit_hat then we can obtain rho_t = sqrt(psit_hat)
%myh20230824 we directly output the torpsi_ped or torpsi_psiw, now we obtain sqrt(psit_hat)
profile_gtcout3        = profile_gtcout2;
profile_gtcout3(:,2:3) = profile_gtcout2(:,2:3)./[a_minor,ped];
profile_gtcout3(:,4)   = sqrt(profile_gtcout2(:,4)./torpsi_psiw);
profile_gtcout_grad(:,2:3) = profile_gtcout_grad(:,2:3)./[a_minor,ped];
profile_gtcout_grad(:,4)   = sqrt(profile_gtcout_grad(:,4)./torpsi_psiw);

%% 诊断位置或者平衡位置处的q剖面信息
%q_diag_flux q_eq_flux
% 包括i,  rg/a,  psi/ped,   q,   rg_sp/rg - 1,  dtorpsi/q
q_diag_flux        = profile_gtcout1(diag_flux,:);
q_eq_flux          = profile_gtcout1(eq_flux,:);
