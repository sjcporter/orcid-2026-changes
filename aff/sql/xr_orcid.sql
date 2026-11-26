-- ORCID side of the experiment (2026 file): surnames, employment and education entries with a ROR ID and dates,
-- and the DOIs an institution's own system wrote to a record, with that system's ROR ID.
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_orcid_name` AS
SELECT orcid_identifier.path id, LOWER(TRIM(person.name.family_name)) family
FROM `ds-open-datasets.orcid.summaries_2026` WHERE person.name.family_name IS NOT NULL;

CREATE OR REPLACE TABLE `your-project.your_dataset.xr_orcid_emp` AS
SELECT a.id, a.section, a.self_asserted, m.ror, SAFE_CAST(a.sy AS INT64) sy, SAFE_CAST(a.ey AS INT64) ey
FROM `your-project.your_dataset.orcid_aff_2026` a
JOIN `your-project.your_dataset.xr_ror_map` m ON m.key_type = a.org_id_type
  AND m.k = CASE a.org_id_type WHEN 'ROR' THEN REGEXP_EXTRACT(a.org_id, r'([0-9a-z]{9})$')
                               WHEN 'FUNDREF' THEN REGEXP_EXTRACT(a.org_id, r'(\d+)$') ELSE a.org_id END
WHERE a.section IN ('employment', 'education');

CREATE OR REPLACE TABLE `your-project.your_dataset.xr_orcid_inst_doi` AS
WITH sys AS (  -- one ROR per institutional system: the organisation on its own entries, else its researchers'
  SELECT o.inst, m.ror FROM `your-project.your_dataset.orcid_inst_org` o
  JOIN `your-project.your_dataset.xr_ror_map` m ON m.key_type = CASE
      WHEN o.org_id LIKE 'https://ror.org/%' THEN 'ROR' WHEN o.org_id LIKE 'grid.%' THEN 'GRID'
      WHEN o.org_id LIKE '%10.13039/%' THEN 'FUNDREF' ELSE 'RINGGOLD' END
    AND m.k = CASE WHEN o.org_id LIKE 'https://ror.org/%' THEN REGEXP_EXTRACT(o.org_id, r'([0-9a-z]{9})$')
                   WHEN o.org_id LIKE '%10.13039/%' THEN REGEXP_EXTRACT(o.org_id, r'(\d+)$') ELSE o.org_id END
  WHERE (o.basis = 'own entries' OR o.share >= 0.2)
    AND o.inst IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources`)
  QUALIFY ROW_NUMBER() OVER (PARTITION BY o.inst ORDER BY o.basis = 'own entries' DESC, o.share DESC) = 1
)
SELECT DISTINCT d.id, d.doi, s.ror FROM `your-project.your_dataset.orcid_doi_2026` d JOIN sys s ON s.inst = d.src;
