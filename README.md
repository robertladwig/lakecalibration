% lakecalibration
author: Robert Ladwig (IGB Berlin);
version: Matlab (1.5, 10.08.2018), Octave (1.4, 05.04.2018)
These scripts are designed to automatically calibrate a GLM model with field data by reducing the NRMSE (normalized by range of field data)

IMPORTANT: An updated version of the script for Matlab is in /simann_matlab_daily/, which uses daily boundary conditions to simulate subdaily temperature profiles, see details below.

%%%% Octave scripts to run a calibration for GLM (includes simulated annealing)
author: Robert Ladwig (IGB Berlin);
version 1.4, 05.04.2018;
written to work in OCTAVE as well as in MATLAB;
not polished (yet);
calibration of hydraulic and physical parameters to fit the vertical temperature profile;
this script includes option for simulated annealing;
other options were already tested (Nelder-Mead, CMA-ES) and worked fine;

structure: calib_start.m calls calc_RMSE.m to calculate the fit criteria

%%%% Matlab calibration of a GLM model: mainscript calib_start.m
% author: Robert Ladwig (IGB Berlin)
% contact: ladwig@igb-berlin.de
% version 1.5, 10.08.2018
% written to work in MATLAB and with small modifications in OCTAVE (csvread)
% not polished (yet)
% calibration of hydraulic and physical parameters to fit the vertical temperature profile
% this script includes option for simulated annealing

%% past versions
% 1.5   focus on Matlab, uses daily boundary condition to simulate hourly vertical water temperature profiles
% 1.4   focus on Octave implementation, did use daily boundary conditions to simulate hourly vertical water temperature profiles

% structure: calib_start.m calls cmaes.m, which subsequently calls calc_RMSE.m to calculate the fit criteria
