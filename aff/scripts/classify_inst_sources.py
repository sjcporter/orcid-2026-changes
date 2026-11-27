"""Mark which sources are an institution's own system, reusing earlier classifications where they exist.
Order: the release analysis's works classification, then the affiliations buckets, then the name rules
(with the affiliations overrides) for sources neither saw.
Run from the repository root.
Usage: python3 -I aff/scripts/classify_inst_sources.py all_sources.csv works_classes.csv aff_source_buckets.csv inst_sources.csv"""
import csv
import re
import sys

sys.path.insert(0, "scripts")
from classify_sources import INSTITUTION, classify  # noqa: E402

sys.path.pop(0)
OVERRIDE_INST = r"orcid hub|^tenet south africa|^high energy accelerator|^jasri$|^landcare research|^agresearch|^gns science" \
                r"|^royal society te|^motu economic|^branz$|^auckland war memorial|^lincoln agritech|^uc viden|^pureexper|^architecture, design and conservation"
OVERRIDE_NOT = r"^nasa open science|^cfi award management|^nz orcid hub for ministry|^concytec$" \
               r"|^american association for cancer research|^proceedings of the national academy|^american academy of child|^medical physics$" \
               r"|^american cancer society|^health research board|^research corporation for science|^national information processing institute|^national institute of informatics"

src_f, works_f, aff_f, out_f = sys.argv[1:5]
works = {r["client_id"]: r["source_subclass"] for r in csv.DictReader(open(works_f, encoding="utf-8"))}
aff = {r["client_id"]: r["bucket"] for r in csv.DictReader(open(aff_f, encoding="utf-8"))}
rows = list(csv.DictReader(open(src_f, encoding="utf-8")))
for r in rows:
    cid, nm = r["client_id"], (r["source_name"] or "").strip().lower()
    if cid in works:
        inst, basis = works[cid] == INSTITUTION, "works classification"
    elif cid in aff:
        inst, basis = aff[cid] == "Institution's own system", "affiliations buckets"
    else:
        inst, basis = classify(r["source_name"])[0] == INSTITUTION, "name rules"
    if re.search(OVERRIDE_NOT, nm):
        inst = False
    elif re.search(OVERRIDE_INST, nm):
        inst = True
    r["institution"], r["basis"] = inst, basis
with open(out_f, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
    w.writeheader(); w.writerows(rows)
inst = [r for r in rows if r["institution"]]
print(len(rows), "sources;", len(inst), "institutional;", sum(int(r["n_2026"]) for r in inst), "items in 2026")
for b in ("works classification", "affiliations buckets", "name rules"):
    print(b, sum(1 for r in inst if r["basis"] == b))
