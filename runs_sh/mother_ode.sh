cd ./dists50

sbatch run_double_mean_control.sh 1
sbatch run_double_fft_control.sh 1

sbatch run_double_mean_KA.sh 1
sbatch run_double_fft_KA.sh 1


sbatch run_double_mean_p.sh 1
sbatch run_double_fft_p.sh 1

sbatch run_double_mean_m.sh 1
sbatch run_double_fft_m.sh 1

cd ..
cd ./dists650

sbatch run_double_mean_control.sh 1
sbatch run_double_fft_control.sh 1

sbatch run_double_mean_KA.sh 1
sbatch run_double_fft_KA.sh 1


sbatch run_double_mean_p.sh 1
sbatch run_double_fft_p.sh 1

sbatch run_double_mean_m.sh 1
sbatch run_double_fft_m.sh 1
