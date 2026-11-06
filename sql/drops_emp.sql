-- Did employment entries written by integrations survive from the 2025 to the 2026 snapshot?
-- No per-entry id is stored, so entries are matched on (iD, source client, created timestamp).
WITH prev AS (
  SELECT t.orcid_identifier.path id, r.source.source_client_id.path client, ANY_VALUE(r.source.source_name) src, r.created_date cd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.source.source_client_id.path IS NOT NULL
  GROUP BY 1, 2, 4
), cur AS (
  SELECT DISTINCT t.orcid_identifier.path id, r.source.source_client_id.path client, r.created_date cd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE r.source.source_client_id.path IS NOT NULL
), ids AS (SELECT DISTINCT orcid_identifier.path id FROM `ds-open-datasets.orcid.summaries_2026`)
SELECT p.client, ANY_VALUE(p.src) source_name, COUNT(*) in_2025,
  COUNTIF(c.id IS NOT NULL) still_there,
  COUNTIF(c.id IS NULL AND i.id IS NOT NULL) gone_record_public,
  COUNTIF(i.id IS NULL) gone_record_not_public,
  COUNTIF(p.cd >= '2024-10-14') in_2025_added_last_window,
  COUNTIF(p.cd >= '2024-10-14' AND c.id IS NULL) gone_added_last_window
FROM prev p
LEFT JOIN cur c ON c.id = p.id AND c.client = p.client AND c.cd = p.cd
LEFT JOIN ids i ON i.id = p.id
GROUP BY 1 HAVING in_2025 >= 300 ORDER BY in_2025 DESC
