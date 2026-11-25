-- Every non-self source of affiliation entries across the three snapshots, with entry counts per snapshot.
-- user_sourced = the source is an ORCID iD other than the record's own (an individual or an institution acting through a personal iD).
WITH a AS (
  SELECT '2024' yr, src, src_name, src LIKE 'APP-%' is_client FROM `your-project.your_dataset.orcid_aff_2024` WHERE NOT self_asserted
  UNION ALL SELECT '2025', src, src_name, src LIKE 'APP-%' FROM `your-project.your_dataset.orcid_aff_2025` WHERE NOT self_asserted
  UNION ALL SELECT '2026', src, src_name, src LIKE 'APP-%' FROM `your-project.your_dataset.orcid_aff_2026` WHERE NOT self_asserted
)
SELECT src client_id, ARRAY_AGG(src_name ORDER BY yr DESC LIMIT 1)[OFFSET(0)] source_name, NOT ANY_VALUE(is_client) user_sourced,
  COUNTIF(yr = '2024') n_2024, COUNTIF(yr = '2025') n_2025, COUNTIF(yr = '2026') n_2026
FROM a GROUP BY 1
