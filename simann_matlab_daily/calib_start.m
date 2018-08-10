%%%% Calibration of a GLM model: mainscript calib_start.m
% author: Robert Ladwig (IGB Berlin)
% version 1.5, 09.08.2018
% written to work in OCTAVE as well as in MATLAB 
% not polished (yet)
% calibration of hydraulic and physical parameters to fit the vertical temperature profile
% this script includes option for simulated annealing
% other options were already tested (Nelder-Mead, CMA-ES) and worked fine

% structure: calib_start.m calls cmaes.m, which subsequently calls calc_RMSE.m to calculate the fit criteria

%!/projekte/rladwig/octave/bin/octave % OCTAVE-specific, comment out for MATLAB
%pkg load netcdf % OCTAVE-specific, comment out for MATLAB
%pkg load financial % OCTAVE-specific, comment out for MATLAB
%pkg load optim
%% General Start (tabula rasa)
clear
clc
close all

%% Declares global variables for use in the script 'calc_RMSE.m'
global LB
global UB
global T 
global tParam 
global isParam 
global rembParam
global specDeps
global maxDep
global numbDep

%% CHECKLIST:
% (1) change lake specific parameters in template.nml (hydrographic curve,
% depths, outflow height, etc.
% (2) change to your directory for work
cd('C:\Users\ladwig\PhD\04_models\GLM\automatic_calb\lakecalibration-master')
% (3) provide a csv-file titled DATES.csv ranging over simulation period,
% see line 54
dates = csvread('DATES.csv',1);
% (4) provide field data in csv-file measparam.csv, see line 60
measParam = csvread('measparam.csv',1);
% (5) give max. depth of lake and GLM output depths specDeps
% specDeps refers to the specific GLM output depths of your simulation
specDeps = [1 3 5 7 8 9 10 13 14];
% maxDep refers to the maximum lake depth
maxDep = 15.43;
% (6) this script assumes you are simulating a lake with two inflows, if
% you only have one, modify the lines reading template.nml in calc_RMSE.m
% (lines corresponding to strmbd_slope, inflow_factor, strm_hf_angle,
% strmbd_drag) and in the initial guess X0 below
% (7) modify lines 81-90 in calc_RMSE.m to your specific example (names of
% output depth files)
% corresponding to depth = dlmread(output-depth-file, structure)

%% calculate important pre-parameters (needs to be improved in the future; very primitive way...)
% T corresponds to the simulated dates which have to be provided by a csv
% file, e.g. if you simulate from 1.1.1900-30.1.1990 provide a csv-file
% ranging for the specific time interval
T = datestr(dates(2:length(dates),1)-1,'dd-mmm-yy HH-MM-SS');

%% load field measurements
% provide with following structure:
% columns date,depth,temp,do [mg/l],nitrate [mg/l],opo4 [mg/l]
% then per same date all depths (see examples measparam.csv)
% depths should be the same per measured day
% example (day 1, depths 0.5-4)
% 39581,0.5,19.656,675,207.5142857,0
% 39581,1,24.206,831.25,249.8500001,0
% 39581,2,23.114,793.75,240.3928572,0
% 39581,3,25.662,872.4375,269.9142857,0
% 39581,4,13.612,503.1875,167.7785714,0
tParam = datestr(measParam(2:length(measParam),1)-1,'dd-mmm-yy HH-MM-SS');
isParam=zeros(1,length(tParam)-1);
for i=1:length(tParam)-1
    if strcmp(tParam(i+1,:),tParam(i,:))==0
      isParam(i)=i+1;
    end
end
isParam( :, ~any(isParam,1) ) = [];
numbDep = unique(diff(isParam));
%% finds corresponding values between simulated and measured dates
k=1;
rembParam=[];
for k=1:length(isParam)
for i=1:length(T)
    if strcmp(tParam(isParam(k)-1,:),T(i,:))==1
      rembParam=[rembParam,i];
    end
  if k==length(isParam)
    if strcmp(tParam(isParam(k)+1,:),T(i,:))==1
      rembParam=[rembParam,i];
    end
  end
end
end

tic; 
%% Calibration of:
% coef_mix_conv
% coef_wind_stir
% coef_mix_shear 
% coef_mix_turb 
% wind_factor
% rain_factor
% strmbd_slope (here: 2 for two inflwos)
% inflow_factor (here: 2 for two inflows)
% outflow_factor 
% outl_elvs 
% ce
% ch
% cd
% coef_mix_hyp
% sw_factor
% strm_hf_angle (here: 2 for two inflows)
% strmbd_drag (here: 2 for two inflows)
% initial guess: X0

X_initial=[0.2 0.23 0.2 0.51 1 1 1 1 0.5 1 1 29 0.3 0.0013 0.0013 0.0013 0.33 1 65 65 0.016 0.016];

%% lower boundary 
LB = 0.5*X_initial;
LB(9)=0.2;
LB(5:6)=[1 1];
LB(12)=28;
LB(14:16)=[0.001 0.001 0.001];
LB(18)=1;
LB(19:22)=[15 15 0.001 0.001];

%% upper boundary 
UB = 1.5*X_initial;
UB(9)=0.6;
UB(10)=2.0;
UB(5:6)=[1.5 1.5];
UB(12)=30;
UB(14:16)=[0.008 0.008 0.008];
UB(17)=[0.6];
UB(18)=1.5;
UB(19:22)=[140 140 0.05 0.05];

X0=X_initial;

%% Start simulated annealing
theta = X0';
n_iter = 30; % amount of iterations
options = saoptimset('MaxFunEvals',n_iter,'PlotFcns',{@saplotbestx,...
          @saplotbestf,@saplotx,@saplotf}); 
[x,fval,exitFlag,output] = simulannealbnd(@calc_RMSE,theta, ...
    LB,UB,options);

toc

sprintf('Best NRMSE = %.3f after %.0f iterations',fval,n_iter)
sprintf(output.message)