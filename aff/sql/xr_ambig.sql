-- Genuine ambiguity versus several organisations named. For each sampled string in the three decider runs, find the
-- text candidates (same rules as xr_decider.sql, including the country check) whose whole name or label (two words or
-- more, no digits; acronyms are not used; active ROR records only) appears word for word in the string. Take the longest such name in the string.
--   ambiguous: two or more organisations share that longest name, so the same name points to several organisations
--              (e.g. "trinity college" or "university of newcastle" with no country to settle it).
--              place_settles: exactly one of them is in a city named in the string (ROR's city only).
--   several:   names of two or more organisations appear, but the longest belongs to one of them (e.g. a hospital and
--              the university it belongs to). The author may mean all of them.
--   one:       exactly one organisation's whole name is in the string.   none: no whole name is.
CREATE TEMP FUNCTION words(s STRING) AS (
  ARRAY(SELECT DISTINCT w FROM UNNEST(REGEXP_EXTRACT_ALL(REGEXP_REPLACE(NORMALIZE(LOWER(s), NFD), r'\p{M}', ''), r'\p{L}+')) w)
);
CREATE TEMP FUNCTION seq(s STRING) AS (
  REGEXP_EXTRACT_ALL(REGEXP_REPLACE(NORMALIZE(LOWER(s), NFD), r'\p{M}', ''), r'\p{L}+')
);
CREATE TEMP FUNCTION clean(s STRING) AS (TRIM(REGEXP_REPLACE(REGEXP_REPLACE(NORMALIZE(s, NFD), r'\p{M}', ''), r'[^a-z. \']', ' ')));
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_ambig` AS
WITH s AS (
  SELECT DISTINCT raw FROM (
    SELECT raw FROM `your-project.your_dataset.xr_decider` UNION ALL
    SELECT raw FROM `your-project.your_dataset.xr_decider_cro` UNION ALL
    SELECT raw FROM `your-project.your_dataset.xr_decider_cr`)
), sw AS (SELECT raw, w FROM s, UNNEST(words(raw)) w),
nh AS (
  SELECT sw.raw, rw.ror, STRING_AGG(DISTINCT sw.w ORDER BY sw.w) wset
  FROM sw JOIN `your-project.your_dataset.xr_ror_words` rw ON rw.w = sw.w AND rw.kind = 'name'
  GROUP BY 1, 2
), ph AS (
  SELECT DISTINCT sw.raw, rw.ror FROM sw JOIN `your-project.your_dataset.xr_ror_words` rw ON rw.w = sw.w AND rw.kind = 'place'
), ctry AS (
  SELECT s.raw, ARRAY_AGG(DISTINCT c.cc IGNORE NULLS) ccs FROM s, UNNEST([STRUCT(ARRAY_REVERSE(SPLIT(s.raw, ',')) AS parts)]) x
  LEFT JOIN `your-project.your_dataset.xr_country_names` c ON c.nm IN (clean(x.parts[SAFE_OFFSET(0)]), clean(x.parts[SAFE_OFFSET(1)]))
  GROUP BY 1
), tc AS (
  SELECT nh.* FROM nh LEFT JOIN ctry USING (raw)
  WHERE ARRAY_LENGTH(ctry.ccs) = 0 OR EXISTS (SELECT 1 FROM UNNEST(ctry.ccs) x JOIN `your-project.your_dataset.xr_ror_country` rc ON rc.cc = x AND rc.ror = nh.ror)
), rn AS (  -- whole names and labels, as normalised phrases
  SELECT DISTINCT r.id ror, ARRAY_TO_STRING(seq(n.value), ' ') ph
  FROM `your-project.ror.records` r, UNNEST(r.names) n
  WHERE r.status = 'active' AND NOT 'acronym' IN UNNEST(n.types) AND NOT REGEXP_CONTAINS(n.value, r'\d') AND ARRAY_LENGTH(seq(n.value)) >= 2
), fullc AS (  -- candidates with a whole name in the string; keep each one's longest
  SELECT tc.raw, tc.ror, MAX(ARRAY_LENGTH(SPLIT(rn.ph, ' '))) len, ARRAY_AGG(rn.ph ORDER BY LENGTH(rn.ph) DESC LIMIT 1)[OFFSET(0)] ph
  FROM tc JOIN rn ON rn.ror = tc.ror
  WHERE STRPOS(CONCAT(' ', ARRAY_TO_STRING(seq(tc.raw), ' '), ' '), CONCAT(' ', rn.ph, ' ')) > 0
  GROUP BY 1, 2
), lg AS (SELECT * FROM fullc QUALIFY RANK() OVER (PARTITION BY raw ORDER BY len DESC) = 1),
lga AS (SELECT lg.raw, COUNT(*) n_top, COUNT(DISTINCT lg.ph) n_ph, COUNT(p.ror) n_top_place, ANY_VALUE(lg.ph) top_phrase, STRING_AGG(lg.ror, '|' ORDER BY lg.ror) top_rors FROM lg LEFT JOIN ph p ON p.raw = lg.raw AND p.ror = lg.ror GROUP BY 1),
fa AS (SELECT raw, COUNT(*) n_full FROM fullc GROUP BY 1)
SELECT s.raw,
  CASE WHEN lga.n_top > 1 AND lga.n_ph = 1 THEN 'ambiguous' WHEN fa.n_full > 1 THEN 'several' WHEN fa.n_full = 1 THEN 'one' ELSE 'none' END cls,
  IF(lga.n_top > 1 AND lga.n_ph = 1, lga.n_top_place = 1, NULL) place_settles, lga.n_top, lga.top_phrase, lga.top_rors
FROM s LEFT JOIN lga USING (raw) LEFT JOIN fa USING (raw)
