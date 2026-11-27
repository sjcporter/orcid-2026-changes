"""Write the SQL for the implicit-affiliation analysis: every item a source writes to a record, in all sections.
Writes all_sources.sql and inst_items.sql into the current directory.
Usage: python3 -I make_sql.py"""
SECTIONS = [  # (kind, FROM clause after the table alias t)
    ("work", "UNNEST(t.activities.works.groups) g, UNNEST(g.records) r"),
    ("funding", "UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r"),
    ("peer_review", "UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r"),
    ("research_resource", "UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r"),
    ("employment", "UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r"),
    ("education", "UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r"),
    ("qualification", "UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r"),
    ("invited_position", "UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r"),
    ("membership", "UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r"),
    ("service", "UNNEST(t.activities.services.groups) g, UNNEST(g.records) r"),
    ("external_id", "UNNEST(t.person.external_identifiers.identifiers) r"),
    ("url", "UNNEST(t.person.researcher_urls.urls) r"),
    ("keyword", "UNNEST(t.person.keywords.keywords) r"),
    ("other_name", "UNNEST(t.person.other_names.names) r"),
    ("address", "UNNEST(t.person.addresses.addresses) r"),
]
SRC = "IFNULL(r.source.source_client_id.path, r.source.source_orcid.path)"
NOT_SELF = f"{SRC} IS NOT NULL AND {SRC} != t.orcid_identifier.path"


def items(yr: int, cols: str, where: str) -> str:
    return "\n  UNION ALL\n".join(
        f"  SELECT {yr} yr, '{k}' kind, {cols}\n  FROM `ds-open-datasets.orcid.summaries_{yr}` t, {f}\n  WHERE {NOT_SELF}{where}"
        for k, f in SECTIONS)


# 1. Every non-self source in any section of any snapshot, for classification.
src_cols = f"{SRC} src, r.source.source_name nm, t.orcid_identifier.path id"
body = "\n  UNION ALL\n".join(items(y, src_cols, "") for y in (2024, 2025, 2026))
open("all_sources.sql", "w").write(
    "-- Every source (other than the researcher) that writes anything to a public record, with item counts by snapshot.\n"
    f"WITH a AS (\n{body}\n)\nSELECT src client_id, ANY_VALUE(nm) source_name, STRING_AGG(DISTINCT kind ORDER BY kind) kinds,\n"
    "  COUNTIF(yr = 2024) n_2024, COUNTIF(yr = 2025) n_2025, COUNTIF(yr = 2026) n_2026, COUNT(DISTINCT IF(yr = 2026, id, NULL)) ids_2026\n"
    "FROM a GROUP BY 1\n")

# 2. Every item written by an institution's own system, with its dates.
item_cols = (f"t.orcid_identifier.path id, {SRC} src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, "
             "r.created_date cd, r.last_modified_date lmd")
where = f" AND {SRC} IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')"
body = "\n  UNION ALL\n".join(items(y, item_cols, where) for y in (2024, 2025, 2026))
open("inst_items.sql", "w").write(
    "-- One row per item written by an institution's own system, in any section, in each snapshot.\n"
    "CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_inst_items` AS\n" + body + "\n")
