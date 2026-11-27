# How could ORCID be used more effectively in affiliations matching?

A follow-up to the 2026 release analysis. It tests how ORCID records can help match affiliation strings on papers to ROR organisation IDs: as the decider when the text fits several organisations, and as a source of the ways each organisation is written. It then looks at where ORCID's affiliation information comes from: the six affiliation sections (employment, education, qualifications, invited positions, memberships, service) in the 2024, 2025 and 2026 public data files, whether entries written by institutions last, and what every other item an institution writes says about where a researcher works.

## Findings

### Matching

A. **A simple text matcher, and where it runs out.** The matcher is deliberately basic, built to show what ORCID adds rather than to compete with matching services. A typical affiliation string has about 120 ROR organisations whose distinctive name words it contains. For almost half of strings the best text score is tied; where one organisation scores highest it agrees with Dimensions about half the time. On its own, the matcher agrees with Dimensions for about one in five strings.
B. **ORCID as the decider.** Take the RORs on the author's ORCID record for the publication year (dated employment and education, plus the institution whose system sent the paper). Where exactly one text candidate is among them, ORCID decides: for 40–49% of instances with a text candidate, agreeing with Dimensions 85–90% of the time (89–93% if a parent or child organisation one level apart counts), and 72–79% of the time when it overrules the matcher's top pick. The matcher plus ORCID agrees with Dimensions for about one in two strings (52–55% counting parent or child, `data/xr_decider_levels.csv`). This holds for authors linked to ORCID through Dimensions (used because it gives the broadest clean set of papers, though any algorithmic dataset can be wrong) for Crossref authors whose iD is in the Crossref metadata (with the surname also matching, as iDs are occasionally attached to the wrong author), and for Crossref authors matched by surname only (`data/xr_decider_summary.csv`, `data/xr_decider_cro_summary.csv`, `data/xr_decider_cr_summary.csv`, `data/xr_decider_cr_examples.csv`).
C. **Training data: a dictionary of variants.** Each string paired with an organisation ID from the author's record is a labelled example for training a matcher. Unfiltered, 60–67% of pairs agree with Dimensions. Dropping strings that cannot belong to the organisation (no shared distinctive word or place, or a different country) lifts that to 80–85%, and keeping the best text match to 85–90% (92–94% counting parent or child organisations). Across runs: 14.2M variants for 53k organisations, 5.3M without a reference in Dimensions (`data/xr_eval_summary.csv`, `data/xr_eval_dim.csv`, `data/xr_variants.csv`).
D. **Names that several organisations share.** Looking for whole ROR names word for word in each string, about 0.3% of instances use a name that several active organisations share (Chang Gung Memorial Hospital, Mahatma Gandhi University, Sacred Heart College). A city in the string settles 65–83% of these. Where none does, the text matcher agrees with Dimensions 5–11% of the time; ORCID decides for 30–36% and agrees 61–80% of the time, on small numbers. Strings naming several organisations, which the author may all mean, are 10–11% of instances; 55–58% name exactly one, and about a third contain no whole name (`data/xr_ambig_summary.csv`, `data/xr_ambig_examples.csv`).

### Where ORCID's affiliation information comes from

1. **Who writes affiliations.** Researchers entered 98.4% of the 30.9M affiliation entries in the 2026 file. Institutions' own systems wrote 419k, and the ORCID Member Portal 50k. Of employment entries from institutions' systems, 38% have a start date and 36% a role. For researchers' own entries, both figures are 71–72% (`data/aff_by_source.csv`).
2. **Do institutional entries last?** Each year, about 83% of the employment pairs written by institutions' systems keep their entry, about 11% are deleted and written again, and about 5% disappear (`data/aff_pair_fate_summary.csv`). Systems recreate their entries in one-off waves: of 188 systems, 34 recreated heavily in one year and 3 in both (`data/aff_pair_fate_by_system.csv`). Half of the recreated pairs changed something, and 65% of those gained an end date (`data/aff_recreated_changes.csv`).
3. **Who makes an assertion is an affiliation signal.** If any item an institution's system writes counts as "this researcher is ours", the 2026 file holds 459k researcher–institution links from 654 systems. That is 44% more than the 318k with an affiliation from the system. For 39.5k researchers it is the only institution visible: they have no employment at all (`data/inst_coverage.csv`).
4. **first_seen and last_seen.** These are the earliest and latest created dates of the items a system wrote for a researcher. `last_seen` is within a year of the institution's stated end date for 55% of ended entries. `first_seen` is within a year of the stated start for 49%, counting only starts after the system began writing to ORCID (`data/inst_dates_check.csv`).
5. **Early warning.** Take the open employment entries in the 2024 file at systems that maintain their entries. The share ended or removed by 2026 rises with time since `last_seen`: 22% for entries seen in the year before, 37% at 1–2 years, and 57% at 2–5 years (`data/inst_early_warning.csv`).

## Definitions

