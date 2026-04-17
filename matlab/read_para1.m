% Yuehao Ma, USTC
% GTC Data Processing GUI, v4.6, read gtc.out parameters
% 读取一些gtc.out中一些read_para中无法读取的数据或者其他数据
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
s = fgetl(fid);
jj = 1;

while (jj<1000 && ischar(s))
    % s = fgets(fid);
    jj=jj+1;

    %         if(strfind(s,[blanks(14) num2str(diag_flux)]) )
    %             s(1:14)=[]; q_diag_flux=str2num(s);
    %             break
    %         end

    if(strfind(s,' ped=') )
        s(1:37)=[];psiw=str2num(s);
    end

    %gtc.out file second output the &KEY_PARAMETERS setup.F90
    if(strfind(s,' NSPECIES        =') )
        s(1:18)=[]; nspecies=str2num(s);
    end

    if(strfind(s,' MGRID   =') )
        s(1:10)=[]; mgrid=str2num(s);
    end

    if(strfind(s,' MTHETA0 =') )
        s(1:10)=[]; mtheta0=str2num(s);
    end

    if(strfind(s,' MTHETA1 =') )
        s(1:10)=[]; mtheta1=str2num(s);
    end
    if(strfind(s,' MTDIAG  =') )
        s(1:10)=[]; mtdiag=str2num(s);
    end
    if(strfind(s,' DELR    =') )
        s(1:10)=[]; delr=str2num(s);
    end
    if(strfind(s,' DELT    =') )
        s(1:10)=[]; delt=str2num(s);
    end
    if(strfind(s,' ULENGTH =') )
        s(1:10)=[]; ulength=str2num(s);
    end
    if(strfind(s,' UTIME   =') )
        s(1:10)=[]; utime=str2num(s);
    end
    if(strfind(s,' RHO0    =') )
        s(1:10)=[]; rho0=str2num(s);
    end
    if(strfind(s,' BETAE   =') )
        s(1:10)=[]; betae=str2num(s);
    end
    if(strfind(s,' LSP     =') )
        s(1:10)=[]; lsp=str2num(s);
    end
    if(strfind(s,' LST     =') )
        s(1:10)=[]; lst=str2num(s);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%gtc4.6 GPU code
    if(strfind(s,' EQ_FLUX =') )
        s(1:11)=[]; eq_flux=str2num(s);
    end

    if(strfind(s,' DIAG_FLUX =') )
        s(1:20)=[]; diag_flux=str2num(s);
    end

    if(strfind(s,' ILOAD =') )
        s(1:11)=[];iload=str2num(s);
    end

    if(strfind(s,' FLOAD =') )
        s(1:11)=[];fload=str2num(s);
    end

    if(strfind(s,' FELOAD =') )
        s(1:11)=[];feload=str2num(s);
    end

    if(strfind(s,' ELOAD =') )
        s(1:11)=[]; eload=str2num(s);
    end
    if(strfind(s,' FEM =') )
        s(1:11)=[];fem=str2num(s);
    end
    if(strfind(s,' AION =') )
        s(1:11)=[]; aion=str2num(s);
    end

    if(strfind(s,' UTIME =') )
        s(1:11)=[]; utime=str2num(s);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s = fgetl(fid);
end
fclose(fid);

%% 重复出现数据需要使用函数文件读取
% read the below parameters
%  OLD MAXIMAL PPHI =   2.782903555437972E-002
%  MINIMAL PPHI =  -7.636206325002901E-003
%  NEW MAXIMAL PPHI =   1.009641461468841E-002
%  MAXIMAL MU =   2.726167307558895E-005
%  MINIMAL MU =   2.528714682119302E-012
%  mi=      378720
%  OLD MAXIMAL PPHI =   5.663652399301923E-002
%  MINIMAL PPHI =  -3.710924935326232E-002
%  NEW MAXIMAL PPHI =   9.763637319878456E-003
%  MAXIMAL MU =   5.652134849462542E-004
%  MINIMAL MU =   2.528714682119302E-012
if(exist(file0,'file'))
    Pphi_max_old = read_para_Values(file0,'OLD MAXIMAL PPHI');
    Pphi_min     = read_para_Values(file0,'MINIMAL PPHI');
    Pphi_max     = read_para_Values(file0,'NEW MAXIMAL PPHI');

    mu_max     = read_para_Values(file0,'MAXIMAL MU');
    mu_min     = read_para_Values(file0,'MINIMAL MU');

    mi         = read_para_Values(file0,'mi');
    if(fload~=0)
        mfi        = read_para_Values(file0,'mf');
    end
end
%% 读取同一行出现两个变量的数据
% ped=  2.698775541087373E-002 , psiw=  2.698775541087373E-002
% rg0,rg1=  0.000000000000000E+000  0.848107933358737
% varnames = {'rg0','rg1'};% delimiter = ',';
[ped,psiw]     = read_para_both_line(file1,' ped=');
[rg0,rg1]      = read_para_both_line(file1,' rg0,rg1');
[psi0,spdpsi]  = read_para_both_line(file1,' psi0,spdpsi=');
if(exist(file0,'file'))
    [me,tfracn]    = read_para_both_line(file0,' me=');
end
%% 读取换行数据
%  read the below parameters
%  mmodes=           20           18           19           21           22
%            23           24           25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(exist(file1,'file'))
    fid1 = fopen(file1, 'r');
elseif(exist(file0,'file'))
    fid1 = fopen(file0, 'r');
else
    msgbox('read_para.m, No gtc.out', 'Error');
end
textData = fscanf(fid1, '%c');
fclose(fid1);

pattern1 = 'mmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
matches = regexp(textData, pattern1, 'tokens');
if ~isempty(matches)
    match = matches{1};
    numbers = str2double(match);
    mmodes = reshape(numbers, 1, 8);
else
    disp('canot find the mmodes=');
end
pattern2 = 'nmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
matches = regexp(textData, pattern2, 'tokens');
if ~isempty(matches)
    match = matches{1};
    numbers = str2double(match);
    nmodes = reshape(numbers, 1, 8);
else
    disp('canot find the nmodes=');
end

% pattern1 = 'mmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern1, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     mmodes = reshape(numbers, 1, 10);
% else
%     disp('canot find the mmodes=');
% end
% pattern2 = 'nmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern2, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     nmodes = reshape(numbers, 1, 10);
% else
%     disp('canot find the nmodes=');
% end

% pattern1 = 'mmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern1, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     mmodes = reshape(numbers, 1, 16);
% else
%     disp('canot find the mmodes=');
% end
% pattern2 = 'nmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern2, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     nmodes = reshape(numbers, 1, 16);
% else
%     disp('canot find the nmodes=');
% end

% pattern1 = 'mmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern1, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     mmodes = reshape(numbers, 1, 32);
% else
%     disp('canot find the mmodes=');
% end
% pattern2 = 'nmodes=\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)';
% matches = regexp(textData, pattern2, 'tokens');
% if ~isempty(matches)
%     match = matches{1};
%     numbers = str2double(match);
%     nmodes = reshape(numbers, 1, 32);
% else
%     disp('canot find the nmodes=');
% end

