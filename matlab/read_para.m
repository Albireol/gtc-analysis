%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC, myh2020@mail.ustc.edu.cn
% GTC Data Processing GUI
% V4.6 for gtc4.6 version myh 20230323 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Yuehao Ma, USTC
% GTC Data Processing GUI, v4.6, read gtc.out parameters
%% read gtc.out parameters
run setpath;
file1=[path,'gtc.out'];
file0=[path,'gtc0.out'];
if(exist(file1,'file'))
    fid = fopen(file1);
elseif(exist(file0,'file'))
    fid = fopen(file0);
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
% s = fgets(fid);
s = fgetl(fid);
% jend=200;
% for j=1:jend    % read first jend lines
% while ischar(s) % read all lines
jj=1;
while (jj<1000 && ischar(s)) % if 'npe' error, larger '600'
    jj=jj+1;
    %input the gtc.in information of gtc.out file
    s=regexprep(s, 'MSTEP * =', 'MSTEP='); s(s==',')='';
    if(strfind(s,'MSTEP='))
        s(1:7)=[]; mstep=str2num(s);
    end
    s=regexprep(s, 'MSNAP * =', 'MSNAP='); s(s==',')='';
    if(strfind(s,'MSNAP='))
        s(1:7)=[]; msnap=str2num(s);
    end
    s=regexprep(s, 'NDIAG * =', 'NDIAG='); s(s==',')='';
    if(strfind(s,'NDIAG='))
        s(1:7)=[]; ndiag=str2num(s);
    end

    s=regexprep(s, 'NHYBRID * =', 'NHYBRID='); s(s==',')='';
    if(strfind(s,'NHYBRID='))
        s(1:9)=[]; nhybrid=str2num(s);
    end

    s=regexprep(s, 'TSTEP * =', 'TSTEP='); s(s==',')='';
    if(strfind(s,'TSTEP='))
        s(1:7)=[]; dt0=str2num(s);
    end
    s=regexprep(s, 'MPSI * =', 'MPSI='); s(s==',')='';
    if(strfind(s,'MPSI='))
        s(1:6)=[]; mpsi=str2num(s);
    end
    s=regexprep(s, 'MTHETAMAX * =', 'MTHETAMAX='); s(s==',')='';
    if(strfind(s,'MTHETAMAX='))
        s(1:11)=[]; mthetamax=str2num(s);
    end
    %     s=regexprep(s, 'ELOAD * =', 'ELOAD='); s(s==',')='';
    %     if(strfind(s,'ELOAD='))
    %         s(1:7)=[]; eload=str2num(s);
    %     end

    s=regexprep(s, 'MAGNETIC * =', 'MAGNETIC='); s(s==',')='';
    if(strfind(s,'MAGNETIC='))
        s(1:11)=[]; magnetic=str2num(s);
    end

    s=regexprep(s, 'MTOROIDAL * =', 'MTOROIDAL='); s(s==',')='';
    if(strfind(s,'MTOROIDAL='))
        s(1:11)=[]; mtoroidal=str2num(s);
    end
    s=regexprep(s, 'PSI0 * =', 'PSI0='); s(s==',')='';
    if(strfind(s,'PSI0='))
        s(1:6)=[]; psi0=str2num(s);
    end
    s=regexprep(s, 'PSI1 * =', 'PSI1='); s(s==',')='';
    if(strfind(s,'PSI1='))
        s(1:6)=[]; psi1=str2num(s);
    end
    s=regexprep(s, 'NUMBERPE * =', 'NUMBERPE='); s(s==',')='';
    if(strfind(s,'NUMBERPE=')) % number of PE
        s(1:10)=[]; npe=str2num(s);
    end

    s=regexprep(s, 'R0 * =', 'R0='); s(s==',')='';
    if(strfind(s,'R0='))
        s(1:4)=[]; R0=str2num(s);
    end
    s=regexprep(s, 'B0 * =', 'B0='); s(s==',')='';
    if(strfind(s,'B0='))
        s(1:4)=[]; B0=str2num(s);
    end
    s=regexprep(s, 'ETEMP0 * =', 'ETEMP0='); s(s==',')='';
    if(strfind(s,'ETEMP0='))
        s(1:8)=[]; etemp0=str2num(s);
    end
    s=regexprep(s, 'EDEN0 * =', 'EDEN0='); s(s==',')='';
    if(strfind(s,'EDEN0='))
        s(1:7)=[]; eden0=str2num(s);
    end
    s=regexprep(s, 'RHO0 * =', 'RHO0='); s(s==',')='';
    if(strfind(s,'RHO0='))
        s(1:6)=[]; rho0=str2num(s);
    end

    s=regexprep(s, ' BETAE * =', 'BETAE='); s(s==',')='';  % read betae
    if(strfind(s,'BETAE='))
        s(1:7)=[]; betae=str2num(s);
    end

    %     js=strfind(s,'a_minor='); % read a_minor
    %     if(js)
    %         s(s==',')=''; s(1:(js+9))=[]; a_minor=str2num(s);
    %     end
    %         end
    %         if(strfind(s,' at last closed flux surface a_minor') )
    %             s(1:37)=[];s(end-17:end)=[];a_minor=str2num(s);
    %         end
    %myh20230824 读取小半径，r/a
    if(strfind(s,' at last closed flux surface a_minor=') )
        s(1:38)=[];a_minor=str2num(s);
    end
    %myh20230824 读取边界的环向磁通，方便和实验rho=sqrt(psi_T/psi_Tmax)对比
    if(strfind(s,' at last toroidal flux surface=') )
        s(1:32)=[];torpsi_ped=str2num(s);
    end

    %读取m,n的数据，针对gtc4.3版本gtc.out nmodes换行问题
