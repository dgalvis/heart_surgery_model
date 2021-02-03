#!/bin/bash            
#SBATCH --time=200:00:00     # Walltime            
#SBATCH --mem=64G  # memory/cpu            
#SBATCH --ntasks 32
#SBATCH --nodes 1-1            
#SBATCH --job-name=rundm          
#SBATCH --output=rundm.out            
#SBATCH --error=rundm.err            
#SBATCH --account=galvisd-virtual-grid-project            
#SBATCH --qos=castles            
            
module purge; module load bluebear # this line is required            
module load MATLAB/2019b            
            
BB_WORKDIR=$(mktemp -d /scratch/${USER}_${SLURM_JOBID}.XXXXXX)            
export TMPDIR=${BB_WORKDIR}           

cd ../..

matlab -nodisplay -r "run_ode_bear([50, 50], {'double', 'fft'}, 'KA_runs$1/dists50', 'KA_runs$1/dists50'); exit;" 