- **Instance (matching).** One author's affiliation string on one paper. Three runs: `dim` (Dimensions researchers matched one-to-one to an ORCID iD), `cr_orcid` (the Crossref author carries the iD and the surname matches the record), `cr_surname` (the DOI is on the ORCID record, the accent-stripped surname matches, and no other author on the paper shares it). DOIs are lower-cased when comparing systems.
- **Text candidates.** ROR organisations with a distinctive name word (in at most 300 organisations' names, at least 3 letters, or an acronym) in the string, and no conflict with a country named in the string's last two parts. Score = words matched, plus 0.5 if the city matches (`sql/xr_text.sql`).
- **Kinds of string (D).** A ROR name or label of two words or more, without digits, from an active record, found word for word in the string. "One name": the longest such name belongs to several organisations the string's country allows; "a city settles it" if exactly one of them has its ROR city in the string. "Several organisations named": whole names of more than one organisation, the longest belonging to one (`sql/xr_ambig.sql`).
- **Reference.** How Dimensions resolved the same string: for the same author on the same paper (decider runs), or most often across all papers (dictionary runs, `sql/xr_dim_dict.sql`).
- **Pair (sections 1–2).** One iD, section, source and organisation name (lowercased). Created timestamps show whether the same entry survived ("kept") or was replaced ("recreated"). Dates, role and department show whether a replacement changed anything.
- **Link (sections 3–5).** One iD and one institutional system. All items count, in every section and in all three files. Member Portal entries count for the institution they were made on behalf of.
- **Institutional systems.** 745 sources, classified as an institution's own system by name (`scripts/classify_inst_sources.py`, which reuses `scripts/classify_sources.py` at the repository root). The list is in `data/inst_sources.csv`.
- **Organisation of a system.** The organisation ID a system most often puts on its own employment entries, plus the current employer its researchers most often enter. Each is widened to the names and other IDs (ROR, Ringgold, GRID, Crossref Funder) used with it (`sql/inst_org_map.sql`, `sql/inst_org_keys.sql`). Systems with no clear organisation, such as data services, are left out of sections 3–5.
- **Maintained system.** A system that still wrote works in the last year, and ended or removed at least 5% of its open 2024 entries.

## Layout

| Path | What it holds |
|---|---|
| `sql/aff_2026.sql`, `sql/aff_detail.sql` | One row per affiliation entry (the 2024 and 2025 versions differ only in the file name) |
| `sql/aff_sources.sql`, `sql/aff_by_source.sql` | Who writes affiliations, and how complete their entries are |
| `sql/aff_pair_fate*.sql`, `sql/aff_recreated_changes.sql`, `sql/aff_rewrite_age.sql`, `sql/aff_dupes.sql` | Following pairs between files |
| `scripts/make_sql.py` | Writes `sql/all_sources.sql` and `sql/inst_items.sql`, covering every section of every file |
| `sql/inst_pairs.sql`, `sql/inst_org_*.sql`, `sql/inst_coverage.sql`, `sql/inst_dates_check.sql`, `sql/inst_early_warning.sql` | Links, first_seen and last_seen, and the checks against explicit dates |
| `sql/xr_ror_map.sql`, `sql/xr_orcid.sql`, `sql/xr_dim.sql`, `sql/xr_cr.sql` | Matching: organisation IDs mapped to ROR, the RORs on each ORCID record, and affiliation strings from Dimensions and Crossref |
| `sql/xr_text.sql`, `sql/xr_score.sql`, `sql/xr_cand.sql`, `sql/xr_eval*.sql`, `sql/xr_dim_dict.sql`, `sql/xr_variants.sql` | The text test and the variant dictionary |
| `sql/xr_decider*.sql` | ORCID as the decider, with agreement counted exactly and one parent or child level apart (`xr_decider_levels.sql`) |
| `sql/xr_ambig*.sql` | Names that several organisations share |
| `data/` | Query outputs (aggregates only, the list of institutional systems, and example strings) |

The entry, pair and link tables hold individual ORCID iDs, so they are not published here. To rebuild them, save the `CREATE TABLE` queries as tables in your own dataset, replacing `your-project.your_dataset`. The matching queries also read the Crossref metadata (`your-project.crossref.metadata`, from a Crossref public data file), the ROR data dump (`your-project.ror.records`) and Dimensions on BigQuery (`dimensions-ai.data_analytics`), which needs a subscription.

## Caveats

- Matching is checked against Dimensions, so its errors count against every method, and a parent-or-unit choice that differs from Dimensions counts as wrong. Only 33% of Crossref iD instances and 38% of surname-only instances have a Dimensions answer for the same author, string and paper. Decider runs use a 2% sample of strings.
- Public data only, so every count is a lower bound. A deleted entry and one made private look the same, so "removed" is an upper bound.
- Pairs are matched on organisation name. A new position at the same organisation counts as "recreated, changed", and a renamed employer counts as removed. With yearly files, an entry recreated twice in a year looks the same as one recreated once.
- `first_seen` can be no earlier than a system's first write to ORCID. `last_seen` moves forward when a system recreates entries or sends papers published after someone left.
