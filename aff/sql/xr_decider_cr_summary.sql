-- Crossref surname-only run, instances with a Dimensions answer only. Text alone vs ORCID as the decider, by how ambiguous the text is. Accuracy is against Dimensions' resolution.
-- text pick = the single top-scoring text candidate (none if tied); combined = ORCID pick if any, else text pick.
SELECT
  CASE WHEN n_text = 0 THEN '0 no text candidate' WHEN n_text = 1 THEN '1 one text candidate'
       WHEN n_top = 1 THEN '2 several, one scores highest' ELSE '3 several, tied at the top' END text_case,
  COUNT(*) instances, ROUND(AVG(n_text), 1) avg_text_cands,
  ROUND(COUNTIF(truth_in_text) / COUNT(*), 3) truth_among_text,
  ROUND(COUNTIF(n_orcid > 0) / COUNT(*), 3) has_orcid_ror,
  ROUND(COUNTIF(n_top = 1) / COUNT(*), 3) text_decides, ROUND(SAFE_DIVIDE(COUNTIF(n_top = 1 AND top_ror = ror_truth), COUNTIF(n_top = 1)), 3) text_acc,
  ROUND(COUNTIF(orcid_pick IS NOT NULL) / COUNT(*), 3) orcid_decides, ROUND(SAFE_DIVIDE(COUNTIF(orcid_pick = ror_truth), COUNTIF(orcid_pick IS NOT NULL)), 3) orcid_acc,
  ROUND(COUNTIF(orcid_family_pick IS NOT NULL) / COUNT(*), 3) orcid_family_decides, ROUND(SAFE_DIVIDE(COUNTIF(orcid_family_pick = ror_truth), COUNTIF(orcid_family_pick IS NOT NULL)), 3) orcid_family_acc,
  ROUND(COUNTIF(n_top = 1 AND orcid_pick IS NOT NULL AND top_ror != orcid_pick) / COUNT(*), 3) disagree,
  ROUND(SAFE_DIVIDE(COUNTIF(n_top = 1 AND orcid_pick IS NOT NULL AND top_ror != orcid_pick AND orcid_pick = ror_truth),
                    COUNTIF(n_top = 1 AND orcid_pick IS NOT NULL AND top_ror != orcid_pick)), 3) orcid_right_when_disagree,
  ROUND(COUNTIF(COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) IS NOT NULL) / COUNT(*), 3) combined_decides,
  ROUND(SAFE_DIVIDE(COUNTIF(COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) = ror_truth), COUNTIF(COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) IS NOT NULL)), 3) combined_acc
FROM `your-project.your_dataset.xr_decider_cr` WHERE ror_truth IS NOT NULL GROUP BY 1 ORDER BY 1
