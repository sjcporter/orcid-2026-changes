"""Heuristic classification of ORCID source clients (the systems that write to ORCID records).

Rules are checked in order and the first match wins. Explicit lists for the big, well-known
services come first, because their names don't follow a pattern. Name patterns for
institutions, journals and repositories follow.

Usage: python3 -I classify_sources.py source_names.csv source_classes.csv
"""
import csv
import re
import sys

REGISTRATION_AGENCY = "Registration agency auto-update"
INDEX = "Index / discovery service"
PUBLISHER = "Publisher / journal platform"
INSTITUTION = "Institution (university, hospital, research institute)"
REPOSITORY = "Repository / preprint server"
NATIONAL = "National research information system"
FUNDER = "Funder / government"
ORCID_TOOL = "ORCID affiliation manager"
OTHER = "Other / unclassified"

# Exact (case-insensitive) or prefix names for services whose names carry no type signal.
KNOWN: list[tuple[str, str]] = [
    (r"^crossref$|^datacite|^jalc$|^medra|^kisti|^airiti|^cnki doi", REGISTRATION_AGENCY),
    (r"^scopus|^web of science|^clarivate|^publons|^researcherid|^dimensions$|^the lens$|^europe pubmed central"
     r"|^inspire-hep|^nasa astrophysics|^openaire|^base - bielefeld|^mla international|^deutsche nationalbibliothek"
     r"|^gnd network|^scienceon$|^heinonline|^redalyc|^openalex|^semantic scholar|^dblp|^crossref metadata search"
     r"|^google scholar|^pubmed|^ebsco|^proquest|^cab direct|^agris|^ieee xplore|^researchgate|^academia\.edu"
     r"|^scilit|^sciprofiles|^sciencegate|^scienceleadr|^my research space|^tracking information products", INDEX),
    (r"^multidisciplinary digital publishing|^aaas|^igi global|^f1000|^wellcome open research|^galoá|^sciendo"
     r"|^scienceopen|^frontiers|^plos|^elsevier|^springer|^wiley|^taylor|^sage|^emerald|^karger|^thieme"
     r"|^de gruyter|^bentham|^hindawi|^copernicus|^pensoft|^iop |^acs |^rsc |^bmj|^jmir|^cureus|^peerj"
     r"|^open research europe|^gates open research|^tib open publishing|^aries|^editorial manager|^scholarone"
     r"|^ejournalpress|^iaoe online journals|^tidsskrift|open research$|^open research africa|^knowledge e$|^tuwhera", PUBLISHER),
    # Institutional repositories whose names don't say "university".
    (r"^archive ouverte unige|^cadmus, eui|^western sydney research|^our archive|^zora \(zurich|^soar \(scholarly open access at rutgers"
     r"|^albert - the digital repository|^arbor - applied research bern|^cornell ecommons|^corpusul|^orfee - hep vaud"
     r"|^fisheries and oceans canada|^scion$|^kula:", INSTITUTION),
    (r"^figshare|^zenodo|^hal$|^arxiv|^osf|^biorxiv|^medrxiv|^verixiv|^ssrn|^preprints\.org|^research square"
     r"|^dryad|^dataverse|^mendeley data|^researcher\.life|^open science framework|preprint|^protocols\.io"
     r"|^pennsieve|^fairsharing|^morphobank|^reactome|^apicuron|^federated research data repository", REPOSITORY),
    (r"^ciênciavitae|^cienciavitae|^lattes|^cvlac|^cti vitae|^authenticus|^cristin|^swepub|^nora$|^current research information system in norway"
     r"|^research information system of|^national research information|^ris3|^pure ?- ?research information system of slovenia|^sicris|^ndltd"
     r"|^higher council for science|^registro de producción intelectual", NATIONAL),
    (r"^researchfish|^ükerresearch|^uberresearch|^doe osti|^nih|^nsf|^ukri|^erc$|^european research council|^nwo"
     r"|^dfg|^anr$|^wellcome trust|^research council|^national science foundation|^cordis|^california digital library",
     FUNDER),
    (r"^orcid member portal|^orcid affiliation", ORCID_TOOL),
]

# Name signals, checked after KNOWN.
INSTITUTION_PAT = re.compile(
    r"universit|univerzit|uniwersytet|universidad|universidade|università|hochschul|politecnic|polytechn|college"
    r"|school|institut|academy|akadem|hospital|health|medical|medicine|medizin|clinic|klinik|cancer|children"
    r"|ku leuven|\bcsic\b|c\.s\.i\.c|\bcnr\b|csiro|ifremer|cirad|\brti\b|\bdlr\b|luft- und raumfahrt|eurac|\bvtt\b|\bkaust\b|\bgist\b"
    r"|karolinska|charité|erasmus|\btu[ e]|\btum|\beth\b|\bepfl\b|\bmit\b|caltech|cedars|sloan|nemours|capital region"
    r"|region sjaelland|region |\bpure\b|symplectic|elements|\biris\b|\bcris\b|experts@|experts at|profile manager"
    r"|research portal|research explorer|research output|research bank|digital measures|\bfis\b|\bobd\b|omega-psir"
    r"|cris\b|^cris|esploro|research connect|research discovery|forschungszentrum|embl|\bsuny\b|_agh|^slu |^dial$|proforis|^rims$|^ucar|^fgv|^ait |^liser|sito della ricerca|academic hub|myunifr|^libra$|research online|research information|scholars|faculty|libraries|library|my ?cv|mypublications|knowledge base"
    r"|wageningen|james hutton|research institute|\bcentre\b|\bcenter\b|laborator|\bgesellschaft\b|bibliography",
    re.I)
JOURNAL_PAT = re.compile(r"journal|revista|riviste|revues|press\b|publishing|publisher|publications? manager|manuscript|ojs\b", re.I)
REPO_PAT = re.compile(r"repositor|archive|e-?prints|dspace|open access", re.I)


def classify(name: str) -> tuple[str, str]:
    """Return (class, rule) for a source name."""
    n = (name or "").strip()
    low = n.lower()
    for pat, cls in KNOWN:
        if re.search(pat, low):
            return cls, "known"
    # Journals hosted by universities ("Revistas UANL") are publishing platforms, so check before institutions.
    if JOURNAL_PAT.search(n) and not re.search(r"publications? at|publication database|publication management", low):
        return PUBLISHER, "journal-pattern"
    if INSTITUTION_PAT.search(n):
        return INSTITUTION, "institution-pattern"
    if REPO_PAT.search(n):
        return REPOSITORY, "repository-pattern"
    return OTHER, "none"


if __name__ == "__main__":
    src, out = sys.argv[1], sys.argv[2]
    rows = list(csv.DictReader(open(src, encoding="utf-8")))
    for r in rows:
        r["source_class"], r["rule"] = classify(r["source_name"])
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
