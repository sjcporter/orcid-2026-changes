WITH e AS (
  SELECT '2025' rel, r.organization.address.country c, r.source.source_orcid.path = t.orcid_identifier.path self
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', r.organization.address.country, r.source.source_orcid.path = t.orcid_identifier.path
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT IFNULL(c, '(none)') country,
  COUNTIF(rel='2025') prev_total, COUNTIF(rel='2026') this_total,
  COUNTIF(rel='2025' AND NOT IFNULL(self,FALSE)) prev_institutional, COUNTIF(rel='2026' AND NOT IFNULL(self,FALSE)) this_institutional
FROM e GROUP BY 1 ORDER BY this_total DESC
