-- Headline counts: public records in each release, records new since 2025 and gone since 2025, public works.
WITH a AS (SELECT orcid_identifier.path id,
             (SELECT COUNT(*) FROM UNNEST(activities.works.groups) g, UNNEST(g.records) r WHERE r.last_modified_date IS NOT NULL) works_records
           FROM `ds-open-datasets.orcid.summaries_2025`),
b AS (SELECT orcid_identifier.path id,
             (SELECT COUNT(*) FROM UNNEST(activities.works.groups) g, UNNEST(g.records) r WHERE r.last_modified_date IS NOT NULL) works_records
           FROM `ds-open-datasets.orcid.summaries_2026`)
SELECT
  (SELECT COUNT(*) FROM a) records_2025, (SELECT COUNT(*) FROM b) records_2026,
  (SELECT COUNT(*) FROM b LEFT JOIN a USING (id) WHERE a.id IS NULL) new_since_2025,
  (SELECT COUNT(*) FROM a LEFT JOIN b USING (id) WHERE b.id IS NULL) gone_since_2025,
  (SELECT SUM(works_records) FROM a) work_records_2025, (SELECT SUM(works_records) FROM b) work_records_2026
