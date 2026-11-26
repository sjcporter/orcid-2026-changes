-- Variants kept by the text+pick rule: per run, and across all runs, with how many Dimensions has no reference for.
WITH v AS (
  SELECT run, cand_ror, raw, LOGICAL_OR(ref_ror IS NOT NULL) has_ref, LOGICAL_OR(exact) exact, COUNT(*) n
  FROM `your-project.your_dataset.xr_eval` WHERE picked GROUP BY 1, 2, 3
), per AS (
  SELECT run, COUNT(*) variants, COUNT(DISTINCT cand_ror) rors, COUNTIF(NOT has_ref) no_ref, COUNTIF(n >= 2) seen_twice
  FROM (SELECT *, COUNT(*) OVER (PARTITION BY run, cand_ror) cnt FROM v) GROUP BY 1
), allv AS (
  SELECT cand_ror, raw, ARRAY_AGG(DISTINCT run) runs, LOGICAL_OR(has_ref) has_ref FROM v GROUP BY 1, 2
)
SELECT * FROM per
UNION ALL
SELECT 'all runs', COUNT(*), COUNT(DISTINCT cand_ror), COUNTIF(NOT has_ref), COUNTIF(ARRAY_LENGTH(runs) >= 2) FROM allv
UNION ALL
SELECT 'only from crossref runs', COUNT(*), COUNT(DISTINCT cand_ror), COUNTIF(NOT has_ref), NULL FROM allv WHERE 'dim' NOT IN UNNEST(runs)
