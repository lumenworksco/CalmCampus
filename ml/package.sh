#!/usr/bin/env bash
# Fuse a trained LoRA adapter into the base model, quantize to 4-bit for iPhone,
# then reload the result from disk and generate once as a sanity check.
#
#   ./package.sh Qwen/Qwen3.5-0.8B runs/lora-0.8b runs/calmcampus-reframe-0.8b-4bit
set -euo pipefail
cd "$(dirname "$0")"
export HF_HOME=$PWD/.cache/hf TMPDIR=$PWD/.cache/tmp/

BASE=$1 ADAPTER=$2 OUT=$3
FUSED=$OUT-bf16

rm -rf "$FUSED" "$OUT"
.venv/bin/python -m mlx_lm fuse --model "$BASE" --adapter-path "$ADAPTER" --save-path "$FUSED"
.venv/bin/python -m mlx_lm convert --hf-path "$FUSED" --mlx-path "$OUT" -q --q-bits 4 --q-group-size 64
rm -rf "$FUSED"
cp "$ADAPTER/adapter_config.json" "$OUT/lora_adapter_config.json"

.venv/bin/python - "$OUT" <<'EOF'
import sys
sys.path.insert(0, "data")
from mlx_lm import load, generate
from spec import SYSTEM_PROMPT
model, tok = load(sys.argv[1])
msgs = [{"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": "I failed my first exam, I'm clearly not smart enough for this."}]
prompt = tok.apply_chat_template(msgs, tokenize=False, add_generation_prompt=True, enable_thinking=False)
print(generate(model, tok, prompt=prompt, max_tokens=200))
EOF
du -sh "$OUT"
