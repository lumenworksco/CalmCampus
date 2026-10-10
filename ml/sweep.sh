#!/usr/bin/env bash
# Train (optional) then score every saved checkpoint on the test set.
# Checkpoints are chosen by behaviour (safety recall first), not by validation loss:
# in run 1 the lowest-val-loss checkpoint had learned no crisis handling at all.
#   ./sweep.sh configs/lora-1.7b-v2.yaml runs/lora-1.7b-v2 [--train]
set -uo pipefail
cd "$(dirname "$0")"
export HF_HOME=$PWD/.cache/hf TMPDIR=$PWD/.cache/tmp/
CONFIG=$1 RUN=$2
MIN_STEP=${MIN_STEP:-0}   # skip early checkpoints, e.g. MIN_STEP=200
BASE=$(grep '^model:' "$CONFIG" | awk '{print $2}')
if [[ "${3:-}" == "--train" ]]; then
  echo "== train"; .venv/bin/python -m mlx_lm lora -c "$CONFIG" || { echo "TRAIN FAILED"; exit 1; }
fi
mkdir -p results
for ckpt in "$RUN"/0*_adapters.safetensors; do
  step=$(basename "$ckpt" _adapters.safetensors)
  (( 10#$step < MIN_STEP )) && continue
  d=$RUN/eval-$step; mkdir -p "$d"; cp "$RUN/adapter_config.json" "$d/"; cp "$ckpt" "$d/adapters.safetensors"
  echo "== checkpoint $step"
  .venv/bin/python evaluate.py --model "$BASE" --adapter "$d" --out "results/$(basename "$RUN")-$step.jsonl" > /dev/null 2>&1 || echo "EVAL FAILED $step"
  python3 -c "import json,sys; s=json.loads(open(sys.argv[1]).readline())['summary']; rows=[json.loads(l) for l in open(sys.argv[1])][1:]; bad=sum('!\\n!\\n!' in r['output'] for r in rows); print('RESULT', sys.argv[2], {k: s[k] for k in ['safety_recall','false_safety_on_reframes','unclear_accuracy','valid_json','language_match','reframe_routed']}, 'GPU-FAULT(%d garbage outputs)' % bad if bad else '')" "results/$(basename "$RUN")-$step.jsonl" "$step"
done
echo "== SWEEP DONE"
