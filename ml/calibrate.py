"""Crisis detection by probability threshold instead of greedy decoding.

The model's answer always starts with `{"` followed by `safety`, `pattern` or
`unclear`. Greedy decoding picks the most likely of the three, which in our runs
trades crisis recall against false alarms. Instead we read P(safety) at that
position and flag a crisis whenever it exceeds a threshold tau.

tau is chosen on the VALIDATION set (the lowest tau-free choice that catches every
validation crisis, with a safety margin), then reported on the held-out TEST set.

    python calibrate.py --model mlx-community/Qwen3-1.7B-4bit --adapter runs/lora-1.7b-v2/eval-0000450
"""
import argparse
import json
import sys
from pathlib import Path

import mlx.core as mx
from mlx_lm import load

sys.path.insert(0, str(Path(__file__).parent / "data"))
from spec import SYSTEM_PROMPT  # noqa: E402

HERE = Path(__file__).parent


def prompt_ids(tokenizer, text):
    messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": text}]
    return tokenizer.apply_chat_template(messages, add_generation_prompt=True, enable_thinking=False)


def decision_tokens(tokenizer):
    """Token ids for the opening `{"` and the first token of each answer key."""
    opening = tokenizer.encode('{"', add_special_tokens=False)
    keys = {}
    for key in ("safety", "pattern", "unclear"):
        ids = tokenizer.encode('{"' + key, add_special_tokens=False)
        assert ids[: len(opening)] == opening, (key, ids, opening)
        keys[key] = ids[len(opening)]
    assert len(set(keys.values())) == 3, keys
    return opening, keys


def p_safety(model, tokenizer, text, opening, keys):
    ids = prompt_ids(tokenizer, text) + opening
    logits = model(mx.array(ids)[None])[0, -1]
    probs = mx.softmax(logits.astype(mx.float32), axis=-1)
    return float(probs[keys["safety"]]), {k: float(probs[v]) for k, v in keys.items()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--adapter", default=None)
    ap.add_argument("--margin", type=float, default=0.5,
                    help="tau = margin * (lowest P(safety) among validation crises)")
    ap.add_argument("--out", default=None)
    args = ap.parse_args()

    model, tokenizer = load(args.model, adapter_path=args.adapter)
    opening, keys = decision_tokens(tokenizer)

    valid = []
    for line in open(HERE / "data/out/valid.jsonl"):
        r = json.loads(line)
        answer = r["messages"][2]["content"]
        label = "safety" if '"safety"' in answer else "unclear" if '"unclear"' in answer else "reframe"
        valid.append({"text": r["messages"][1]["content"], "expected": label})
    test = [json.loads(l) for l in open(HERE / "data/out/test_items.jsonl")]

    for split in (valid, test):
        for item in split:
            item["p_safety"], item["probs"] = p_safety(model, tokenizer, item["text"], opening, keys)

    lowest_crisis = min(i["p_safety"] for i in valid if i["expected"] == "safety")
    tau = args.margin * lowest_crisis

    def report(name, items):
        crises = [i for i in items if i["expected"] == "safety"]
        others = [i for i in items if i["expected"] != "safety"]
        reframes = [i for i in items if i["expected"] == "reframe"]
        recall = sum(i["p_safety"] >= tau for i in crises) / len(crises)
        false_alarms = sum(i["p_safety"] >= tau for i in reframes) / max(1, len(reframes))
        print(f"{name}: crisis recall {recall:.3f} ({len(crises)} crises) | "
              f"false alarms on reframes {false_alarms:.3f} ({len(reframes)}) | "
              f"lowest crisis p={min(i['p_safety'] for i in crises):.4f} | "
              f"highest non-crisis p={max(i['p_safety'] for i in others):.4f}")
        return {"recall": recall, "false_alarms_on_reframes": false_alarms}

    print(f"tau = {tau:.5f} (margin {args.margin} x lowest validation crisis p {lowest_crisis:.5f})")
    summary = {"tau": tau, "valid": report("valid", valid), "test": report("test ", test)}

    missed = [i["text"] for i in test if i["expected"] == "safety" and i["p_safety"] < tau]
    flagged = [(round(i["p_safety"], 4), i["text"]) for i in test if i["expected"] != "safety" and i["p_safety"] >= tau]
    if missed:
        print("MISSED TEST CRISES:", *missed, sep="\n  ")
    if flagged:
        print("FALSE ALARMS ON TEST:", *flagged, sep="\n  ")

    if args.out:
        with open(args.out, "w") as f:
            json.dump({"summary": summary, "test": test}, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
