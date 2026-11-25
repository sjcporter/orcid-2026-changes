-- Which organisation each institution system stands for: the organisation ID it most often puts on its own
-- employment entries, and the current employer its researchers most often enter themselves (one row for each).
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_inst_org` AS
WITH own AS (
  SELECT src inst, org_id, COUNT(*) n, SUM(COUNT(*)) OVER (PARTITION BY src) tot
  FROM `your-project.your_dataset.orcid_aff_2026`
  WHERE section = 'employment' AND NOT self_asserted AND org_id IS NOT NULL AND src != 'APP-4B3XYWJHXCC1VLVV' GROUP BY 1, 2
), self_emp AS (
  SELECT p.inst, a.org_id, COUNT(DISTINCT p.id) n, ANY_VALUE(tot) tot
  FROM (SELECT inst, id, COUNT(*) OVER (PARTITION BY inst) tot FROM `your-project.your_dataset.orcid_inst_pairs` WHERE in_2026 AND NOT via_mp) p
  JOIN `your-project.your_dataset.orcid_aff_2026` a ON a.id = p.id AND a.section = 'employment' AND a.self_asserted AND a.ey IS NULL AND a.org_id IS NOT NULL
  GROUP BY 1, 2
), pick AS (
  SELECT inst, org_id, 'own entries' basis, n / tot share FROM own QUALIFY ROW_NUMBER() OVER (PARTITION BY inst ORDER BY n DESC) = 1
  UNION ALL
  SELECT inst, org_id, "researchers' own entries", n / tot FROM self_emp
  QUALIFY ROW_NUMBER() OVER (PARTITION BY inst ORDER BY n DESC) = 1
)
SELECT * FROM pick
