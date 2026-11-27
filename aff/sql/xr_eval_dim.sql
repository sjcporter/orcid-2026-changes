-- Dimensions run: candidate pairs against Dimensions' own resolution of the same author's string on the same paper.
-- "related" counts a parent, child or related organisation in ROR as a match.
-- Filters: definitely_not = names a different country, or shares no distinctive word or city with the organisation;
-- name_only = keep only strings that share a distinctive name word or acronym.
WITH rel AS (
  SELECT r.id a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b FROM `your-project.ror.records` r, UNNEST(r.relationships) x
), c AS (
  SELECT c.*, s.name_hit, s.place_hit, IFNULL(s.country_conflict, FALSE) country_conflict,
    IFNULL(s.country_conflict, FALSE) OR NOT (s.name_hit OR s.place_hit) definitely_not,
    c.cand_ror = c.ror_truth exact, c.cand_ror = c.ror_truth OR rel.b IS NOT NULL related
  FROM `your-project.your_dataset.xr_cand` c
  JOIN `your-project.your_dataset.xr_score` s ON s.ror = c.cand_ror AND s.raw = c.raw
  LEFT JOIN rel ON rel.a = c.cand_ror AND rel.b = c.ror_truth
  WHERE c.run = 'dim' AND c.ror_truth IS NOT NULL
)
SELECT signal, IF(n_aff = 1, 'one string', 'several strings') strings, IF(n_cand = 1, 'one candidate', 'several candidates') cands,
  COUNT(*) pairs, ROUND(AVG(IF(exact, 1, 0)), 3) precision_all, ROUND(AVG(IF(related, 1, 0)), 3) precision_related_all,
  ROUND(COUNTIF(definitely_not) / COUNT(*), 3) share_flagged,
  ROUND(SAFE_DIVIDE(COUNTIF(exact AND NOT definitely_not), COUNTIF(NOT definitely_not)), 3) precision_kept,
  ROUND(SAFE_DIVIDE(COUNTIF(related AND NOT definitely_not), COUNTIF(NOT definitely_not)), 3) precision_related_kept,
  ROUND(SAFE_DIVIDE(COUNTIF(exact AND definitely_not), COUNTIF(definitely_not)), 3) precision_flagged,
  ROUND(SAFE_DIVIDE(COUNTIF(exact AND NOT definitely_not), COUNTIF(exact)), 3) correct_kept,
  ROUND(SAFE_DIVIDE(COUNTIF(exact AND name_hit), COUNTIF(name_hit)), 3) precision_name_only,
  ROUND(SAFE_DIVIDE(COUNTIF(exact AND name_hit), COUNTIF(exact)), 3) correct_kept_name_only
FROM c GROUP BY 1, 2, 3 ORDER BY 1, 2, 3
