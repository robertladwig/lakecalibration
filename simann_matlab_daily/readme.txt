%%%% Calibration of a GLM model: mainscript calib_start.m
% author: Robert Ladwig (IGB Berlin)
% version 1.5, 10.08.2018
% written to work in MATLAB and with small modifications in OCTAVE (csvread)
% not polished (yet)
% calibration of hydraulic and physical parameters to fit the vertical temperature profile
% this script includes option for simulated annealing

% structure: calib_start.m calls cmaes.m, which subsequently calls calc_RMSE.m to calculate the fit criteria


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
