-- One row per (iD, DOI, source) from the 2024 snapshot; save as your-project.your_dataset.orcid_doi_2024.
SELECT t.orcid_identifier.path id, LOWER(TRIM(i.normalized)) doi,
  IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, r.created_date cd, gi gidx
FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.works.groups) g WITH OFFSET gi, UNNEST(g.records) r, UNNEST(r.external_ids.identifiers) i
WHERE i.type = 'doi' AND IFNULL(i.relationship,'self') = 'self' AND i.normalized IS NOT NULL
