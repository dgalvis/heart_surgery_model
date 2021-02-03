cd ./dists50

sbatch run_hypercube_mean_control.sh 1
sbatch run_hypercube_fft_control.sh 1

sbatch run_hypercube_mean_KA.sh 1
sbatch run_hypercube_fft_KA.sh 1


sbatch run_hypercube_mean_p.sh 1
sbatch run_hypercube_fft_p.sh 1

sbatch run_hypercube_mean_m.sh 1
sbatch run_hypercube_fft_m.sh 1

cd ..
cd ./dists650

sbatch run_hypercube_mean_control.sh 1
sbatch run_hypercube_fft_control.sh 1

sbatch run_hypercube_mean_KA.sh 1
sbatch run_hypercube_fft_KA.sh 1


sbatch run_hypercube_mean_p.sh 1
sbatch run_hypercube_fft_p.sh 1

sbatch run_hypercube_mean_m.sh 1
sbatch run_hypercube_fft_m.sh 1
