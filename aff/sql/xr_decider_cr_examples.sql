-- Examples where the methods disagree, Crossref surname-only run (instances with a Dimensions answer).
-- Cases: A = several candidates, one scores highest, text and ORCID differ (split by who matches Dimensions);
-- B = several candidates tied at the top, ORCID pick differs from Dimensions; C = one text candidate, ORCID differs from Dimensions.
WITH n AS (
  SELECT id ror, (SELECT value FROM UNNEST(names) WHERE 'ror_display' IN UNNEST(types) LIMIT 1) name,
    (SELECT geonames_details.country_code FROM UNNEST(locations) LIMIT 1) cc
  FROM `your-project.ror.records`
), d AS (
  SELECT *,
    CASE
      WHEN n_top = 1 AND n_text > 1 AND orcid_pick IS NOT NULL AND top_ror != orcid_pick THEN
        CASE WHEN orcid_pick = ror_truth THEN 'A1 unique top, ORCID right, text wrong'
             WHEN top_ror = ror_truth THEN 'A2 unique top, text right, ORCID wrong'
             ELSE 'A3 unique top, both wrong' END
      WHEN n_top > 1 AND orcid_pick IS NOT NULL AND orcid_pick != ror_truth THEN 'B tied, ORCID wrong'
      WHEN n_text = 1 AND orcid_pick IS NOT NULL AND orcid_pick != ror_truth THEN 'C one candidate, ORCID wrong'
    END k
  FROM `your-project.your_dataset.xr_decider_cr` WHERE ror_truth IS NOT NULL
)
SELECT k, raw, n_text, n_top,
  CONCAT(tn.name, ' (', tn.cc, ')') text_pick, CONCAT(onm.name, ' (', onm.cc, ')') orcid_pick, CONCAT(dn.name, ' (', dn.cc, ')') dimensions,
  orcid_family_pick = ror_truth family_fixes
FROM d LEFT JOIN n tn ON tn.ror = d.top_ror AND d.n_top = 1 LEFT JOIN n onm ON onm.ror = d.orcid_pick LEFT JOIN n dn ON dn.ror = d.ror_truth
WHERE k IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY k ORDER BY FARM_FINGERPRINT(CONCAT(raw, doi))) <= 8
ORDER BY k
