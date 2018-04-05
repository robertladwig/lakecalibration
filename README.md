# lakecalibration
Octave scripts to run a calibration for GLM (includes simulated annealing)

author: Robert Ladwig (IGB Berlin)
version 1.4, 05.04.2018
written to work in OCTAVE as well as in MATLAB 
not polished (yet)
calibration of hydraulic and physical parameters to fit the vertical temperature profile
this script includes option for simulated annealing
other options were already tested (Nelder-Mead, CMA-ES) and worked fine

structure: calib_start.m calls calc_RMSE.m to calculate the fit criteria
