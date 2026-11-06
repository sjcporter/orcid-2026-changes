WITH au AS (SELECT client_id, source_name FROM `your-project.your_dataset.orcid_source_classes`
            WHERE country = 'AU' AND source_class LIKE 'Institution%'),
w AS (
  SELECT au.source_name, t.orcid_identifier.path id, SAFE_CAST(r.publication_date.year AS INT64) py, SUBSTR(r.created_date, 1, 7) ym,
    (SELECT COUNT(*) FROM UNNEST(g.records) o WHERE IFNULL(o.source.source_client_id.path, o.source.source_orcid.path) != r.source.source_client_id.path) other_recs,
    EXISTS(SELECT 1 FROM UNNEST(r.external_ids.identifiers) i WHERE i.type = 'doi') has_doi
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  JOIN au ON au.client_id = r.source.source_client_id.path
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT source_name, COUNT(*) works, COUNT(DISTINCT id) researchers,
  ROUND(100*COUNTIF(py >= 2025)/COUNT(*)) pct_pub_2025_on, ROUND(100*COUNTIF(py < 2020)/COUNT(*)) pct_pub_pre2020,
  ROUND(100*COUNTIF(other_recs = 0)/COUNT(*)) pct_only_source, ROUND(100*COUNTIF(has_doi)/COUNT(*)) pct_doi,
  APPROX_TOP_COUNT(ym, 3) top_months
FROM w GROUP BY 1 ORDER BY works DESC LIMIT 12
