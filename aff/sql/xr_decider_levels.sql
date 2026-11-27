-- Agreement with Dimensions in two tiers, for the three decider runs: the same ROR ID, or a parent or child one level
-- apart in ROR's relationships (e.g. a medical school and its university). Instances with a text candidate and a
-- Dimensions answer, as in the decider summaries.
WITH d AS (
  SELECT 'dim' run, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT 'cr_orcid', ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT 'cr_surname', ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cr`
), pc AS (
  SELECT DISTINCT REGEXP_EXTRACT(r.id, r'([0-9a-z]{9})$') a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b
  FROM `your-project.ror.records` r, UNNEST(r.relationships) x WHERE x.type IN ('parent', 'child')
), x AS (
  SELECT d.*, IF(n_top = 1, top_ror, NULL) text_pick, COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) comb FROM d
  WHERE ror_truth IS NOT NULL AND n_text > 0
), lv AS (
  SELECT x.*,
    CASE WHEN text_pick IS NULL THEN NULL WHEN text_pick = ror_truth THEN 'exact' WHEN EXISTS (SELECT 1 FROM pc WHERE pc.a = text_pick AND pc.b = ror_truth) THEN 'level' ELSE 'other' END text_lv,
    CASE WHEN orcid_pick IS NULL THEN NULL WHEN orcid_pick = ror_truth THEN 'exact' WHEN EXISTS (SELECT 1 FROM pc WHERE pc.a = orcid_pick AND pc.b = ror_truth) THEN 'level' ELSE 'other' END orcid_lv,
    CASE WHEN comb IS NULL THEN NULL WHEN comb = ror_truth THEN 'exact' WHEN EXISTS (SELECT 1 FROM pc WHERE pc.a = comb AND pc.b = ror_truth) THEN 'level' ELSE 'other' END comb_lv
  FROM x
)
SELECT run, COUNT(*) instances,
  ROUND(COUNTIF(text_lv = 'exact') / COUNT(*), 3) text_exact, ROUND(COUNTIF(text_lv IN ('exact', 'level')) / COUNT(*), 3) text_exact_or_level,
  ROUND(COUNTIF(orcid_lv IS NOT NULL) / COUNT(*), 3) orcid_decides,
  ROUND(COUNTIF(orcid_lv = 'exact') / COUNTIF(orcid_lv IS NOT NULL), 3) orcid_exact,
  ROUND(COUNTIF(orcid_lv IN ('exact', 'level')) / COUNTIF(orcid_lv IS NOT NULL), 3) orcid_exact_or_level,
  ROUND(COUNTIF(comb_lv = 'exact') / COUNT(*), 3) comb_exact, ROUND(COUNTIF(comb_lv IN ('exact', 'level')) / COUNT(*), 3) comb_exact_or_level
FROM lv GROUP BY 1 ORDER BY 1
