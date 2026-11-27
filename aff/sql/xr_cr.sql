-- Crossref side (7 November 2026 release): every affiliation string on every author, with the author's ORCID iD
-- (bare), surname, and how many authors on the same DOI share that surname. DOIs lower-cased; strings normalised
-- as for Dimensions.
-- Surname uniqueness (n_same_family) counts every author on the DOI by accent-stripped, lower-cased surname. Authors
-- with no family name but a full name in `name` count under the last word of that name; they are not output, as they
-- have no family name to match on. n_same_family_v1 is the earlier count (exact lower-cased surname, family names only).
CREATE TEMP FUNCTION fkey(s STRING) AS (REGEXP_REPLACE(NORMALIZE(LOWER(TRIM(s)), NFD), r'\p{M}', ''));
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_cr` AS
WITH a AS (
  SELECT LOWER(c.doi) doi,
    c.issued.date_parts[SAFE_OFFSET(0)] yr, pos, LOWER(TRIM(au.family)) family,
    REGEXP_EXTRACT(au.orcid, r'(\d{4}-\d{4}-\d{4}-\d{3}[\dX])') orcid, au.affiliation aff,
    IF(au.family IS NOT NULL AND TRIM(au.family) != '', fkey(au.family),
       ARRAY_REVERSE(REGEXP_EXTRACT_ALL(fkey(au.name), r'\p{L}+'))[SAFE_OFFSET(0)]) fam_key
  FROM `your-project.crossref.metadata` c, UNNEST(c.author) au WITH OFFSET pos
  WHERE (au.family IS NOT NULL AND TRIM(au.family) != '') OR au.name IS NOT NULL
), b AS (
  SELECT *,
    COUNT(*) OVER (PARTITION BY doi, fam_key) n_same_family,
    COUNTIF(family IS NOT NULL) OVER (PARTITION BY doi, family) n_same_family_v1
  FROM a
)
SELECT doi, yr, pos, family, orcid, n_same_family, n_same_family_v1, ARRAY_LENGTH(aff) n_aff,
  TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(f.name), r'\s+', ' '), r'[\s.,;]+$', '')) raw,
  (SELECT REGEXP_EXTRACT(i.id, r'([0-9a-z]{9})$') FROM UNNEST(f.id) i WHERE UPPER(i.id_type) = 'ROR' LIMIT 1) cr_ror
FROM b, UNNEST(aff) f
WHERE family IS NOT NULL AND f.name IS NOT NULL AND TRIM(f.name) != ''
