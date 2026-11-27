-- Entries per researcher-organisation pair from each system, by snapshot (duplicates vs one entry each).
WITH a AS (
  SELECT '2024' yr, * FROM `your-project.your_dataset.orcid_aff_2024`
  UNION ALL SELECT '2025', * FROM `your-project.your_dataset.orcid_aff_2025`
  UNION ALL SELECT '2026', * FROM `your-project.your_dataset.orcid_aff_2026`)
SELECT src, yr, COUNT(*) entries, COUNT(DISTINCT id) researchers,
  COUNT(DISTINCT CONCAT(id, section, LOWER(TRIM(org)))) id_org_pairs,
  COUNT(DISTINCT CONCAT(id, section, LOWER(TRIM(org)), IFNULL(CAST(sy AS STRING),''), IFNULL(CAST(ey AS STRING),''))) distinct_content
FROM a WHERE section IN ('employment','education') AND src IN ('APP-CKV92M0O9MPKINNV','0000-0002-4407-7742','APP-QSI3BOI1FRJ3MSVC','APP-UKGLZX5LPGYOXYX5','APP-NMZQ8IRMT5FHJB03','APP-CBBRNA08S76OOD5I')
GROUP BY 1,2 ORDER BY 1,2
