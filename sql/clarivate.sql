-- Works added Oct 2025 - Oct 2026 by Clarivate sources: when, how old, and whether the same work was already
-- on the record from another source (another record in the same ORCID work group).
WITH w AS (
  SELECT r.source.source_name src, r.source.source_client_id.path client, SUBSTR(r.created_date, 1, 7) ym,
    SAFE_CAST(r.publication_date.year AS INT64) py,
    (SELECT COUNT(*) FROM UNNEST(g.records) o WHERE IFNULL(o.source.source_client_id.path, '') != IFNULL(r.source.source_client_id.path, '')) other_recs,
    (SELECT COUNT(*) FROM UNNEST(g.records) o WHERE o.source.source_name IN ('Web of Science Researcher Profile Sync', 'ResearcherID', 'Publons')
       AND IFNULL(o.source.source_client_id.path, '') != IFNULL(r.source.source_client_id.path, '')) old_clarivate_recs
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2024-10-14' AND r.created_date < '2026-10-15'
    AND REGEXP_CONTAINS(r.source.source_name, r'(?i)web of science|clarivate|researcherid|publons'))
SELECT src, client, ym, COUNT(*) n, COUNTIF(other_recs > 0) already_from_other, COUNTIF(old_clarivate_recs > 0) already_from_old_clarivate,
  COUNTIF(py < 2020) pub_pre2020, COUNTIF(py >= 2025) pub_2025plus
FROM w GROUP BY 1, 2, 3 ORDER BY 1, 3
