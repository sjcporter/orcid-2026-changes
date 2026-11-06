"""Resolve DOI prefixes to publisher/registrant names via the public Crossref and DataCite APIs."""
import csv
import os
import json
import sys
import time
import urllib.error
import urllib.request

# Crossref and DataCite ask API users to identify themselves; set CONTACT_EMAIL to join Crossref's polite pool.
UA = {"User-Agent": "orcid-release-analysis/1.0" + (f" (mailto:{os.environ['CONTACT_EMAIL']})" if os.environ.get("CONTACT_EMAIL") else "")}

def get_json(url: str) -> dict | None:
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=20) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code in (401, 403, 404):
                return None
            if e.code in (429, 502, 503, 504):
                time.sleep(2 ** attempt); continue
            return None
        except (urllib.error.URLError, TimeoutError):
            time.sleep(2 ** attempt)
    return None

def resolve(prefix: str) -> tuple[str, str]:
    cr = get_json(f"https://api.crossref.org/prefixes/{prefix}")
    if cr and cr.get("message", {}).get("name"):
        return cr["message"]["name"], "Crossref"
    dc = get_json(f"https://api.datacite.org/prefixes/{prefix}?include=providers")
    if dc:
        for inc in dc.get("included", []):
            if inc.get("type") == "providers":
                return inc["attributes"].get("name", "?"), "DataCite"
        return "?", "DataCite"
    return "?", "unknown"

if __name__ == "__main__":
    src, out = sys.argv[1], sys.argv[2]
    rows = list(csv.DictReader(open(src)))
    for r in rows:
        if r["prefix"].startswith("10."):
            r["publisher"], r["registry"] = resolve(r["prefix"])
        else:
            r["publisher"], r["registry"] = "", ""
    with open(out, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
