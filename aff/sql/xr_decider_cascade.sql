-- A whole-name-first matcher, with and without ORCID. Whole-name pick: the organisation whose whole ROR name is the
-- longest found word for word in the string, when exactly one organisation has it (xr_ambig.sql). Instances with a
-- text candidate and a Dimensions answer, as in the decider summaries. Agreement = the same ROR ID as Dimensions.
WITH d AS (
  SELECT 'dim' run, raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT 'cr_orcid', raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT 'cr_surname', raw, ror_truth, n_text, n_top, top_ror, orcid_pick FROM `your-project.your_dataset.xr_decider_cr`
), x AS (
  SELECT d.run, d.ror_truth, d.orcid_pick, IF(d.n_top = 1, d.top_ror, NULL) text_pick, a.cls,
    IF(a.top_rors IS NOT NULL AND STRPOS(a.top_rors, '|') = 0, a.top_rors, NULL) name_pick
  FROM d JOIN `your-project.your_dataset.xr_ambig` a USING (raw)
  WHERE d.ror_truth IS NOT NULL AND d.n_text > 0
)
SELECT run, COUNT(*) instances,
  ROUND(COUNTIF(name_pick IS NOT NULL) / COUNT(*), 3) name_decides,
  ROUND(SAFE_DIVIDE(COUNTIF(name_pick = ror_truth), COUNTIF(name_pick IS NOT NULL)), 3) name_acc,
  ROUND(COUNTIF(cls = 'one' AND name_pick = ror_truth) / NULLIF(COUNTIF(cls = 'one'), 0), 3) one_name_acc,
  ROUND(COUNTIF(text_pick = ror_truth) / COUNT(*), 3) text_only,
  ROUND(COUNTIF(name_pick = ror_truth) / COUNT(*), 3) name_only,
  ROUND(COUNTIF(COALESCE(name_pick, text_pick) = ror_truth) / COUNT(*), 3) name_then_text,
  ROUND(COUNTIF(COALESCE(name_pick, orcid_pick, text_pick) = ror_truth) / COUNT(*), 3) name_orcid_text,
  ROUND(COUNTIF(COALESCE(IF(cls = 'one', name_pick, NULL), orcid_pick, name_pick, text_pick) = ror_truth) / COUNT(*), 3) one_name_orcid_name_text,
  ROUND(COUNTIF(COALESCE(orcid_pick, name_pick, text_pick) = ror_truth) / COUNT(*), 3) orcid_name_text,
  -- strings with no single whole name: what ORCID adds there
  COUNTIF(name_pick IS NULL) no_name, ROUND(COUNTIF(name_pick IS NULL AND text_pick = ror_truth) / NULLIF(COUNTIF(name_pick IS NULL), 0), 3) no_name_text,
  ROUND(COUNTIF(name_pick IS NULL AND orcid_pick IS NOT NULL) / NULLIF(COUNTIF(name_pick IS NULL), 0), 3) no_name_orcid_decides,
  ROUND(SAFE_DIVIDE(COUNTIF(name_pick IS NULL AND orcid_pick = ror_truth), COUNTIF(name_pick IS NULL AND orcid_pick IS NOT NULL)), 3) no_name_orcid_acc,
  ROUND(COUNTIF(name_pick IS NULL AND COALESCE(orcid_pick, text_pick) = ror_truth) / NULLIF(COUNTIF(name_pick IS NULL), 0), 3) no_name_orcid_text,
  -- where the whole name and ORCID both decide and differ
  COUNTIF(name_pick IS NOT NULL AND orcid_pick IS NOT NULL AND name_pick != orcid_pick) differ,
  ROUND(SAFE_DIVIDE(COUNTIF(name_pick IS NOT NULL AND orcid_pick IS NOT NULL AND name_pick != orcid_pick AND name_pick = ror_truth), COUNTIF(name_pick IS NOT NULL AND orcid_pick IS NOT NULL AND name_pick != orcid_pick)), 3) differ_name_agrees,
  ROUND(SAFE_DIVIDE(COUNTIF(name_pick IS NOT NULL AND orcid_pick IS NOT NULL AND name_pick != orcid_pick AND orcid_pick = ror_truth), COUNTIF(name_pick IS NOT NULL AND orcid_pick IS NOT NULL AND name_pick != orcid_pick)), 3) differ_orcid_agrees
FROM x GROUP BY 1 ORDER BY 1
