-- Crosswalk from every organisation ID used in ORCID, Crossref and Dimensions to a bare ROR ID (e.g. 04040yw90).
-- GRID and FundRef come from the ROR registry. Ringgold has no public crosswalk, so a Ringgold ID maps to the
-- ROR ID that ORCID employment entries with the same organisation name most often carry (at least half of them).
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_ror_map` AS
WITH reg AS (
  SELECT 'ROR' key_type, id k, id ror FROM `your-project.ror.records`
  UNION ALL
  SELECT UPPER(e.type), a, r.id FROM `your-project.ror.records` r, UNNEST(r.external_ids) e, UNNEST(e.all) a
  WHERE e.type IN ('grid', 'fundref')
), orcid_emp AS (
  SELECT LOWER(TRIM(org)) nm, org_id_type, org_id FROM `your-project.your_dataset.orcid_aff_2026`
  WHERE section = 'employment' AND org_id IS NOT NULL
), name_ror AS (  -- modal ROR per organisation name, where ORCID entries name one
  SELECT nm, REGEXP_EXTRACT(org_id, r'([0-9a-z]{9})$') ror, COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY nm) share
  FROM orcid_emp WHERE org_id_type = 'ROR' GROUP BY nm, ror QUALIFY ROW_NUMBER() OVER (PARTITION BY nm ORDER BY COUNT(*) DESC) = 1
), ringgold AS (
  SELECT 'RINGGOLD' key_type, e.org_id k, n.ror, COUNT(*) n
  FROM orcid_emp e JOIN name_ror n USING (nm) WHERE e.org_id_type = 'RINGGOLD' AND n.share >= 0.5
  GROUP BY 1, 2, 3 QUALIFY COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY k) >= 0.5 AND ROW_NUMBER() OVER (PARTITION BY k ORDER BY COUNT(*) DESC) = 1
)
SELECT DISTINCT key_type, k, ror FROM reg
UNION DISTINCT SELECT key_type, k, ror FROM ringgold
