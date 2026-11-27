-- Where the whole-name-first matcher with ORCID (whole name, else ORCID, else the best word score; xr_decider_cascade.sql)
-- does not agree with Dimensions: why. Instances with a text candidate and a Dimensions answer. Every instance has an
-- ORCID iD linked to the author by construction.
WITH d AS (
  SELECT 'dim' run, raw, ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT 'cr_orcid', raw, ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT 'cr_surname', raw, ror_truth, n_text, n_top, top_ror, orcid_pick, n_orcid FROM `your-project.your_dataset.xr_decider_cr`
), pc AS (
  SELECT DISTINCT REGEXP_EXTRACT(r.id, r'([0-9a-z]{9})$') a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b
  FROM `your-project.ror.records` r, UNNEST(r.relationships) x WHERE x.type IN ('parent', 'child')
), x AS (
  SELECT d.*, IF(d.n_top = 1, d.top_ror, NULL) text_pick,
    IF(a.top_rors IS NOT NULL AND STRPOS(a.top_rors, '|') = 0, a.top_rors, NULL) name_pick
  FROM d JOIN `your-project.your_dataset.xr_ambig` a USING (raw)
  WHERE d.ror_truth IS NOT NULL AND d.n_text > 0
), b AS (
  SELECT run, CASE
    WHEN COALESCE(name_pick, orcid_pick, text_pick) = ror_truth THEN IF(name_pick IS NOT NULL, '1 agrees: whole name', IF(orcid_pick IS NOT NULL, '2 agrees: ORCID', '3 agrees: word score'))
    WHEN name_pick IS NOT NULL THEN IF(EXISTS (SELECT 1 FROM pc WHERE pc.a = name_pick AND pc.b = ror_truth), '4 whole name: parent or child of Dimensions\' choice', '5 whole name: a different organisation')
    WHEN orcid_pick IS NOT NULL THEN '6 ORCID decided: a different organisation'
    WHEN n_orcid = 0 THEN '7 no ORCID affiliation for the year'
    ELSE '8 ORCID affiliations, but none or several among the candidates' END bucket
  FROM x
)
SELECT run, bucket, COUNT(*) instances, ROUND(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY run), 3) share FROM b GROUP BY 1, 2 ORDER BY 1, 2
