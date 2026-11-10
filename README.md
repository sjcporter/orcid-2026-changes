# What changed in the ORCID 2026 public data file

A comparison of the ORCID Public Data File 2026 (snapshot of 14 October 2026) with the 2025 release: who joins ORCID, what they add, and which systems write to their records.

- **Dashboard:** [`docs/index.html`](docs/index.html), served at <https://sjcporter.github.io/orcid-2026-changes/> when GitHub Pages is enabled. It has charts, tables and the SQL behind every figure.
- **Blog post:** [`blog/post.md`](blog/post.md), also a tab on the dashboard.
- **NSW follow-up:** [`nsw/`](nsw/) follows ten New South Wales university integrations and their co-author network across the 2024, 2025 and 2026 files.

## Findings

| | 2025 release | 2026 release |
|---|---|---|
| Public records | 25.05M | 29.99M (+19.7%) |
| Public works | 122.1M | 145.1M (+18.9%) |
| Records with an employer | 35.5% | 42.1% |
| Works added by Clarivate services (in the release year) | ~161k | ~5.0M |
| Works researchers added themselves (in the release year) | 4.83M | 7.02M (+45%) |
| Profiles linking to Bluesky | 4,576 | 6,410 (+40%) |

1. **Employment.** Two-thirds of new researchers list an employer, up from under a fifth. The jump starts with accounts created in February–March 2024, when ORCID began prompting for an employer at registration.
2. **Web of Science** became a main route for works into ORCID after Clarivate switched to new ORCID clients in September–October 2025.
3. **Self-entered works.** Researchers added 7.0M works themselves. Of the 4.49M with a DOI, 84% have no copy from any integration on the record.
4. **Institutions.** 68% of works sent by institutional systems come from Europe, and under 4% from Asia, Latin America, Africa and the Middle East.
5. **Churn.** 41% of this year's institutional employment entries replace an entry the same system had already sent, so year-on-year counts overstate new coverage.
6. **Links.** GitHub overtook X/Twitter, and Bluesky has a small but growing foothold.

## Repository layout

| Path | What it holds |
|---|---|
| `sql/` | Every BigQuery query behind the dashboard, one file per query |
| `data/` | Query outputs (aggregates only) used to build the page, plus `source_classes.csv`, the classification of 838 source systems |
| `scripts/classify_sources.py` | Heuristic classification of source systems from their names |
| `scripts/prefix_names.py` | Names DOI prefixes through the Crossref and DataCite APIs (set `CONTACT_EMAIL` to identify yourself) |
| `site/` | Page template and build script |
| `docs/index.html` | The built dashboard |
| `blog/post.md` | The blog post |
| `nsw/` | The NSW universities follow-up: queries, scripts, outputs and pictures |

## Reproducing

1. Load the ORCID summaries into BigQuery. The queries expect tables shaped like `ds-open-datasets.orcid.summaries_2025` and `summaries_2026`, as produced by [digital-science/ds-external-dataset-transformations](https://github.com/digital-science/ds-external-dataset-transformations/tree/main/orcid).
2. Two queries (`au_detail.sql`, `pub_mix_class.sql`) join to the source classification. Load `data/source_classes.csv` into your own dataset and replace `your-project.your_dataset.orcid_source_classes`.
3. Run the queries and save their output to `data/`. BigQuery bills by the columns a query reads. Most of these read 1–20 GB, and the whole set costs a few dollars.
4. Rebuild the page from the repository root: `python3 site/build_page.py`.

## Caveats

- Public data only, so every count is a lower bound. About 1.16M records in the snapshot are placeholders for locked, deprecated or deactivated accounts.
- Release-year comparisons use each item's created date, in 14 October to 14 October windows.
- Apart from the 145.1M headline, works figures count work records: one per source per researcher. A paper sent by two systems counts twice.
- An institutional system's country is inferred from the employers in the entries it writes, as ORCID does not record it.
- The links between the data and outside events (ORCID's 2024 registration change, Clarivate's new ORCID connection) come from release notes and timing, and are noted as such on the page.

## Licences

The ORCID Public Data File is released by ORCID under [CC0](https://creativecommons.org/publicdomain/zero/1.0/). Code in this repository is under the MIT licence (see `LICENSE`). The blog post and dashboard text are under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
