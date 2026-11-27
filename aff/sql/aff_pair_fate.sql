-- Fate of each researcher-organisation pair from one snapshot to the next (2024 -> 2025, 2025 -> 2026).
-- A pair is (iD, section, source, organisation name). Counting pairs, not entries, stops duplicate entries
-- from weighing in. Created timestamps say whether the same entries survived or new ones replaced them;
-- dates, role and department say whether a replacement changed anything.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_aff_pair_fate` AS
WITH e AS (
  SELECT *, TO_JSON_STRING(STRUCT(sy, sm, ey, em, role, dept)) sig
  FROM `your-project.your_dataset.orcid_aff_detail`
), p AS (
  SELECT yr, id, section, src, org, ANY_VALUE(self_asserted) self_asserted, COUNT(*) n_entries,
    COUNT(DISTINCT sig) n_content, ARRAY_AGG(DISTINCT cd) cds,
    STRING_AGG(DISTINCT sig ORDER BY sig) sigs, STRING_AGG(DISTINCT IFNULL(org_id, '') ORDER BY IFNULL(org_id, '')) org_ids,
    LOGICAL_OR(ey IS NOT NULL) any_end, MIN(cd) first_cd
  FROM e GROUP BY 1, 2, 3, 4, 5
), pub AS (
  SELECT 2025 yr, orcid_identifier.path id FROM `ds-open-datasets.orcid.summaries_2025`
  UNION ALL SELECT 2026, orcid_identifier.path FROM `ds-open-datasets.orcid.summaries_2026`
), other AS (SELECT DISTINCT yr, id, section, src FROM e)
SELECT a.yr, a.id, a.section, a.src, a.self_asserted, a.n_entries, a.n_content, b.n_entries n_entries_next,
  a.n_entries > a.n_content had_duplicates,
  CASE
    WHEN pub.id IS NULL THEN 'record not public'
    WHEN b.id IS NULL AND o.id IS NOT NULL THEN 'removed, other organisation left from source'
    WHEN b.id IS NULL THEN 'removed'
    WHEN (SELECT COUNT(*) FROM UNNEST(a.cds) c WHERE c IN UNNEST(b.cds)) = 0 THEN
      IF(a.sigs = b.sigs, 'recreated, identical', 'recreated, changed')
    WHEN a.sigs = b.sigs THEN 'kept'
    ELSE 'kept, edited or added to'
  END fate,
  b.id IS NOT NULL AND NOT a.any_end AND b.any_end end_date_added,
  b.id IS NOT NULL AND a.org_ids != b.org_ids org_id_changed,
  DATE_DIFF(DATE(SUBSTR(b.first_cd, 1, 10)), DATE(SUBSTR(a.first_cd, 1, 10)), DAY) cd_shift_days
FROM p a
LEFT JOIN pub ON pub.yr = a.yr + 1 AND pub.id = a.id
LEFT JOIN p b ON b.yr = a.yr + 1 AND b.id = a.id AND b.section = a.section AND b.src = a.src AND b.org = a.org
LEFT JOIN other o ON o.yr = a.yr + 1 AND o.id = a.id AND o.section = a.section AND o.src = a.src AND b.id IS NULL
WHERE a.yr < 2026
