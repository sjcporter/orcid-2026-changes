WITH w AS (
  SELECT '2025' rel, r.type, IFNULL(r.source.source_name,'?') src, r.source.source_client_id.path client,
    r.source.source_orcid.path = t.orcid_identifier.path self, r.source.assertion_origin_name origin
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2025-10-14'
  UNION ALL
  SELECT '2026', r.type, IFNULL(r.source.source_name,'?'), r.source.source_client_id.path,
    r.source.source_orcid.path = t.orcid_identifier.path, r.source.assertion_origin_name
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT 'by_datacite_client' section, CONCAT(src, ' [', IFNULL(client,'-'), ']', IF(origin IS NOT NULL, ' on behalf of user', '')) k, type,
  COUNTIF(rel='2025') prev_year, COUNTIF(rel='2026') this_year
FROM w WHERE LOWER(src) LIKE '%datacite%' GROUP BY 1,2,3
UNION ALL
SELECT 'datasets_software_by_source', IF(self, '(self-entered)', src), type, COUNTIF(rel='2025'), COUNTIF(rel='2026')
FROM w WHERE type IN ('data-set','software') GROUP BY 1,2,3
