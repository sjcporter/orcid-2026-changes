-- Score each distinct (candidate ROR, string) pair with the text test from xr_text.sql. The country in a string is
-- read from its last or second-last comma-separated part.
CREATE TEMP FUNCTION words(s STRING) AS (
  ARRAY(SELECT DISTINCT w FROM UNNEST(REGEXP_EXTRACT_ALL(REGEXP_REPLACE(NORMALIZE(LOWER(s), NFD), r'\p{M}', ''), r'\p{L}+')) w)
);
CREATE TEMP FUNCTION clean(s STRING) AS (TRIM(REGEXP_REPLACE(REGEXP_REPLACE(NORMALIZE(s, NFD), r'\p{M}', ''), r'[^a-z. \']', ' ')));
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_score` AS
WITH p AS (SELECT DISTINCT cand_ror ror, raw FROM `your-project.your_dataset.xr_cand`),
pw AS (SELECT p.ror, p.raw, w FROM p, UNNEST(words(p.raw)) w),
hits AS (
  SELECT pw.ror, pw.raw, LOGICAL_OR(rw.kind = 'name') name_hit, LOGICAL_OR(rw.kind = 'place') place_hit
  FROM pw JOIN `your-project.your_dataset.xr_ror_words` rw ON rw.ror = pw.ror AND rw.w = pw.w GROUP BY 1, 2
), seg AS (
  SELECT ror, raw, ARRAY_REVERSE(SPLIT(raw, ',')) parts FROM p
), ctry AS (
  SELECT s.ror, s.raw, ARRAY_AGG(DISTINCT c.cc IGNORE NULLS) ccs
  FROM seg s LEFT JOIN `your-project.your_dataset.xr_country_names` c
    ON c.nm IN (clean(s.parts[SAFE_OFFSET(0)]), clean(s.parts[SAFE_OFFSET(1)]))
  GROUP BY 1, 2
)
SELECT p.ror, p.raw, IFNULL(h.name_hit, FALSE) name_hit, IFNULL(h.place_hit, FALSE) place_hit,
  ARRAY_LENGTH(c.ccs) > 0 AND NOT EXISTS (SELECT 1 FROM UNNEST(c.ccs) x JOIN `your-project.your_dataset.xr_ror_country` rc ON rc.cc = x AND rc.ror = p.ror) country_conflict
FROM p LEFT JOIN hits h USING (ror, raw) LEFT JOIN ctry c USING (ror, raw)
