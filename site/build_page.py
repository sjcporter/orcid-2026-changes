"""Assemble data/ (query outputs) and site/page_template.html into docs/index.html. Run from the repository root."""
import collections
import csv
import html as html_lib
import re
import json

D = json.load(open("data/page_data.json"))
D["stats"] = [["29.99M", "public records", "+19.7% on 2025"], ["4.96M", "records new since 2025", "13.6k dropped out"],
              ["145.1M", "public works", "+18.9% on 2025"], ["7.0M", "works self-entered this year", "+45% on last year"],
              ["6,410", "profiles linking to Bluesky", "+40%, vs 65.3k for X"]]

REG = {}
for grp, cs in {"East Asia": "CN JP KR TW HK MO MN", "South Asia": "IN PK BD LK NP AF BT MV",
                "Southeast Asia": "ID PH MY TH VN SG MM KH LA BN TL", "North America": "US CA",
                "Latin America & Caribbean": "BR PE CO EC MX AR CL VE BO PY UY CR CU DO GT HN NI PA SV PR JM TT HT",
                "Middle East & N. Africa": "TR IR SA EG IQ AE JO IL LB QA KW OM BH SY YE PS MA DZ TN LY",
                "Sub-Saharan Africa": "NG KE ET GH ZA TZ UG CM SD ZW ZM MW RW SN CI BJ BF ML NE TG MZ AO CD CG GA SO SS LR SL GM GN MG BW NA LS SZ ER DJ",
                "Oceania": "AU NZ FJ PG", "Russia, Ukraine & C. Asia": "RU UA BY KZ UZ AZ GE AM KG TJ TM MD"}.items():
    for c in cs.split(): REG[c] = grp
reg = collections.defaultdict(lambda: [0, 0])
for r in csv.DictReader(open("data/emp_by_country.csv")):
    g = "(no country)" if r["country"] == "(none)" else REG.get(r["country"], "Europe")
    reg[g][0] += int(r["prev_total"]); reg[g][1] += int(r["this_total"])
D["emp_regions"] = sorted([[g, a, b] for g, (a, b) in reg.items()], key=lambda x: -x[2])
D["emp_sources"] = [["Researchers themselves" if s == "(self-asserted)" else s, a, b] for s, a, b in D["emp_sources"]]
D["work_sources"] = [["Self-entered" if s == "(self-entered)" else s, a, b] for s, a, b in D["work_sources"]]

dc_ch = collections.Counter(); dc_ty = collections.defaultdict(lambda: [0, 0])
for r in csv.DictReader(open("data/datacite.csv")):
    if r["section"] != "by_datacite_client": continue
    ch = "Researcher search & link" if "on behalf of user" in r["k"] else "Automatic update"
    dc_ch[(ch, 0)] += int(r["prev_year"]); dc_ch[(ch, 1)] += int(r["this_year"])
    dc_ty[r["type"]][0] += int(r["prev_year"]); dc_ty[r["type"]][1] += int(r["this_year"])
D["dc_channels"] = [[c, dc_ch[(c, 0)], dc_ch[(c, 1)]] for c in ("Automatic update", "Researcher search & link")]
D["dc_types"] = sorted([[t, a, b] for t, (a, b) in dc_ty.items()], key=lambda x: -x[2])[:8]

ALIAS = {"CERN - European Organization for Nuclear Research": "Zenodo (CERN)", "Informa UK Limited": "Taylor & Francis",
         "Ovid Technologies (Wolters Kluwer Health)": "Wolters Kluwer Health", "Springer Science and Business Media LLC": "Springer Nature",
         "Institute of Electrical and Electronics Engineers (IEEE)": "IEEE", "Elsevier BV": "Elsevier", "MDPI AG": "MDPI",
         "Frontiers Media SA": "Frontiers", "Oxford University Press (OUP)": "Oxford University Press",
         "Cambridge University Press (CUP)": "Cambridge University Press", "Walter de Gruyter GmbH": "De Gruyter"}
pub = collections.defaultdict(collections.Counter); reg_of = {}
for r in csv.DictReader(open("data/prefixes_named.csv")):
    if not r["prefix"].startswith("10.") or r["publisher"] in ("?", ""): continue
    n = ALIAS.get(r["publisher"], r["publisher"]); reg_of[n] = r["registry"]
    for f in ("self_entered", "crossref_auto", "total", "prev_self"): pub[n][f] += int(r[f])
D["publishers"] = [{"name": n + (" (DataCite DOIs)" if reg_of[n] == "DataCite" else ""), "self": c["self_entered"], "total": c["total"],
                    "crossref": c["crossref_auto"], "prev_self": c["prev_self"], "datacite": reg_of[n] == "DataCite"}
                   for n, c in sorted(pub.items(), key=lambda kv: -kv[1]["self_entered"])[:20]]
D["pub_mix"] = json.load(open("data/pub_mix.json"))["pub_mix"]
S = json.load(open("data/inst_summary.json"))
names = {"Index / discovery service": "Index / discovery service", "Registration agency auto-update": "DOI agency auto-update (Crossref, DataCite)",
         "Institution (university, hospital, research institute)": "Institution (university, hospital, institute)"}
nclients = collections.Counter(r["source_subclass"] for r in csv.DictReader(open("data/source_classes.csv", encoding="utf-8")))
D["classes"] = sorted([[names.get(k, k), v[0], v[1], v[3], nclients[k]] for k, v in S["subclass"].items()], key=lambda x: -x[2])
D["inst_countries"] = [[k, v[0], v[1]] for k, v in S["countries"].items() if k != "(unknown)"]
mix = json.load(open("data/pub_mix_class.json"))
D["pub_mix"] = [[r[0] if r[0] not in ("Zenodo (CERN)", "arXiv", "ResearchGate") else r[0] + " (DataCite DOIs)", r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9]] for r in mix["rows"]]
cvm = collections.defaultdict(collections.Counter)
for r in csv.DictReader(open("data/clarivate.csv")):
    key = {"APP-1DSJAQCZ1PW1VN5X": "old", "APP-OKON44OLRIOZU944": "wos", "APP-PIPD3W8Z8DY9GESR": "profiles"}.get(r["client"])
    if key: cvm[key][r["ym"]] += int(r["n"])
