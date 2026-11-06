WITH e AS (
  SELECT '2025' rel, IF(r.source.source_orcid.path = t.orcid_identifier.path, 'self', 'integration') kind, IFNULL(r.source.source_name,'?') src
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', IF(r.source.source_orcid.path = t.orcid_identifier.path, 'self', 'integration'), IFNULL(r.source.source_name,'?')
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT IF(kind='self','(self-asserted)',src) src, COUNTIF(rel='2025') prev_year, COUNTIF(rel='2026') this_year
FROM e GROUP BY 1 ORDER BY this_year DESC LIMIT 30
