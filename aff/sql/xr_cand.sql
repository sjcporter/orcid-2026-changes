-- Candidate (ROR, affiliation string) pairs. An instance is one author on one DOI; each of its strings is paired with
-- each ROR the ORCID record suggests for that paper:
--   emp      employment or education entry with a ROR (via any ID type) whose dates cover the publication year
--   inst_doi the institution's own system wrote this DOI to the record (the system's ROR)
-- Runs: dim (Dimensions researcher matched to the iD), cr_orcid (Crossref author carries the iD and the surname
-- matches the ORCID record), cr_surname (the DOI is on the ORCID record and exactly one Crossref author has that surname).
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_cand` AS
WITH nm AS (
  SELECT id, REGEXP_REPLACE(NORMALIZE(family, NFD), r'\p{M}', '') fam FROM `your-project.your_dataset.xr_orcid_name`
), inst AS (
  SELECT 'dim' run, doi, year, id, raw, n_aff, ror_truth FROM `your-project.your_dataset.xr_dim`
  UNION ALL
  SELECT 'cr_orcid', c.doi, c.yr, c.orcid, c.raw, c.n_aff, CAST(NULL AS STRING)
  FROM `your-project.your_dataset.xr_cr` c JOIN nm ON nm.id = c.orcid
  WHERE REGEXP_REPLACE(NORMALIZE(c.family, NFD), r'\p{M}', '') = nm.fam
  UNION ALL
  SELECT 'cr_surname', c.doi, c.yr, d.id, c.raw, c.n_aff, CAST(NULL AS STRING)
  FROM `your-project.your_dataset.xr_cr` c
  JOIN (SELECT DISTINCT id, doi FROM `your-project.your_dataset.orcid_doi_2026`) d ON d.doi = c.doi
  JOIN nm ON nm.id = d.id AND nm.fam = REGEXP_REPLACE(NORMALIZE(c.family, NFD), r'\p{M}', '')
  WHERE c.n_same_family = 1
), cand AS (
  SELECT DISTINCT i.run, 'emp' signal, i.doi, i.id, i.year, i.raw, i.n_aff, i.ror_truth, e.ror cand_ror
  FROM inst i JOIN `your-project.your_dataset.xr_orcid_emp` e
    ON e.id = i.id AND (e.sy IS NULL OR e.sy <= i.year) AND (e.ey IS NULL OR e.ey >= i.year)
  UNION ALL
  SELECT DISTINCT i.run, 'inst_doi', i.doi, i.id, i.year, i.raw, i.n_aff, i.ror_truth, d.ror
  FROM inst i JOIN `your-project.your_dataset.xr_orcid_inst_doi` d ON d.id = i.id AND d.doi = i.doi
)
SELECT *, COUNT(DISTINCT cand_ror) OVER (PARTITION BY run, signal, doi, id) n_cand FROM cand
