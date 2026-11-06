WITH w AS (
  SELECT '2025' rel, r.type FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', r.type FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT type, COUNTIF(rel='2025') added_prev_year, COUNTIF(rel='2026') added_this_year,
  ROUND(100*(COUNTIF(rel='2026')-COUNTIF(rel='2025'))/NULLIF(COUNTIF(rel='2025'),0)) pct_change
FROM w GROUP BY type ORDER BY added_this_year DESC LIMIT 20
