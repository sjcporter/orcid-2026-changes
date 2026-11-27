-- Who sources affiliation entries, by snapshot, section and source group, and what the entries record.
WITH a AS (
  SELECT '2024' yr, a.*, IF(a.self_asserted, 'Researcher', IFNULL(s.bucket, 'Other')) bucket
  FROM `your-project.your_dataset.orcid_aff_2024` a LEFT JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = a.src
  UNION ALL
  SELECT '2025' yr, a.*, IF(a.self_asserted, 'Researcher', IFNULL(s.bucket, 'Other')) bucket
  FROM `your-project.your_dataset.orcid_aff_2025` a LEFT JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = a.src
  UNION ALL
  SELECT '2026' yr, a.*, IF(a.self_asserted, 'Researcher', IFNULL(s.bucket, 'Other')) bucket
  FROM `your-project.your_dataset.orcid_aff_2026` a LEFT JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = a.src
)
SELECT yr, section, bucket, COUNT(*) entries, COUNT(DISTINCT id) researchers,
  ROUND(100 * COUNTIF(sy IS NOT NULL) / COUNT(*), 1) pct_start,
  ROUND(100 * COUNTIF(sm IS NOT NULL) / COUNT(*), 1) pct_start_month,
  ROUND(100 * COUNTIF(ey IS NOT NULL) / COUNT(*), 1) pct_end,
  ROUND(100 * COUNTIF(org_id IS NOT NULL) / COUNT(*), 1) pct_org_id,
  ROUND(100 * COUNTIF(org_id_type = 'ROR') / COUNT(*), 1) pct_ror,
  ROUND(100 * COUNTIF(org_id_type = 'RINGGOLD') / COUNT(*), 1) pct_ringgold,
  ROUND(100 * COUNTIF(has_role) / COUNT(*), 1) pct_role,
  ROUND(100 * COUNTIF(has_dept) / COUNT(*), 1) pct_dept,
  COUNTIF(origin IS NOT NULL AND origin != src) on_behalf_of
FROM a GROUP BY 1, 2, 3 ORDER BY 1, 2, entries DESC
