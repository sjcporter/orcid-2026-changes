-- ORCID as the decider on genuinely ambiguous strings (xr_ambig.sql), by run and kind of string. Instances with a
-- Dimensions answer only; "correct" = the same ROR ID as Dimensions. Text pick = the matcher's single top candidate.
WITH d AS (
  SELECT 'dim' run, doi, id, raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT 'cr_orcid', doi, id, raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT 'cr_surname', doi, id, raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cr`
), x AS (
  SELECT d.*, CASE a.cls WHEN 'ambiguous' THEN IF(a.place_settles, '1 one name, a city settles it', '2 one name, no city settles it')
    WHEN 'several' THEN '3 several organisations named' WHEN 'one' THEN '4 one organisation named' ELSE '5 no whole name' END kind,
    a.n_top n_same_name, SPLIT(a.top_rors, '|') same_name
  FROM d JOIN `your-project.your_dataset.xr_ambig` a USING (raw) WHERE d.ror_truth IS NOT NULL
)
SELECT run, kind, COUNT(*) instances, ROUND(AVG(n_same_name), 1) avg_same_name,
  ROUND(SAFE_DIVIDE(COUNTIF(ror_truth IN UNNEST(same_name)), COUNTIF(same_name IS NOT NULL)), 3) truth_is_same_name,
  ROUND(COUNTIF(n_top = 1 AND top_ror = ror_truth) / COUNT(*), 3) text_correct,
  ROUND(COUNTIF(orcid_pick IS NOT NULL) / COUNT(*), 3) orcid_decides,
  ROUND(SAFE_DIVIDE(COUNTIF(orcid_pick = ror_truth), COUNTIF(orcid_pick IS NOT NULL)), 3) orcid_acc,
  ROUND(SAFE_DIVIDE(COUNTIF(orcid_pick IN UNNEST(same_name)), COUNTIF(orcid_pick IS NOT NULL AND same_name IS NOT NULL)), 3) orcid_pick_is_same_name,
  ROUND(COUNTIF(COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) = ror_truth) / COUNT(*), 3) combined_correct
FROM x GROUP BY 1, 2 ORDER BY 1, 2
