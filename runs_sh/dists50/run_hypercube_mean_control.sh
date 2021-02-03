#!/bin/bash            
#SBATCH --time=100:00:00     # Walltime            
#SBATCH --mem=64G  # memory/cpu            
#SBATCH --ntasks 32            
#SBATCH --nodes 1-1            
#SBATCH --job-name=runcont          
#SBATCH --output=runcont.out            
#SBATCH --error=runcont.err            
#SBATCH --account=galvisd-virtual-grid-project            
#SBATCH --qos=castles            
            
module purge; module load bluebear # this line is required            
module load MATLAB/2019b            
            
BB_WORKDIR=$(mktemp -d /scratch/${USER}_${SLURM_JOBID}.XXXXXX)            
export TMPDIR=${BB_WORKDIR}  

cd ../..          
                                 
matlab -nodisplay -r "run_hypercube_bear( \
[0.1,      0,    1,    1,    0],\
[10,     100,   60, 1000,    1],\
[1:3, 5:6],\
[2],\
[4],\
4*1024^2,\
{'double', 'mean'},\
'control$1/dists50',\
1982400768); exit;" 

matlab -nodisplay -r "run_copy_hypercube_bear(1:4,\
4,\
{'double', 'mean'},\
'control$1/dists50'\
); exit;" 
