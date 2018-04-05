Calibration of a GLM model

author: Robert Ladwig (IGB Berlin)
version 1.3b
written to work in OCTAVE as well as in MATLAB 
not polished (yet)
calibration of hydraulic and physical parameters to fit the vertical temperature profile
this script only includes option for CMA-ES (by Nikolaus Hansen)
other options were already tested (Nelder-Mead, simulated annealling) and worked fine

structure: calib_start.m calls cmaes.m, which subsequently calls calc_RMSE.m to calculate the fit criteria