months = [f"{y}-{m:02d}" for y in (2024, 2025, 2026) for m in range(1, 13) if "2024-11" <= f"{y}-{m:02d}" <= "2026-09"]
D["clarivate"] = {"months": months, **{k: [cvm[k][m] for m in months] for k in ("old", "wos", "profiles")}}
D["link_pairs"] = [[r["pa"], r["pb"], int(r["both_n"]), int(r["n_a"]), int(r["n_b"]), float(r["lift"])] for r in csv.DictReader(open("data/link_pairs.csv"))]

# NSW follow-up (nsw/): data for the second blog post. Notre Dame's client is the US university's and is left out.
NAME = {"USyd": "Sydney"}
SNAPS = ("2024", "2025", "2026")
nsw_rows = lambda f: list(csv.DictReader(open("nsw/data/" + f)))
nsw_works = collections.defaultdict(lambda: [0, 0, 0])
for r in nsw_rows("nsw_clients_by_snapshot.csv"):
    if r["section"] == "work" and r["uni"] != "Notre Dame":
        nsw_works[NAME.get(r["uni"], r["uni"])][SNAPS.index(r["yr"])] += int(r["entries"])
reach = {r["uni"]: r for r in nsw_rows("nsw_reach.csv") if r["uni"] != "Notre Dame"}
route = {r["uni"]: r for r in nsw_rows("nsw_emp_route.csv")}
credit = nsw_rows("nsw_new_links_last_year.csv")
net = json.load(open("nsw/data/nsw_network_stats.json"))
D["nsw"] = {
    "works": sorted([[u, *v] for u, v in nsw_works.items()], key=lambda x: -x[3]),
    "reach": sorted([[NAME.get(u, u), int(r["research_staff"]), int(r["reached_by_own_integration"])] for u, r in reach.items()],
                    key=lambda x: -x[2] / x[1]),
    "credit": [[NAME.get(r["uni"], r["uni"]), int(r["new_links_credited"]), int(r["between_universities"])] for r in credit],
    "credit_total": int(credit[0]["total_new_int_links"]), "new_total": int(credit[0]["total_new_links"]),
    # [university, research staff, works added last year, of which by hand, employment by own system, by Member Portal, by either]
    "aff": sorted([[NAME.get(u, u), int(r["research_staff"]), int(r["works_added_ly"]), int(r["works_ly_by_hand"]),
                    int(route[u]["emp_by_own_system"]), int(route[u]["emp_by_member_portal"]), int(r["emp_written_by_uni"])]
                   for u, r in reach.items()], key=lambda x: -x[6] / x[1]),
    "snaps": {s: {k: net[s][k] for k in ("edges", "researchers_linked", "largest_component", "edges_between_universities",
                                           "edges_only_via_integration", "new_since_first", "new_since_first_only_via_integration")}
              for s in SNAPS},
}
D["nsw_stats"] = [["10", "NSW universities writing to ORCID", "New England 2016 to Western Sydney 2026"],
                  ["+51%", "co-author links, 2024 to 2026", "81.9k → 124k, same researchers"],
                  ["2 in 5", "new links seen only via a university", "16.6k of 42.3k since 2024"],
                  ["1 in 6", "last year’s new links from Sydney", "4.4k of 26.1k"]]
html = open("site/page_template.html").read().replace("/*DATA*/null", json.dumps(D, separators=(",", ":")))


NOTES = {"completeness_urls.sql": "Backs \"only 6% of records list any website\": 6.1%, 5.9% and 6.0% in the 2024, 2025 and 2026 releases. Trimmed from a wider record-completeness query to the column used here.",
         "completeness_employment.sql": "Backs the 27% \u2192 36% \u2192 42% share of records with employment (27.4%, 35.5%, 42.1%). Trimmed from a wider record-completeness query to the column used here.",
         "source_names.sql": "Source names are then classified by classify_sources.py (name rules); see the method notes.",
         "self_prefix.sql": "DOI prefixes are then named from the Crossref and DataCite APIs by prefix_names.py.",
         "au_detail.sql": "Uses the classification table built from source_names.sql and classify_sources.py."}


def sql_block(m: "re.Match[str]") -> str:
    """Expand <!--SQL:a.sql,b.sql--> into a collapsible panel holding those queries."""
    files = m.group(1).split(",")
    parts = []
    for f in files:
        note = f'<span class="note">{html_lib.escape(NOTES[f])}</span>' if f in NOTES else ""
        path = f if "/" in f else "sql/" + f
        parts.append(f'<div class="q"><b>{f.split("/")[-1]}</b>{note}<pre><code>{html_lib.escape(open(path).read().rstrip())}</code></pre></div>')
    label = "Show the SQL" + (f" ({len(files)} queries)" if len(files) > 1 else "")
    return f'<details class="sql"><summary>{label}</summary>{"".join(parts)}</details>'


html = re.sub(r"<!--SQL:([\w./,]+)-->", sql_block, html)
head, body = html.split("\n<main>", 1)
page = ('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n'
        + head + "\n</head>\n<body>\n<main>" + body + "\n</body>\n</html>\n")
open("docs/index.html", "w").write(page)
print(len(html), D["dc_channels"], D["publishers"][:2])
