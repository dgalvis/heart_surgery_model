#!/bin/bash            
#SBATCH --time=100:00:00     # Walltime            
#SBATCH --mem=64G  # memory/cpu            
#SBATCH --ntasks 32            
#SBATCH --nodes 1-1            
#SBATCH --job-name=runhyp          
#SBATCH --output=runhyp.out            
#SBATCH --error=runhyp.err            
#SBATCH --account=galvisd-virtual-grid-project            
#SBATCH --qos=castles            
            
module purge; module load bluebear # this line is required            
module load MATLAB/2019b            
            
BB_WORKDIR=$(mktemp -d /scratch/${USER}_${SLURM_JOBID}.XXXXXX)            
export TMPDIR=${BB_WORKDIR}  

cd ../..          
                                 
matlab -nodisplay -r "run_hypercube_bear( \
[0.1,       0,        1],\
[10,     1000,    1000],\
[1,3,5],\
[18.1167, 2, 0.2353],\
[2,4,6],\
16*1024^2,\
{'double', 'mean},\
'KA_runs$1/dists50',\
2001330924); exit;" 

# these median values are the medians of the control group parameters
# The ones having the best mean squared error over all controls
