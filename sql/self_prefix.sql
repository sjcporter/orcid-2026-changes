WITH w AS (
  SELECT IF(r.source.source_orcid.path = t.orcid_identifier.path, 'self', IF(r.source.source_name = 'Crossref', 'crossref', 'other')) kind,
    (SELECT REGEXP_EXTRACT(LOWER(IFNULL(i.normalized, i.value)), r'(10\.\d{4,9})/') FROM UNNEST(r.external_ids.identifiers) i WHERE i.type = 'doi' LIMIT 1) prefix
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT IFNULL(prefix, '(no DOI)') prefix, COUNTIF(kind='self') self_entered, COUNTIF(kind='crossref') crossref_auto, COUNTIF(kind='other') other_integrations, COUNT(*) total
FROM w GROUP BY 1 ORDER BY self_entered DESC LIMIT 400
