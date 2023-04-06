    #!/usr/bin/env bash

set -x

PARTITION=$1
JOB_NAME=$2
GPUS=$3
PER_GPU_BS=32

GPUS_PER_NODE=$((${GPUS}<8?${GPUS}:8))
CPUS_PER_TASK=${CPUS_PER_TASK:-2}
SRUN_ARGS=${SRUN_ARGS:-""}

PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \
srun -p ${PARTITION} \
    --job-name=${JOB_NAME} \
    --gres=gpu:${GPUS_PER_NODE} \
    --ntasks-per-node=1 \
    --cpus-per-task=${CPUS_PER_TASK} \
    --kill-on-bad-exit=1 \
    ${SRUN_ARGS} \
    torchrun --nproc_per_node=${GPUS_PER_NODE} \
        --master_port 44141 train.py \
        --gpu_num ${GPUS_PER_NODE}\
        --lr 1e-4 \
        --exp_name output/train_${JOB_NAME} \
        --end_epoch 14 \
        --train_batch_size ${PER_GPU_BS} \
        --continue \
        --pretrained_model_path ../output/train_osx_ddp_8_32_20230405_162819/model_dump/snapshot_13.pth.tar
