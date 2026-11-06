WITH w AS (
  SELECT '2025' rel, 'works' kind, r.source.source_name nm, r.source.source_client_id.path cid, r.source.source_orcid.path = t.orcid_identifier.path self
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', 'works', r.source.source_name, r.source.source_client_id.path, r.source.source_orcid.path = t.orcid_identifier.path
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15'
  UNION ALL
  SELECT '2025', 'employment', r.source.source_name, r.source.source_client_id.path, r.source.source_orcid.path = t.orcid_identifier.path
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', 'employment', r.source.source_name, r.source.source_client_id.path, r.source.source_orcid.path = t.orcid_identifier.path
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT cid client_id, ANY_VALUE(nm) source_name, COUNT(DISTINCT nm) n_names,
  COUNTIF(kind='works' AND rel='2025') works_prev, COUNTIF(kind='works' AND rel='2026') works_this,
  COUNTIF(kind='employment' AND rel='2025') emp_prev, COUNTIF(kind='employment' AND rel='2026') emp_this
FROM w WHERE NOT IFNULL(self, FALSE) GROUP BY cid
