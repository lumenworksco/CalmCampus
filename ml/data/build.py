"""Build train/valid/test JSONL for mlx-lm from the hand-written sources.

    python data/build.py            # writes data/out/{train,valid,test_items}.jsonl

Training/validation rows are chat transcripts {"messages": [system, user, assistant]}.
The test file keeps the expected label so evaluate.py can score it; it is never trained on.
"""
import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import reframes_en_1, reframes_en_2, reframes_en_3, reframes_nl, safety_unclear, test_set  # noqa: E402
from spec import SYSTEM_PROMPT, PATTERNS, MAX_REFRAME_WORDS  # noqa: E402

OUT = Path(__file__).parent / "out"


def reframe_answer(pattern, reframes):
    assert pattern in PATTERNS, pattern
    assert len(reframes) == 3, reframes
    for r in reframes:
        assert len(r.split()) <= MAX_REFRAME_WORDS, r
    return json.dumps({"pattern": pattern, "reframes": reframes}, ensure_ascii=False)


def row(user, answer):
    return {"messages": [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user},
        {"role": "assistant", "content": answer},
    ]}


def main():
    rows = []
    for module in (reframes_en_1, reframes_en_2, reframes_en_3, reframes_nl):
        rows += [row(t, reframe_answer(p, r)) for t, p, r in module.DATA]
    rows += [row(t, reframe_answer(p, r)) for t, p, r in safety_unclear.HYPERBOLE]
    rows += [row(t, '{"safety": true}') for t in safety_unclear.SAFETY]
    rows += [row(t, '{"unclear": true}') for t in safety_unclear.UNCLEAR]

    test_texts = {i["text"].strip().lower() for i in test_set.items()}
    leaks = [r for r in rows if r["messages"][1]["content"].strip().lower() in test_texts]
    assert not leaks, f"training rows duplicate test items: {leaks}"
    users = [r["messages"][1]["content"] for r in rows]
    assert len(users) == len(set(users)), "duplicate training inputs"

    random.Random(42).shuffle(rows)
    n_valid = max(1, len(rows) // 10)
    splits = {"valid": rows[:n_valid], "train": rows[n_valid:]}

    OUT.mkdir(exist_ok=True)
    for name, data in splits.items():
        with open(OUT / f"{name}.jsonl", "w") as f:
            for r in data:
                f.write(json.dumps(r, ensure_ascii=False) + "\n")
    with open(OUT / "test_items.jsonl", "w") as f:
        for item in test_set.items():
            f.write(json.dumps(item, ensure_ascii=False) + "\n")

    kinds = lambda d: {k: sum(1 for r in d if k in r["messages"][2]["content"]) for k in ("reframes", "safety", "unclear")}
    for name, data in splits.items():
        print(f"{name}: {len(data)} rows {kinds(data)}")
    print(f"test: {sum(1 for _ in test_set.items())} items")


if __name__ == "__main__":
    main()
