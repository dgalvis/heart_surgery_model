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
[0.1,      0,       1,    0],\
[10,     100,    1000,    1],\
[1:2,5:6],\
[49.1971, 2],\
3:4,\
16*1024^2,\
{'double', 'mean},\
'p_runs$1/dists50',\
2001330925); exit;" 
