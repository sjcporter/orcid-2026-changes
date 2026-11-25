-- Per institution or Member Portal system: fates of its employment and education pairs over both transitions.
SELECT f.src client_id, ANY_VALUE(s.source_name) source_name, ANY_VALUE(s.bucket) bucket, COUNT(*) pairs,
  COUNTIF(f.fate LIKE 'kept%') kept, COUNTIF(f.fate = 'recreated, identical') recreated_identical,
  COUNTIF(f.fate = 'recreated, changed') recreated_changed, COUNTIF(f.fate = 'recreated, changed' AND f.end_date_added) recreated_end_added,
  COUNTIF(f.fate LIKE 'removed%') removed, COUNTIF(f.fate = 'removed, other organisation left from source') removed_other_org_left,
  COUNTIF(f.fate = 'record not public') record_gone, COUNTIF(f.had_duplicates) pairs_with_duplicates, SUM(f.n_entries) entries,
  COUNTIF(f.yr = 2024 AND f.fate LIKE 'recreated%') recreated_24, COUNTIF(f.yr = 2025 AND f.fate LIKE 'recreated%') recreated_25,
  COUNTIF(f.yr = 2024) pairs_24, COUNTIF(f.yr = 2025) pairs_25
FROM `your-project.your_dataset.orcid_aff_pair_fate` f
JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = f.src
WHERE NOT f.self_asserted AND s.bucket IN ("Institution's own system", 'ORCID Member Portal', 'National system')
GROUP BY 1 HAVING pairs >= 500 ORDER BY pairs DESC
