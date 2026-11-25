-- Widen each system's organisation from one ID to every way researchers write it: names used with that ID
-- (where the name mostly points to that ID, so generic names like "university" drop out), and other IDs
-- (Ringgold, GRID, ROR) used with those names. Three rounds, so a GRID-only system reaches its ROR and Ringgold forms.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_inst_org_keys` AS
WITH emp AS (
  SELECT LOWER(TRIM(org)) nm, org_id FROM `your-project.your_dataset.orcid_aff_2026`
  WHERE section = 'employment' AND org IS NOT NULL
), id_names AS (  -- names used with each ID, and how much of that name's ID'd use points there
  SELECT nm, org_id, COUNT(*) n,
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY org_id) share_of_id,
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY nm) share_of_name
  FROM emp WHERE org_id IS NOT NULL GROUP BY 1, 2
), ids0 AS (
  SELECT inst, org_id FROM `your-project.your_dataset.orcid_inst_org` WHERE basis = 'own entries' OR share >= 0.2
), own_names AS (  -- names the system itself puts on at least 5% of its employment entries
  SELECT src inst, LOWER(TRIM(org)) nm FROM `your-project.your_dataset.orcid_aff_2026`
  WHERE section = 'employment' AND NOT self_asserted AND org IS NOT NULL
  GROUP BY 1, 2 QUALIFY COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY src) >= 0.05
), names1 AS (  -- names that mostly point to the IDs found so far
  SELECT ids.inst, n.nm FROM ids0 ids JOIN id_names n ON n.org_id = ids.org_id
  GROUP BY 1, 2 HAVING SUM(n.share_of_name) >= 0.5 AND MAX(n.share_of_id) >= 0.01 AND LENGTH(n.nm) >= 8
  UNION DISTINCT SELECT inst, nm FROM own_names WHERE inst IN (SELECT inst FROM ids0)
), ids1 AS (  -- plus the other IDs used with those names
  SELECT inst, org_id FROM ids0
  UNION DISTINCT SELECT a.inst, n.org_id FROM names1 a JOIN id_names n ON n.nm = a.nm WHERE n.share_of_name >= 0.1
), names2 AS (  -- names that mostly point to the IDs found so far
  SELECT ids.inst, n.nm FROM ids1 ids JOIN id_names n ON n.org_id = ids.org_id
  GROUP BY 1, 2 HAVING SUM(n.share_of_name) >= 0.5 AND MAX(n.share_of_id) >= 0.01 AND LENGTH(n.nm) >= 8
), ids2 AS (  -- plus the other IDs used with those names
  SELECT inst, org_id FROM ids1
  UNION DISTINCT SELECT a.inst, n.org_id FROM names2 a JOIN id_names n ON n.nm = a.nm WHERE n.share_of_name >= 0.1
), names3 AS (  -- names that mostly point to the IDs found so far
  SELECT ids.inst, n.nm FROM ids2 ids JOIN id_names n ON n.org_id = ids.org_id
  GROUP BY 1, 2 HAVING SUM(n.share_of_name) >= 0.5 AND MAX(n.share_of_id) >= 0.01 AND LENGTH(n.nm) >= 8
), ids3 AS (  -- plus the other IDs used with those names
  SELECT inst, org_id FROM ids2
  UNION DISTINCT SELECT a.inst, n.org_id FROM names3 a JOIN id_names n ON n.nm = a.nm WHERE n.share_of_name >= 0.1
)
SELECT inst, 'id' key_type, org_id k FROM ids3
UNION DISTINCT SELECT inst, 'name', nm FROM names3
