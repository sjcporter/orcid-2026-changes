-- Can ORCID decide between organisations that the text of an affiliation string fits equally well?
-- Crossref version of xr_decider.sql for authors who carry an ORCID iD in Crossref, with the surname also matching the record
-- (a guard against iDs attached to the wrong author). Sample: about 2% of distinct strings. The answer is Dimensions'
-- resolution of the same string for the same-surname author on the same DOI (NULL where Dimensions has none).
-- Text candidates: every ROR with a distinctive name word or acronym in the string (see xr_text.sql), not in conflict
-- with the string's country. Text score = distinctive name words matched, plus 0.5 if the city matches.
-- ORCID set for an instance: dated employment or education RORs (xr_orcid_emp) and the ROR of an institution's
-- system that wrote this DOI (xr_orcid_inst_doi). "Family" also accepts a ROR parent, child or related organisation.
CREATE TEMP FUNCTION words(s STRING) AS (
  ARRAY(SELECT DISTINCT w FROM UNNEST(REGEXP_EXTRACT_ALL(REGEXP_REPLACE(NORMALIZE(LOWER(s), NFD), r'\p{M}', ''), r'\p{L}+')) w)
);
CREATE TEMP FUNCTION clean(s STRING) AS (TRIM(REGEXP_REPLACE(REGEXP_REPLACE(NORMALIZE(s, NFD), r'\p{M}', ''), r'[^a-z. \']', ' ')));
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_decider_cro` AS
WITH nm AS (
  SELECT id, REGEXP_REPLACE(NORMALIZE(family, NFD), r'\p{M}', '') fam FROM `your-project.your_dataset.xr_orcid_name`
), cr AS (  -- Crossref instances where the author carries an ORCID iD and the surname matches the ORCID record
  SELECT DISTINCT c.doi, c.yr year, c.orcid id, c.raw, nm.fam
  FROM `your-project.your_dataset.xr_cr` c
  JOIN nm ON nm.id = c.orcid AND nm.fam = REGEXP_REPLACE(NORMALIZE(c.family, NFD), r'\p{M}', '')
  WHERE MOD(ABS(FARM_FINGERPRINT(c.raw)), 50) = 0
), g AS (SELECT id grid_id, REGEXP_EXTRACT(external_ids.ror.preferred, r'([0-9a-z]{9})$') ror FROM `dimensions-ai.data_analytics.organizations`),
dim AS (  -- answer: Dimensions' resolution of the same string for the author with the same surname on the same DOI
  SELECT LOWER(p.doi) doi, REGEXP_REPLACE(NORMALIZE(LOWER(TRIM(a.last_name)), NFD), r'\p{M}', '') fam,
    TRIM(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(aa.raw_affiliation), r'\s+', ' '), r'[\s.,;]+$', '')) raw, ANY_VALUE(g.ror) ror
  FROM `dimensions-ai.data_analytics.publications` p, UNNEST(p.authors) a, UNNEST(a.affiliations_address) aa
  JOIN g ON g.grid_id = aa.grid_id
  WHERE LOWER(p.doi) IN (SELECT doi FROM cr) AND g.ror IS NOT NULL
  GROUP BY 1, 2, 3
), inst AS (
  SELECT cr.doi, cr.year, cr.id, cr.raw, dim.ror ror_truth FROM cr LEFT JOIN dim USING (doi, fam, raw)
), s AS (SELECT DISTINCT raw FROM inst),
sw AS (SELECT raw, w FROM s, UNNEST(words(raw)) w),
nh AS (
  SELECT sw.raw, rw.ror, COUNT(DISTINCT sw.w) n_words FROM sw JOIN `your-project.your_dataset.xr_ror_words` rw ON rw.w = sw.w AND rw.kind = 'name'
  GROUP BY 1, 2
), ph AS (
  SELECT DISTINCT sw.raw, rw.ror FROM sw JOIN `your-project.your_dataset.xr_ror_words` rw ON rw.w = sw.w AND rw.kind = 'place'
), ctry AS (
  SELECT s.raw, ARRAY_AGG(DISTINCT c.cc IGNORE NULLS) ccs FROM s, UNNEST([STRUCT(ARRAY_REVERSE(SPLIT(s.raw, ',')) AS parts)]) x
  LEFT JOIN `your-project.your_dataset.xr_country_names` c ON c.nm IN (clean(x.parts[SAFE_OFFSET(0)]), clean(x.parts[SAFE_OFFSET(1)]))
  GROUP BY 1
), tc AS (  -- text candidates with scores
  SELECT nh.raw, nh.ror, nh.n_words + IF(ph.ror IS NOT NULL, 0.5, 0) score
  FROM nh LEFT JOIN ph USING (raw, ror) LEFT JOIN ctry USING (raw)
  WHERE ARRAY_LENGTH(ctry.ccs) = 0 OR EXISTS (SELECT 1 FROM UNNEST(ctry.ccs) x JOIN `your-project.your_dataset.xr_ror_country` rc ON rc.cc = x AND rc.ror = nh.ror)
), tcr AS (
  SELECT *, RANK() OVER (PARTITION BY raw ORDER BY score DESC) rk, COUNT(*) OVER (PARTITION BY raw) n_text FROM tc
), top AS (
  SELECT raw, ANY_VALUE(ror) top_ror, COUNT(*) n_top, ANY_VALUE(n_text) n_text FROM tcr WHERE rk = 1 GROUP BY 1
), rel AS (
  SELECT r.id a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b FROM `your-project.ror.records` r, UNNEST(r.relationships) x
), orc AS (  -- ORCID RORs per instance
  SELECT DISTINCT i.doi, i.id, e.ror FROM inst i JOIN `your-project.your_dataset.xr_orcid_emp` e
    ON e.id = i.id AND (e.sy IS NULL OR e.sy <= i.year) AND (e.ey IS NULL OR e.ey >= i.year)
  UNION DISTINCT
  SELECT i.doi, i.id, d.ror FROM inst i JOIN `your-project.your_dataset.xr_orcid_inst_doi` d ON d.id = i.id AND d.doi = i.doi
), pick AS (  -- text candidates that the ORCID set confirms, directly or through a ROR relationship
  SELECT i.doi, i.id, i.raw,
    ARRAY_AGG(DISTINCT IF(o.ror = t.ror, t.ror, NULL) IGNORE NULLS) direct,
    ARRAY_AGG(DISTINCT IF(o.ror = t.ror OR rel.a IS NOT NULL, t.ror, NULL) IGNORE NULLS) family
  FROM inst i JOIN tcr t ON t.raw = i.raw JOIN orc o ON o.doi = i.doi AND o.id = i.id
  LEFT JOIN rel ON rel.a = t.ror AND rel.b = o.ror
  GROUP BY 1, 2, 3
)
SELECT i.*, IFNULL(tp.n_text, 0) n_text, tp.n_top, tp.top_ror,
  (SELECT COUNT(*) FROM orc o WHERE o.doi = i.doi AND o.id = i.id) n_orcid,
  EXISTS (SELECT 1 FROM tcr t WHERE t.raw = i.raw AND t.ror = i.ror_truth) truth_in_text,
  IF(ARRAY_LENGTH(p.direct) = 1, p.direct[OFFSET(0)], NULL) orcid_pick,
  IF(ARRAY_LENGTH(p.family) = 1, p.family[OFFSET(0)], NULL) orcid_family_pick
FROM inst i LEFT JOIN top tp USING (raw) LEFT JOIN pick p USING (doi, id, raw)
