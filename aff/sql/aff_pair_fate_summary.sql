-- Pair fates by source group, section and transition, with how often duplicates and end dates were involved.
SELECT IF(f.self_asserted, 'Researcher', IFNULL(s.bucket, 'Other')) bucket, f.section, f.yr from_yr, f.fate,
  COUNT(*) pairs, COUNTIF(f.had_duplicates) pairs_with_duplicates, COUNTIF(f.end_date_added) end_date_added,
  COUNTIF(f.org_id_changed) org_id_changed
FROM `your-project.your_dataset.orcid_aff_pair_fate` f
LEFT JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = f.src
GROUP BY 1, 2, 3, 4 ORDER BY 1, 2, 3, 4
