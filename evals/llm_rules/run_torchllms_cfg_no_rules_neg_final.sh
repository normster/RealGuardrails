#!/bin/bash

set -x

MODEL_PATH=${1}
CONFIG=${2}
BATCH_SIZE=${3:-1}

MODEL_NAME=$(basename $(dirname $MODEL_PATH))

cd "$(dirname "$0")"

#TODO: Fix the output dir
for SCALE in 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2; do
    for SUITE in benign basic redteam; do
        python -m llm_rules.scripts.evaluate_batched \
            --provider torchllms \
            --model $MODEL_PATH \
            --model_name no_rules_neg_${MODEL_NAME}_${SCALE}_eager \
            --model_kwargs template_config=${CONFIG} \
            --model_kwargs batch_size=${BATCH_SIZE} \
            --model_kwargs attention_impl=eager \
            --model_kwargs lp_kwargs="{\"type\": \"cfg\", \"guidance_scale\": ${SCALE}, \"plausibility_threshold\": 0.1, \"prompt_builder\": \"no_rules\"}" \
            --test_suite $SUITE \
            --output_dir logs_use_system_remove_precedence/${SUITE} \
            --system_instructions # Don't use --remove_precedence_reminders because use_no_rule_negative does it instead
    done
done
cd -