%     if(strfind(s,' N_MODES = '))
%         s(1:13)=[]; nmodes=repmat(str2num(s),1,8);
%     end
%     if(strfind(s,' M_MODES = '))
%         s(1:13)=[]; mmodes=str2num(s);
%     end
%     if(strfind(s,'qiflux='))
%         s(1:8)=[]; qiflux=str2num(s);
%     end
%     if(strfind(s,'rgiflux='))
%         s(1:9)=[]; rgiflux=str2num(s);
%     end
    if(strfind(s,' EQ_FLUX =') )
        s(1:11)=[]; eq_flux=str2num(s);
    end

    if(strfind(s,' DIAG_FLUX       =') )
        s(1:20)=[]; diag_flux=str2num(s);
    end

    if(strfind(s,' ILOAD   =') )
        s(1:11)=[];iload=str2num(s);
    end

    if(strfind(s,' FLOAD   =') )
        s(1:11)=[];fload=str2num(s);
    end

    if(strfind(s,' FELOAD  =') )
        s(1:11)=[];feload=str2num(s);
    end

    if(strfind(s,' ELOAD   =') )
        s(1:11)=[]; eload=str2num(s);
    end
    if(strfind(s,' FEM     =') )
        s(1:11)=[];fem=str2num(s);
    end
    if(strfind(s,' IZONAL =') )
        s(1:10)=[];izonal=str2num(s);
    end
    if(strfind(s,' IZONAL  =') )
        s(1:10)=[];izonal=str2num(s);
    end
    if(strfind(s,' On-axis electron density (cm^-3)=') )
        s(1:35)=[]; ne_axis=str2num(s);
    end

    if(strfind(s,' On-axis electron temperature (eV)=') )
        s(1:36)=[]; te_axis=str2num(s);
    end

    if(strfind(s,' On-axis ion density (norm to eden0)') )
        s(1:37)=[]; ni_axis_norm=str2num(s);
    end

    if(strfind(s,' ion temperature (norm to etemp0)=') )

        s(1:34)=[]; ti_axis_norm=str2num(s);
    end

    if(strfind(s,' fe temperature (norm to etemp0)=') )
        s(1:34)=[]; tfe_axis_norm=str2num(s);
    end

    if(strfind(s,' On-axis felectron density (norm to eden0)=') )
        s(1:44)=[]; nfe_axis_norm=str2num(s);
    end

    if(strfind(s,' On-axis fion density (norm to eden0)=') )
        s(1:38)=[]; nfi_axis_norm=str2num(s);
    end

    if(strfind(s,' fi temperature (norm to etemp0)=') )
        s(1:33)=[]; tfi_axis_norm=str2num(s);
    end


    if(strfind(s,' psi_iflux/ped =') )
        s(1:17)=[]; psi_iflux=str2num(s);
    end

    if(strfind(s,' ped=') )
        s(1:6)=[];s(end-30:end)=[];ped=str2num(s);
    end


    if(strfind(s,' te_iflux/te_axis') )
        s(1:19)=[]; te_iflux_te_axis=str2num(s);
    end

    if(strfind(s,' ti_iflux/te_axis') )
        s(1:19)=[]; ti_iflux_te_axis=str2num(s);
    end

    if(strfind(s,' ne_iflux/ne_axis') )
        s(1:19)=[]; ne_iflux_ne_axis=str2num(s);
    end

    if(strfind(s,' tfi_iflux/te_axis') )
        s(1:20)=[]; tfi_iflux_te_axis=str2num(s);
    end

    if(strfind(s,' nfi_iflux/ne_axis') )
        s(1:20)=[]; nfi_iflux_ne_axis=str2num(s);
    end

    if(strfind(s,' AION    =') )
        s(1:11)=[]; aion=str2num(s);
    end

    if(strfind(s,' UTIME   =') )
        s(1:11)=[]; utime=str2num(s);
    end

    if(strfind(s,' tstep=') )
        s(1:8)=[]; tstep_gtc_unit=str2num(s);
    end

    if(strfind(s,' tstep in seconds:') )
        s(1:18)=[]; tstep_gtc_second=str2num(s);
    end

    s = fgetl(fid);

