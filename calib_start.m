%%%% Calibration of a GLM model: mainscript calib_start.m
% author: Robert Ladwig (IGB Berlin)
% version 1.4, 05.04.2018
% written to work in OCTAVE as well as in MATLAB 
% not polished (yet)
% calibration of hydraulic and physical parameters to fit the vertical temperature profile
% this script includes option for simulated annealing
% other options were already tested (Nelder-Mead, CMA-ES) and worked fine

% structure: calib_start.m calls cmaes.m, which subsequently calls calc_RMSE.m to calculate the fit criteria

%!/projekte/rladwig/octave/bin/octave % OCTAVE-specific, comment out for MATLAB
pkg load netcdf % OCTAVE-specific, comment out for MATLAB
pkg load financial % OCTAVE-specific, comment out for MATLAB
pkg load optim
%% General Start (tabula rasa)
clear
clc

% Declares global variables for use in the script 'calc_RMSE.m'
global LB
global UB
global T 
global tParam 
global isParam 
global rembParam 


% calculate important pre-parameters (needs to be improved in the future; very primitive way...)
dates = csvread('DATES.csv');
T = datestr(dates(2:length(dates),1)-1,'dd-mmm-yy HH-MM-SS');
% load field measurements
measParam = csvread('measparam.csv');
tParam = datestr(measParam(2:length(measParam),1)-1,'dd-mmm-yy HH-MM-SS');
isParam=zeros(1,length(tParam)-1);
for i=1:length(tParam)-1
    if strcmp(tParam(i+1,:),tParam(i,:))==0
      isParam(i)=i+1;
    end
end
isParam( :, ~any(isParam,1) ) = [];
% find similar values
k=1;
rembParam=[];
for k=1:length(isParam)
for i=1:length(T)
    if strcmp(tParam(isParam(k)-1,:),T(i,:))==1
      rembParam=[rembParam,i];
    endif
  if k==length(isParam)
    if strcmp(tParam(isParam(k)+1,:),T(i,:))==1
      rembParam=[rembParam,i];
    endif
  endif
end
end

tic; 
% initial guess 
X_initial=[0.2 0.23 0.2 0.51 1 1 1 1 0.5 1 1 29 0.3 0.0013 0.0013 0.0013 0.33 1 65 65 0.016 0.016];

% lower boundary 
LB = 0.5*X_initial;
LB(9)=0.2;
LB(5:6)=[1 1];
LB(12)=28;
LB(14:16)=[0.001 0.001 0.001];
LB(18)=1;
LB(19:22)=[15 15 0.001 0.001];

% upper boundary 
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

% parameters for simulated annealing
nt = 20;
ns = 5;
rt = 0.8; % 0.5 careful - this is too low for many problems
maxevals = 50;
neps = 5;
functol = 1e-10;
paramtol = 1e-3;
verbosity = 1; % only final results. Inc
minarg = 1;
control = {LB', UB', nt, ns, rt, maxevals, neps, functol, paramtol, ...
             verbosity, 1};
theta = X0';
curvature = ones(length(X0),1)*0.01;
[theta_best, obj_value, convergence] = samin ("calc_RMSE",
                                           {theta, curvature},
                                           control);
                                           
toc
