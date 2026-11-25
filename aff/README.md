# Affiliations in ORCID, and what institutions tell it without saying it, 2024–2026

A follow-up to the 2026 release analysis. It looks at the six affiliation sections of ORCID records (employment, education, qualifications, invited positions, memberships, service) in the 2024, 2025 and 2026 public data files. It asks who writes them, whether entries written by institutions last, and what every other item an institution writes says about where a researcher works.

## Findings

1. **Who writes affiliations.** Researchers entered 98.4% of the 30.9M affiliation entries in the 2026 file. Institutions' own systems wrote 419k, and the ORCID Member Portal 50k. Of employment entries from institutions' systems, 38% have a start date and 36% a role. For researchers' own entries, both figures are 71–72% (`data/aff_by_source.csv`).
2. **Do institutional entries last?** Each year, about 83% of the employment pairs written by institutions' systems keep their entry, about 11% are deleted and written again, and about 5% disappear (`data/aff_pair_fate_summary.csv`). Systems recreate their entries in one-off waves: of 188 systems, 34 recreated heavily in one year and 3 in both (`data/aff_pair_fate_by_system.csv`). Half of the recreated pairs changed something, and 65% of those gained an end date (`data/aff_recreated_changes.csv`).
3. **Every item is an affiliation.** If any item an institution's system writes counts as "this researcher is ours", the 2026 file holds 459k researcher–institution links from 654 systems. That is 44% more than the 318k with an affiliation from the system. For 39.5k researchers it is the only institution visible: they have no employment at all (`data/inst_coverage.csv`).
4. **first_seen and last_seen.** These are the earliest and latest created dates of the items a system wrote for a researcher. `last_seen` is within a year of the institution's stated end date for 55% of ended entries. `first_seen` is within a year of the stated start for 49%, counting only starts after the system began writing to ORCID (`data/inst_dates_check.csv`).
5. **Early warning.** Take the open employment entries in the 2024 file at systems that maintain their entries. The share ended or removed by 2026 rises with time since `last_seen`: 22% for entries seen in the year before, 37% at 1–2 years, and 57% at 2–5 years (`data/inst_early_warning.csv`).

## Definitions

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
| `data/` | Query outputs (aggregates only, and the list of institutional systems) |

The entry, pair and link tables hold individual ORCID iDs, so they are not published here. To rebuild them, save the `CREATE TABLE` queries as tables in your own dataset, replacing `your-project.your_dataset`.

## Caveats

- Public data only, so every count is a lower bound. A deleted entry and one made private look the same, so "removed" is an upper bound.
- Pairs are matched on organisation name. A new position at the same organisation counts as "recreated, changed", and a renamed employer counts as removed. With yearly files, an entry recreated twice in a year looks the same as one recreated once.
- `first_seen` can be no earlier than a system's first write to ORCID. `last_seen` moves forward when a system recreates entries or sends papers published after someone left.
