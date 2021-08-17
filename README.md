Heart Surgery Modelling
=======================
This code implements a latin hypercube of parameters on a model of acth onto cortisol  
acth is treated as an input to the model dc/dt = F(a(t-10), pars) with a delay of 10 minutes  

There are two versions of the model 'double' and 'single'  
- 'single' has 4 parameters and one compartment
- 'double' has 6 parameters and two compartments (to separate timescales)  

### Author: Daniel Galvis
### Manuscript: The dynamic interaction of systemic inflammation and the hypothalamic-pituitary-adrenal (HPA) axis during and after major surgery (submitted).
### License: BSD 2-Clause License (open source)

Model
-----
Single compartment (pre is acth(t-10)) - called 'single

    dy = - y / par(1) + par(2) * hill_fun(pre(t_idx), par(4), par(3));

Two compartment model - called 'double'

    dy1 = - y1 / par(1) + par(2) * hill_fun(pre(t_idx), par(4), par(3));
    dy2 = - y2 / par(5) + par(6) * hill_fun(pre(t_idx), par(4), par(3));    

par = [lambda_f, p_f, K_A, m, lambda_s, p_s]

Cost Function
-------------
The cost function is the absolute difference between cortisol data and cortisol model output

    if strcmp(type{2}, 'mean')
        error = error + sum(abs(post_model - post_data)) / max(post_data);
    elseif strcmp(type{2}, 'fft')
        error = error + sum(abs(fft(post_model - post_data))) / max(abs(fft(post_data)));
    end

Note:   
   - fft evaluates in frequency space, mean in time space 
   - dists = [length, slide] (we use length = slide) this allows for evaluating the cost function on subsegments of the cortisol data 
   - we use dists = [650, 650] (the whole segment, no slide), dists = [50,50] (13 segments of 50 minutes)
   - The reason for dists is based on the idea that resetting the initial condition to the true cortisol data and running for shorter time segments may give better solutions (qualitatively it does not work!)  

Manuscript:  
   - we use mean because it is more straightforward.  
   - we use dists = [650, 650] because it gives qualitatively good solutions  (unlike [50,50])  

Directories
-----------
### . :
The code to run is here (each has a detailed docstring)
   - run_data.m, run_data_cyts.m - prepare the data for modelling
   - run_hypercube_bear.m - find the latin hypercube for the single or double compartment model
   - run_ode_bear.m - run the model on all parameters of the hypercube for all patients in data_all.mat (controls too)
   - run_copy_hypercube_bear.m - Parameter 4 of this model is an integer, this adds that to the hypercube
   - run_analysis.m - takes in the results of hypercube evaluation and analyses the best solutions
   - run_pca.m - compares features (Cortisol, ACTH, Cytokines) using pca and correlation (for all patient's data)

### data :  
Contains the acth, cortisol data (it also has cytokine data which is not yet in the model)  
   - CORT_ACTH_control_a.xlsx - first control dataset (one patient - Ferdinand)
   - CORT_ACTH_control_b.xlsx - second control dataset (two patients - Gibbison)
   - CORT_ACTH_control_ab.xlsx - concatenation of above
   - CORT_ACTH_surgical.xlsx - surgical dataset (10 patients - Gibbison)
   - Data increments 10 minutes for about 11 - 12 hours  
   - cortisol units in nmol/L

The data for modelling is in .mat files  
   - data_surgical.mat - surgical data ready for modelling
   - data_control.mat  - control data ready for modelling
   - data_all.mat - concatenate the above 
   - These data have been interpolated (spline) to 1 minute increments
   - acth is time shifted so acth(t-10) hits cortisol
   - pats = 1:10 (surgical), 1:3 (controls), 1:13 (all) where 11:13 is controls
   - times (time points), pre (cortisol), post (acth)   
   - cortisol units converted to micro-gram/dL

### data/cytokines :
The surgical data with cytokines included  
   - 2075.csv through 2120.csv (original data files) - cortisol in nmol/L
   - acth.csv, cortisol.csv, IL6.csv, TNFA.csv - datasets ready for modelling (cortisol in micro-gram/dL)
   - cytokines_data.mat - datasets ready for modelling (cortisol in micro-gram/dL)

Note: In the datasets ready for modelling, Cortisol is converted from nanomolar to microgam per deciliter (0.0363 factor)

### functions :
   - The code that finds the latin hypercube and performs the modelling and evaluates the cost function
   - It also prepares the dataset for modelling
   - Each file has a docstring


### functions_cyts : 
   - The code for preparing the cytokines surgical data for modelling
   - This has not been modelled yet

### functions_analysis :
   - functions used to analyse the results of running the latin hypercube of parameters on all the patients

### runs_sh :
   - the shell scripts to submit the jobs to the HPC

### results :
The full results are not included in the repository as the filesizes are too large. They are available upon request.  
Please note that the units of cortisol in the repository differ from that in the paper so conversions were made  

0.0363 micro-gram/dL = 1 nmol/L. This affects the units of the parameters (see model above) and the resulting trajectories. In the paper, we use nmol/L, but for all files below the units are in micro-gram/dL.  

### results/control/dists650  
   - par_choices_acth_cort_double_mean.mat - latin hypercube parameter set
   - results_double_mean.mat - latin hypercube parameter set and cost function evaluations for all patients and controls  
   - dists = [650, 650] (could be 50 also)
   - The analysis code prints out the following csv files for making violin plots and plotting trajectories:
   - THIS IS THE CASE WHERE ALL 6 PARAMETERS VARY (m = 1,2,3,4)  
   
CSV files
   - control_group_double_mean.csv: the top parameter sets (according to MSE of CFE across control group)
   - surgical_group_double_mean.csv: the top parameter sets (according to MSE of CFE across surgical group)
   - control_group_m_double_mean.csv: we choose m by selecting the m value that has the most top parameter sets  (in controls!!)
   - surgical_group_m_double_mean.csv: given that m above, this is the top surgical parameter sets  
   - control_group_m_traj{i}_double_mean.csv: trajectories for parameters (fixed m) i = 1:3 (1,21,22)
   - surgical_group_m_traj{i}_double_mean.csv: trajectories for parameters (fixed m) i = 1:10 (in order of 2075 - 2120)  

The baseline of controls is chosen as the median of each parameter in the top parameter sets. This is because we can't know that the parameter set that optimises the control group is necessarily the correct one  
   - same as traj{i} but with 'medbest' shows the surgical and control trajectories using the median baseline and the best fit baseline OF THE CONTROLS
   - You can note that the surgical fits are bad because the parameters were not fit to them  


### results/control/m_runs/dists650
   - This is a rerun with only m fixed (because this latin hypercube will have 4x the points)

### results/control/KA_runs/dists650
   - This is a rerun with  m, p_f, p_s fixed (at median baseline)
   - This shows what happens if we assume only KA (and lambda_f, lambda_s) is changed after surgery  

### results/control/p_runs/dists650
   - This is a rerun with  m, KA fixed (at median baseline)
   - This shows what happens if we assume only p_f and p_s (and lambda_f, lambda_s)  is changed after surgery  

Analysis
--------
The csv files above show the group level analysis extraction of the latin hypercube   

Individual analysis also exists (replace group with individual in csv) - This finds the optimal parameter sets for individual patients or controls  
   - individuals 1-10 for surgical, 1-3 for controls  

Subgroup analysis also exists for surgical (replace group with subgroup in csv) - This finds the optimal parameter sets for subgroups which were defined quantitatively in another package   
   - subgroup1 = [1, 5, 6, 7]
   - subgroup2 = [2, 3, 8]
   - subgroup3 = [4, 9, 10]  
