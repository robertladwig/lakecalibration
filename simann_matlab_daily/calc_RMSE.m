function [CF] = calc_RMSE(p)

%%%% Calibration of a GLM model: subscript calc_RMSE.m
% author: Robert Ladwig (IGB Berlin)
% version 1.5, 09.08.2018
% written to work in OCTAVE as well as in MATLAB 
% not polished (yet)
% calibration of hydraulic and physical parameters to fit the vertical temperature profile
% this script includes option for simulated annealing
% other options were already tested (Nelder-Mead, CMA-ES) and worked fine

global LB
global UB
global T 
global tParam 
global isParam 
global rembParam 
global specDeps
global maxDep
global numbDep

%% Open Steering file
fid=fopen('template.nml','rt');
a=fscanf(fid,'%c'); 
fclose(fid);

mix_conv=sprintf('coef_mix_conv = %.2g',p(1));
mix_wind=sprintf('coef_wind_stir = %.2g',p(2));
mix_shear=sprintf('coef_mix_shear = %.2g',p(3));
mix_turb=sprintf('coef_mix_turb = %.2g',p(4));
wind=sprintf('wind_factor = %.2g',p(5));
rain=sprintf('rain_factor = %.2g',p(6));
slope=sprintf('strmbd_slope = %.2g, %.2g',p(7),p(8));
inflow=sprintf('inflow_factor = %.2g, %.2g',p(9),p(10));
outflow=sprintf('outflow_factor = %.2g',p(11));
elevs=sprintf('outl_elvs = %.2g',p(12));
mix_KH=sprintf('coef_mix_KH = %.2g',p(13));
ce=sprintf('ce = %.3g',p(14));
ch=sprintf('ch = %.3g',p(15));
cdp=sprintf('cd = %.3g',p(16));
mix_hypo=sprintf('coef_mix_hyp = %.2g',p(17));
sw=sprintf('sw_factor = %.2g',p(18));%28
angle=sprintf('strm_hf_angle = %.2g, %.2g',p(19),p(20));
drag=sprintf('strmbd_drag = %.2g, %.2g',p(21),p(22));

a=strrep(a,'coef_mix_conv = 0.125',num2str(mix_conv));
a=strrep(a,'coef_wind_stir = 0.23',num2str(mix_wind));
a=strrep(a,'coef_mix_shear = 0.2',num2str(mix_shear));
a=strrep(a,'coef_mix_turb = 0.51',num2str(mix_turb));
a=strrep(a,'wind_factor = 1',num2str(wind));
a=strrep(a,'rain_factor = 1',num2str(rain));
a=strrep(a,'strmbd_slope = 1, 1',num2str(slope));
a=strrep(a,'inflow_factor = 1, 1',num2str(inflow));
a=strrep(a,'outflow_factor = 1',num2str(outflow));
a=strrep(a,'outl_elvs = 30',num2str(elevs));
a=strrep(a,'coef_mix_KH = 0.3',num2str(mix_KH));
a=strrep(a,'ce = 0.0010',num2str(ce));
a=strrep(a,'ch = 0.0060',num2str(ch));
a=strrep(a,'cd = 0.0010',num2str(cdp));
a=strrep(a,'coef_mix_hyp = 0.5',num2str(mix_hypo));
a=strrep(a,'sw_factor = 1',num2str(sw));
a=strrep(a,'strm_hf_angle = 65, 65',num2str(angle));
a=strrep(a,'strmbd_drag = 0.016, 0.016',num2str(drag));

fid=fopen('glm2.nml','wt');
fprintf(fid,'%c',a);
fclose(fid);

% NO WATER QUALITY CALIBRATION
 
%% Start simulation
[status,result]=system('glm.bat'); % needs GLM version

% Reads field data
measParam = csvread('measparam.csv',1);
measParam(1,:) = [];

%% get simulated data, test-case specific, skipping date
% d1=dlmread('DT_1.csv',',',['B2..C8425']);
% d2=dlmread('DT_3.csv',',',['B2..C8425']);
% d3=dlmread('DT_5.csv',',',['B2..C8425']);
% d4=dlmread('DT_7.csv',',',['B2..C8425']);
% d5=dlmread('DT_8.csv',',',['B2..C8425']);
% d6=dlmread('DT_9.csv',',',['B2..C8425']);
% d7=dlmread('DT_10.csv',',',['B2..C8425']);
% d8=dlmread('DT_13.csv',',',['B2..C8425']);
% d9=dlmread('DT_14.csv',',',['B2..C8425']);
d1=csvread('DT_1.csv',1,1);
d2=csvread('DT_3.csv',1,1);
d3=csvread('DT_5.csv',1,1);
d4=csvread('DT_7.csv',1,1);
d5=csvread('DT_8.csv',1,1);
d6=csvread('DT_9.csv',1,1);
d7=csvread('DT_10.csv',1,1);
d8=csvread('DT_13.csv',1,1);
d9=csvread('DT_14.csv',1,1);
d_csv=[d1,d2,d3,d4,d5,d6,d7,d8,d9];

temp_csvParam=zeros(9,length(isParam)+1);
for i=1:length(rembParam)
    for j=1:length(d_csv(1,:))/2
        temp_csvParam(j,i)=d_csv((rembParam(i)+12),(2*j)-1);
        if i==length(rembParam)
            temp_csvParam(j,i+1)=d_csv((rembParam(i)+12),(2*j)-1);
        end
    end
end

dep_csv=specDeps; % lake-specific (field-specific) depths
aParam=diff(isParam);
simParam=zeros(aParam(1),length(isParam)+1);
field_depParam=maxDep-measParam(1:numbDep,2);
% inter-/extrapolation technique: Piecewise Cubic Hermite Interpolating Polynomial (PCHIP)
simParam(:,1)=interp1(dep_csv,temp_csvParam(:,1),field_depParam,'pchip','extrap');
for i=2:length(isParam)
    simParam(:,i)=interp1(dep_csv,temp_csvParam(:,i),field_depParam,'pchip','extrap');
if i==length(isParam)
    simParam(:,i+1)=interp1(dep_csv,temp_csvParam(:,i+1),field_depParam,'pchip','extrap');
end
end

fieldParam=zeros(aParam(1),length(isParam)+1);
fieldParam(:,1)=measParam(1:numbDep,3);
for i=2:length(isParam)
    fieldParam(:,i)=measParam(isParam(i-1):(isParam(i-1)+(numbDep-1)),3);

    if i==length(isParam)
        fieldParam(:,i+1)=measParam(isParam(i):(isParam(i)+(numbDep-1)),3);

    end
end

field_plotParam=[fieldParam(:,1)];
sim_plotParam=[simParam(:,1)];

for i=2:max(size(fieldParam(1,:)))
    field_plotParam=[field_plotParam;fieldParam(:,i)];
    sim_plotParam=[sim_plotParam;simParam(:,i)];
end


check=find(~isnan(field_plotParam)); 
b=sqrt(sum((sim_plotParam(check)-field_plotParam(check)).^2)/length(sim_plotParam(check))); % RMSE
nse=1-(sum((sim_plotParam(check)-field_plotParam(check)).^2)/sum((field_plotParam(check)-mean(field_plotParam(check))).^2)); % NSE

allNSE = [nse];
allRMSE = [b];
% save('NSE.txt', 'allNSE', '-append')
% save('RMSE.txt','allRMSE','-append')

%% calculate NRMSE of water temperature discrepancies between 
%% observed and simulated values
CF = ((b/range(field_plotParam)));


