WITH w AS (
  SELECT '2025' rel, IF(r.source.source_orcid.path = t.orcid_identifier.path, '(self-entered)', IFNULL(r.source.source_name, '(unknown)')) src, r.type = 'preprint' is_pre
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', IF(r.source.source_orcid.path = t.orcid_identifier.path, '(self-entered)', IFNULL(r.source.source_name, '(unknown)')), r.type = 'preprint'
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT src, COUNTIF(rel='2025') prev_year, COUNTIF(rel='2026') this_year,
  COUNTIF(rel='2026' AND is_pre) preprints_this_year, COUNTIF(rel='2025' AND is_pre) preprints_prev_year
FROM w GROUP BY src ORDER BY this_year DESC LIMIT 15
