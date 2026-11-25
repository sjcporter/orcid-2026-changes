"""Group affiliation sources into the buckets used in the affiliations post.
Starts from the general source classifier and adds overrides for sources that only write affiliations.
Usage: python3 -I classify_aff_sources.py aff_source_classes.csv aff_source_buckets.csv"""
import csv, re, sys

BUCKET = {"Institution (university, hospital, research institute)": "Institution's own system",
          "ORCID affiliation manager": "ORCID Member Portal",
          "National research information system": "National system",
          "Funder / government": "Funder or government",
          "Publisher / journal platform": "Publisher, index or repository",
          "Index / discovery service": "Publisher, index or repository",
          "Repository / preprint server": "Publisher, index or repository",
          "Registration agency auto-update": "Publisher, index or repository",
          "Other / unclassified": "Other"}
OVERRIDE = [  # (name pattern, bucket)
    (r"^concytec$", "National system"),
    (r"^nasa open science|^cfi award management|^nz orcid hub for ministry", "Funder or government"),
    (r"orcid hub|^tenet south africa", "Institution's own system"),  # hubs write on behalf of member institutions
    (r"^high energy accelerator|^jasri$|^landcare research|^agresearch|^gns science|^royal society te|^motu economic|^branz$"
     r"|^auckland war memorial|^lincoln agritech|^wsp new zealand|^uc viden|^pureexper|^architecture, design and conservation", "Institution's own system"),
    (r"^american chemical society reviewers", "Publisher, index or repository"),
    (r"^rob_b +prod test", "Other"),
]

rows = list(csv.DictReader(open(sys.argv[1], encoding="utf-8")))
for r in rows:
    b = BUCKET[r["source_class"]]
    for pat, ob in OVERRIDE:
        if re.search(pat, r["source_name"].strip().lower()):
            b = ob
            break
    r["bucket"] = b
with open(sys.argv[2], "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["client_id", "source_name", "user_sourced", "source_class", "bucket", "n_2024", "n_2025", "n_2026"], extrasaction="ignore")
    w.writeheader(); w.writerows(rows)
