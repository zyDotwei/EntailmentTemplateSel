#!/usr/bin/env bash
TASK_NAME="tnews"
TASK_IDX=$1
# MODEL_NAME="../pretrained_lm/chinese_roberta_wwm_ext_pytorch"
MODEL_NAME="../pretrained_lm/macbert_large/"
#MODEL_NAME="./ocnli_output/bert/"
# MODEL_NAME="../pretrained_lm/macbert_large/"
CURRENT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export CUDA_VISIBLE_DEVICES="3"

export FewCLUE_DATA_DIR=../datasets/

# make output dir
if [ ! -d $CURRENT_DIR/${TASK_NAME}_output ]; then
  mkdir -p $CURRENT_DIR/${TASK_NAME}_output
  echo "makedir $CURRENT_DIR/${TASK_NAME}_output"
fi

if [ "$task_idx"=="all" ]; then
    bs=20
    epoch=3
else
    bs=4
    epoch=5
fi

# run task
cd $CURRENT_DIR
echo "Start running..."
if [ $# == 1 ]; then
    nohup python run_classifier.py \
      --model_type=bert \
      --model_name_or_path=$MODEL_NAME \
      --task_name=$TASK_NAME \
      --task_idx=$TASK_IDX \
      --do_train \
      --do_lower_case \
      --data_dir=$FewCLUE_DATA_DIR/${TASK_NAME}/ \
      --max_seq_length=128 \
      --per_gpu_train_batch_size=$bs \
      --per_gpu_eval_batch_size=$bs \
      --learning_rate=2e-5 \
      --num_train_epochs=$epoch \
      --logging_steps=3335 \
      --save_steps=3335 \
      --output_dir=$CURRENT_DIR/${TASK_NAME}_output/ \
      --overwrite_output_dir \
      --seed=42 \
      --cmnli_path cmnli_output_bert/bert/ \
      --bert_multi > $CURRENT_DIR/${TASK_NAME}_output/${TASK_NAME}_${TASK_IDX}.log 2>&1
elif [ $2 == "predict" ]; then
    echo "Start predict..."
    python run_classifier.py \
      --model_type=bert \
      --model_name_or_path=$MODEL_NAME \
      --task_name=$TASK_NAME \
      --task_idx=$TASK_IDX \
      --do_predict \
      --do_lower_case \
      --data_dir=$FewCLUE_DATA_DIR/${TASK_NAME}/ \
      --max_seq_length=128 \
      --per_gpu_train_batch_size=20 \
      --per_gpu_eval_batch_size=20 \
      --learning_rate=2e-5 \
      --predict_checkpoints=0 \
      --num_train_epochs=4 \
      --logging_steps=3335 \
      --save_steps=3335 \
      --output_dir=$CURRENT_DIR/${TASK_NAME}_output/ \
      --overwrite_output_dir \
      --seed=42 \
      --bert_multi 
elif [ $2 == "template" ]; then
    echo "Start score template..."
    python template_check.py \
      --model_type=bert \
      --model_name_or_path=$MODEL_NAME \
      --task_name=$TASK_NAME \
      --task_idx=$TASK_IDX \
      --do_lower_case \
      --data_dir=$FewCLUE_DATA_DIR/${TASK_NAME}/ \
      --max_seq_length=64 \
      --per_gpu_train_batch_size=16 \
      --per_gpu_eval_batch_size=16 \
      --learning_rate=2e-5 \
      --predict_checkpoints=0 \
      --num_train_epochs=3.0 \
      --logging_steps=3335 \
      --save_steps=3335 \
      --output_dir=$CURRENT_DIR/${TASK_NAME}_output/ \
      --overwrite_output_dir \
      --seed=42 \
      --bert_multi 
fi