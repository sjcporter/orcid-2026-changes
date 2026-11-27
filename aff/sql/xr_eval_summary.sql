-- Summary by run and signal: how many variants each rule yields, and how precise they are against the reference.
WITH e AS (SELECT * FROM `your-project.your_dataset.xr_eval`)
SELECT run, signal, rule, COUNT(*) pairs, COUNT(DISTINCT cand_ror) rors, COUNT(DISTINCT CONCAT(cand_ror, '|', raw)) variants,
  ROUND(COUNTIF(ref_ror IS NOT NULL) / COUNT(*), 3) with_ref,
  ROUND(SAFE_DIVIDE(COUNTIF(exact), COUNTIF(ref_ror IS NOT NULL)), 3) precision,
  ROUND(SAFE_DIVIDE(COUNTIF(related), COUNTIF(ref_ror IS NOT NULL)), 3) precision_related
FROM (
  SELECT *, 'all' rule FROM e UNION ALL
  SELECT *, 'text' FROM e WHERE NOT definitely_not UNION ALL
  SELECT *, 'text+pick' FROM e WHERE picked)
GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
