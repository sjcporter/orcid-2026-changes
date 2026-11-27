-- Where text + ORCID does not agree with Dimensions: why. Instances with a text candidate and a Dimensions answer, as in
-- the decider summaries. Every instance has an ORCID iD linked to the author by construction.
WITH d AS (
  SELECT 'dim' run, ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT 'cr_orcid', ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT 'cr_surname', ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider_cr`
), pc AS (
  SELECT DISTINCT REGEXP_EXTRACT(r.id, r'([0-9a-z]{9})$') a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b
  FROM `your-project.ror.records` r, UNNEST(r.relationships) x WHERE x.type IN ('parent', 'child')
), x AS (
  SELECT run, CASE
    WHEN COALESCE(orcid_pick, IF(n_top = 1, top_ror, NULL)) = ror_truth THEN '1 agrees'
    WHEN orcid_pick IS NOT NULL AND EXISTS (SELECT 1 FROM pc WHERE pc.a = orcid_pick AND pc.b = ror_truth) THEN '2 ORCID decided: parent or child of Dimensions\' choice'
    WHEN orcid_pick IS NOT NULL THEN '3 ORCID decided: a different organisation'
    WHEN n_orcid = 0 THEN IF(n_top = 1, '4 no ORCID affiliation for the year: matcher\'s pick differs', '5 no ORCID affiliation for the year: matcher tied')
    ELSE IF(n_top = 1, '6 ORCID affiliations, none or several among candidates: matcher\'s pick differs', '7 ORCID affiliations, none or several among candidates: matcher tied') END bucket
  FROM d WHERE ror_truth IS NOT NULL AND n_text > 0
)
SELECT run, bucket, COUNT(*) instances, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY run), 3) share FROM x GROUP BY 1, 2 ORDER BY 1, 2
