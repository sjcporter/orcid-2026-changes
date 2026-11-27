-- All runs. Reference: Dimensions' resolution of the same instance (dim run), or for Crossref runs the ROR that
-- Dimensions most often resolves the same string to (xr_dim_dict); where Crossref itself carries a ROR it is shown too.
-- Rules: all = every candidate pair; text = drop "definitely does not belong" (xr_eval_dim.sql);
-- text+pick = also, where several candidates remain for a string, keep only the one whose name words match, if unique.
CREATE OR REPLACE TABLE `your-project.your_dataset.xr_eval` AS
WITH rel AS (
  SELECT r.id a, REGEXP_EXTRACT(x.id, r'([0-9a-z]{9})$') b FROM `your-project.ror.records` r, UNNEST(r.relationships) x
), c AS (
  SELECT c.run, c.signal, c.doi, c.id, c.raw, c.n_aff, c.cand_ror, IFNULL(c.ror_truth, d.ref_ror) ref_ror, d.share ref_share,
    s.name_hit, IFNULL(s.country_conflict, FALSE) OR NOT (s.name_hit OR s.place_hit) definitely_not
  FROM `your-project.your_dataset.xr_cand` c
  JOIN `your-project.your_dataset.xr_score` s ON s.ror = c.cand_ror AND s.raw = c.raw
  LEFT JOIN `your-project.your_dataset.xr_dim_dict` d ON c.run != 'dim' AND d.raw = c.raw
), k AS (
  SELECT *, COUNTIF(NOT definitely_not) OVER w kept_cands, COUNTIF(NOT definitely_not AND name_hit) OVER w name_cands
  FROM c WINDOW w AS (PARTITION BY run, signal, doi, id, raw)
)
SELECT k.*, NOT definitely_not AND (kept_cands = 1 OR (name_hit AND name_cands = 1)) picked,
  k.cand_ror = k.ref_ror exact, k.cand_ror = k.ref_ror OR rel.b IS NOT NULL related
FROM k LEFT JOIN rel ON rel.a = k.cand_ror AND rel.b = k.ref_ror
