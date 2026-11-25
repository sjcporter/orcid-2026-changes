-- How old are each system's entries at each snapshot? Systems that recreate entries often hold only young entries.
WITH a AS (
  SELECT '2024' yr, src, section, DATE(SUBSTR(cd,1,10)) c FROM `your-project.your_dataset.orcid_aff_2024`
  UNION ALL SELECT '2025', src, section, DATE(SUBSTR(cd,1,10)) FROM `your-project.your_dataset.orcid_aff_2025`
  UNION ALL SELECT '2026', src, section, DATE(SUBSTR(cd,1,10)) FROM `your-project.your_dataset.orcid_aff_2026`),
snap AS (SELECT yr, MAX(c) s FROM a GROUP BY yr)
SELECT a.src, a.yr, snap.s snapshot, COUNT(*) n,
  ROUND(100*COUNTIF(DATE_DIFF(s,c,DAY)<=7)/COUNT(*),1) pct_7d,
  ROUND(100*COUNTIF(DATE_DIFF(s,c,DAY)<=30)/COUNT(*),1) pct_30d,
  ROUND(100*COUNTIF(DATE_DIFF(s,c,DAY)<=365)/COUNT(*),1) pct_1y,
  APPROX_QUANTILES(DATE_DIFF(s,c,DAY),2)[OFFSET(1)] median_age_days,
  COUNT(DISTINCT c) distinct_days
FROM a JOIN snap USING (yr)
WHERE a.section IN ('employment','education') AND a.src IN ('APP-CKV92M0O9MPKINNV','0000-0002-4407-7742','APP-QSI3BOI1FRJ3MSVC','APP-UKGLZX5LPGYOXYX5','APP-NMZQ8IRMT5FHJB03','APP-CBBRNA08S76OOD5I')
GROUP BY 1,2,3 ORDER BY 1,2
