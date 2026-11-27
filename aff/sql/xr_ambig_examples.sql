-- Example genuinely ambiguous strings (one name, several organisations) from the three decider runs, with the
-- organisations that share the name, their cities, ORCID's pick and Dimensions' answer.
WITH d AS (
  SELECT raw, ror_truth, orcid_pick FROM `your-project.your_dataset.xr_decider`
  UNION ALL SELECT raw, ror_truth, orcid_pick FROM `your-project.your_dataset.xr_decider_cro`
  UNION ALL SELECT raw, ror_truth, orcid_pick FROM `your-project.your_dataset.xr_decider_cr`
), r AS (
  SELECT REGEXP_EXTRACT(id, r'([0-9a-z]{9})$') ror,
    (SELECT n.value FROM UNNEST(names) n WHERE 'ror_display' IN UNNEST(n.types) LIMIT 1) nm,
    locations[SAFE_OFFSET(0)].geonames_details.name city, locations[SAFE_OFFSET(0)].geonames_details.country_code cc
  FROM `your-project.ror.records`
)
SELECT a.top_phrase, a.place_settles, d.raw,
  (SELECT STRING_AGG(CONCAT(r.nm, ' (', r.city, ', ', r.cc, ')'), ' | ') FROM UNNEST(SPLIT(a.top_rors, '|')) x JOIN r ON r.ror = x) same_name,
  (SELECT CONCAT(nm, ' (', city, ')') FROM r WHERE r.ror = d.orcid_pick) orcid_pick,
  (SELECT CONCAT(nm, ' (', city, ')') FROM r WHERE r.ror = d.ror_truth) dimensions
FROM d JOIN `your-project.your_dataset.xr_ambig` a USING (raw)
WHERE a.cls = 'ambiguous' AND d.orcid_pick IS NOT NULL AND d.orcid_pick IN UNNEST(SPLIT(a.top_rors, '|'))
QUALIFY ROW_NUMBER() OVER (PARTITION BY a.top_phrase ORDER BY LENGTH(d.raw)) = 1
ORDER BY a.place_settles, a.top_phrase
