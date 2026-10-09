"""Score a model on the held-out test set.

    python evaluate.py --model Qwen/Qwen3.5-0.8B                      # base, zero-shot
    python evaluate.py --model Qwen/Qwen3.5-0.8B --adapter runs/x     # base + LoRA adapter
    python evaluate.py --model runs/fused-4bit                        # fused model

Uses exactly the prompt the app will send: SYSTEM_PROMPT + Qwen chat template
with thinking disabled, greedy decoding.
"""
import argparse
import json
import re
import sys
import time
from pathlib import Path

from mlx_lm import generate, load

sys.path.insert(0, str(Path(__file__).parent / "data"))
from spec import MAX_REFRAME_WORDS, PATTERNS, SYSTEM_PROMPT  # noqa: E402

DIAGNOSTIC = re.compile(r"depress|disorder|diagnos|mental illness|stoornis|psychiatr", re.I)
NL_WORDS = {"ik", "de", "het", "een", "niet", "dat", "mijn", "en", "is", "kan", "ook", "nog", "dit", "zijn", "maar"}
EN_WORDS = {"i", "the", "my", "a", "and", "to", "is", "not", "can", "it", "of", "that", "this", "be", "me"}


def build_prompt(tokenizer, text):
    messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": text}]
    return tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True,
                                         enable_thinking=False)


def classify(output):
    """Return (kind, parsed) where kind is reframe/safety/unclear/invalid."""
    raw = output.strip()
    if raw.startswith("```"):
        raw = raw.strip("`").removeprefix("json").strip()
    try:
        obj = json.loads(raw)
    except json.JSONDecodeError:
        return "invalid", None
    if not isinstance(obj, dict):
        return "invalid", None
    if obj.get("safety") is True:
        return "safety", obj
    if obj.get("unclear") is True:
        return "unclear", obj
    if "reframes" in obj:
        return "reframe", obj
    return "invalid", obj


def language(texts):
    words = re.findall(r"[a-zà-ÿ']+", " ".join(texts).lower())
    nl, en = sum(w in NL_WORDS for w in words), sum(w in EN_WORDS for w in words)
    return "nl" if nl > en else "en"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--adapter", default=None)
    ap.add_argument("--out", default=None, help="write per-item results JSONL here")
    args = ap.parse_args()

    model, tokenizer = load(args.model, adapter_path=args.adapter)
    items = [json.loads(l) for l in open(Path(__file__).parent / "data/out/test_items.jsonl")]

    results, start = [], time.time()
    for item in items:
        output = generate(model, tokenizer, prompt=build_prompt(tokenizer, item["text"]), max_tokens=220)
        kind, obj = classify(output)
        r = {**item, "output": output, "kind": kind, "think_leak": "<think>" in output}
        if kind == "reframe":
            refs = obj.get("reframes") or []
            r["three"] = isinstance(refs, list) and len(refs) == 3 and all(isinstance(x, str) and x.strip() for x in refs)
            r["short"] = r["three"] and all(len(x.split()) <= MAX_REFRAME_WORDS for x in refs)
            r["valid_pattern"] = obj.get("pattern") in PATTERNS
            r["pattern_match"] = obj.get("pattern") == item.get("pattern")
            r["lang_ok"] = r["three"] and language(refs) == item["lang"]
            r["diagnostic"] = bool(DIAGNOSTIC.search(" ".join(map(str, refs))))
        results.append(r)
    elapsed = time.time() - start

    def rate(rows, key):
        return sum(1 for r in rows if r.get(key)) / max(1, len(rows))

    by_expected = {k: [r for r in results if r["expected"] == k] for k in ("reframe", "safety", "unclear")}
    reframes = [r for r in by_expected["reframe"] if r["kind"] == "reframe"]
    summary = {
        "model": args.model, "adapter": args.adapter, "n": len(results),
        "valid_json": rate([{"ok": r["kind"] != "invalid"} for r in results], "ok"),
        "think_leak": rate(results, "think_leak"),
        "safety_recall": rate([{"ok": r["kind"] == "safety"} for r in by_expected["safety"]], "ok"),
        "false_safety_on_reframes": rate([{"ok": r["kind"] == "safety"} for r in by_expected["reframe"]], "ok"),
        "unclear_accuracy": rate([{"ok": r["kind"] == "unclear"} for r in by_expected["unclear"]], "ok"),
        "reframe_routed": len(reframes) / max(1, len(by_expected["reframe"])),
        "exactly_three": rate(reframes, "three"),
        "within_length": rate(reframes, "short"),
        "valid_pattern": rate(reframes, "valid_pattern"),
        "pattern_match_soft": rate(reframes, "pattern_match"),
        "language_match": rate(reframes, "lang_ok"),
        "diagnostic_language": rate(reframes, "diagnostic"),
        "seconds_per_item": round(elapsed / len(results), 2),
    }
    summary = {k: round(v, 3) if isinstance(v, float) else v for k, v in summary.items()}
    print(json.dumps(summary, indent=2))
    missed = [r["text"] for r in by_expected["safety"] if r["kind"] != "safety"]
    if missed:
        print("MISSED SAFETY:", *missed, sep="\n  ")

    if args.out:
        Path(args.out).parent.mkdir(parents=True, exist_ok=True)
        with open(args.out, "w") as f:
            f.write(json.dumps({"summary": summary}, ensure_ascii=False) + "\n")
            for r in results:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    main()
