-- Self-entered work records created Oct 2025 - Oct 2026: how many sit in a work group that also has a record
-- from another source (so an integration sent the same work too), with and without a DOI.
SELECT
  EXISTS(SELECT 1 FROM UNNEST(r.external_ids.identifiers) i WHERE i.type = 'doi') has_doi,
  COUNT(*) self_records,
  COUNTIF(EXISTS(SELECT 1 FROM UNNEST(g.records) o
                 WHERE IFNULL(o.source.source_orcid.path, '') != t.orcid_identifier.path)) also_from_other_source
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15'
  AND r.source.source_orcid.path = t.orcid_identifier.path
GROUP BY 1
