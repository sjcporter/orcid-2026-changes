-- Text test: does an affiliation string plausibly belong to a ROR organisation?
-- Words are runs of letters, lower-cased with accents removed. A ROR's distinctive words are the words in any of its
-- names, labels or acronyms that appear in the names of at most 300 organisations (so "university" or "institute" do
-- not count; acronyms always do), plus its city. A string "definitely does not belong" when it shares
-- no distinctive word or place with the organisation, or when it names a different country and not the organisation's own.
CREATE TEMP FUNCTION words(s STRING) AS (
  ARRAY(SELECT DISTINCT w FROM UNNEST(REGEXP_EXTRACT_ALL(REGEXP_REPLACE(NORMALIZE(LOWER(s), NFD), r'\p{M}', ''), r'\p{L}+')) w)
);
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_ror_words` AS
WITH r AS (SELECT * FROM `your-project.ror.records`),
nw AS (
  SELECT r.id ror, w, 'acronym' IN UNNEST(n.types) is_acr FROM r, UNNEST(r.names) n, UNNEST(words(n.value)) w
), df AS (SELECT w, COUNT(DISTINCT ror) df FROM nw WHERE NOT is_acr GROUP BY 1)
SELECT DISTINCT nw.ror, nw.w, 'name' kind FROM nw JOIN df USING (w) WHERE nw.is_acr OR (df.df <= 300 AND LENGTH(nw.w) >= 3)
UNION DISTINCT
SELECT DISTINCT r.id, w, 'place' FROM r, UNNEST(r.locations) l,
  UNNEST(words(l.geonames_details.name)) w WHERE LENGTH(w) >= 3;

CREATE OR REPLACE TABLE `your-project.your_dataset.xr_ror_country` AS
SELECT DISTINCT r.id ror, l.geonames_details.country_code cc FROM `your-project.ror.records` r, UNNEST(r.locations) l;

-- Country names as they appear in strings, mapped to ISO codes (ROR's names plus common forms).
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_country_names` AS
SELECT DISTINCT LOWER(REGEXP_REPLACE(NORMALIZE(l.geonames_details.country_name, NFD), r'\p{M}', '')) nm, l.geonames_details.country_code cc
FROM `your-project.ror.records` r, UNNEST(r.locations) l
WHERE l.geonames_details.country_name NOT IN ('Georgia', 'Jordan', 'Chad')
UNION DISTINCT SELECT * FROM UNNEST([
  STRUCT('usa' AS nm, 'US' AS cc), ('u.s.a', 'US'), ('united states of america', 'US'), ('uk', 'GB'), ('u.k', 'GB'), ('england', 'GB'),
  ('scotland', 'GB'), ('great britain', 'GB'), ('northern ireland', 'GB'), ('p.r. china', 'CN'), ('pr china', 'CN'), ('p. r. china', 'CN'),
  ('peoples republic of china', 'CN'), ("people's republic of china", 'CN'), ('korea', 'KR'), ('republic of korea', 'KR'), ('russia', 'RU'),
  ('iran', 'IR'), ('vietnam', 'VN'), ('czech republic', 'CZ'), ('turkey', 'TR'), ('turkiye', 'TR'), ('the netherlands', 'NL'),
  ('holland', 'NL'), ('deutschland', 'DE'), ('espana', 'ES'), ('brasil', 'BR'), ('italia', 'IT'), ('taiwan', 'TW'), ('hong kong', 'HK')]);