end
fclose(fid);
%% 再添加一个脚本读取一些gtc.out中平衡网格设置的数据
run read_para1.m
run read_para2.m
run read_para3_parameters.m
disp('gtc.out completed ')
% Z_mp = 1;                                    % A_mass is multiples m_p; Z is ion charge number [e]
% % 诊断磁面处iflux diag_flux处的信息
% if iload==1
% te_axis = etemp0/te_iflux_te_axis;        %iload=1解析位形的例如CBC下这样设置，其余正常
% itemp_iflux = ti_iflux_te_axis*te_axis;   % on-iflux ion temperature, unit=ev
% etemp_iflux = te_iflux_te_axis*te_axis;   % on-iflux electron temperature, unit=ev
% rho_i   = 1.02*10^2*(aion^0.5)/Z_mp*(itemp_iflux^0.5)/R0/B0;   % R0归一化ion thermal radius
% rho_e   = 2.38*(etemp_iflux^0.5)/R0/B0;   % R0归一化 electronon thermal radius
% V_i_iflux  = 9.79*10^5./(aion^0.5)*itemp_iflux^(0.5);%ion thermal velocity,cm/s
% C_si_iflux = 9.79*10^5./(aion^0.5)*etemp_iflux^(0.5);%ion sound velocity,cm/s   R0/Cs中的Cs
% C_sp_iflux = 9.79*10^5.*etemp_iflux^(0.5); %proton sound velocity,cm/s          etemp_iflux=etemp0
% V_e_iflux  = 4.19*10^7*etemp_iflux^(0.5);  %electron thermal velocity,cm/s
% tstep_unity  = 1*R0/C_si_iflux;            %1R0/Cs  R0/Cs中的Cs
% end
% % % read gtc.in parameters
% % fid = fopen([path,'gtc.in']);
% %
% % s1 = fgetl(fid);
% % while ischar(s1)
% % % for j=1:10
%     s1 = fgetl(fid);
%     s=strtok(s1);
%     if(strfind(s,'mstep='))
%         s(1:6)=[]; mstep=str2num(s);
%     end
%     if(strfind(s,'msnap='))
%         s(1:6)=[]; msnap=str2num(s);
%     end
%     if(strfind(s,'ndiag='))
%         s(1:6)=[]; ndiag=str2num(s);
%     end
%     if(strfind(s,'tstep='))
%         s(1:6)=[]; tstep=str2num(s);
%     end
%     if(strfind(s,'mpsi='))
%         s(1:5)=[]; mpsi=str2num(s);
%     end
%     if(strfind(s,'mthetamax='))
%         s(1:10)=[]; mthetamax=str2num(s);
%     end
%     if(strfind(s,'mtoroidal='))
%         s(1:10)=[]; mtoroidal=str2num(s);
%     end
%     if(strfind(s,'psi0='))
%         s(1:5)=[]; psi0=str2num(s);
%     end
%     if(strfind(s,'psi1='))
%         s(1:5)=[]; psi1=str2num(s);
%     end
%     if(strfind(s,'r0='))
%         s(1:3)=[]; r0=str2num(s);
%     end
%
% %     disp(s);
% %     strfind(s1,'mstep=');
% end
%
% fclose(fid);


%%
% s=' nmodes=   4   9  14  18  22  27  31  36';
% if(strfind(s,'nmodes='))
%     s(1:8)=[]; nmodes=str2num(s);
% end
