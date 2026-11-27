-- Does last_seen predict leaving? Cohort: pairs where, in the 2024 file, the institution's system had written an
-- open employment entry (no end date) and at least one other item. last_seen is measured on the 2024 file only.
-- Outcome is the system's employment entries in the 2026 file, and whether the researcher entered a new
-- employer elsewhere after the 2024 file. by_system = 'maintained': only systems that still wrote new items in the
-- last year and ended or removed at least 5% of their cohort, so a system that never updates anything does not count as a signal.
WITH keys AS (SELECT * FROM `your-project.your_dataset.orcid_inst_org_keys`),
emp AS (
  SELECT yr, id, src inst, LOGICAL_OR(ey IS NULL) any_open, MAX(SAFE_CAST(ey AS INT64)) end_year
  FROM `your-project.your_dataset.orcid_aff_detail` WHERE section = 'employment' AND NOT self_asserted GROUP BY 1, 2, 3
), seen24 AS (
  SELECT id, src inst, MAX(DATE(SUBSTR(cd, 1, 10))) last_seen
  FROM `your-project.your_dataset.orcid_inst_items`
  WHERE yr = 2024 AND kind NOT IN ('employment', 'education', 'qualification', 'invited_position', 'membership', 'service') GROUP BY 1, 2
), cohort AS (
  SELECT e.id, e.inst, s.last_seen FROM emp e JOIN seen24 s USING (id, inst) WHERE e.yr = 2024 AND e.any_open
), pub AS (SELECT orcid_identifier.path id FROM `ds-open-datasets.orcid.summaries_2026`),
new_job AS (  -- a self-entered employment created after the 2024 file, at an organisation that is not this institution
  SELECT DISTINCT c.id, c.inst FROM cohort c
  JOIN `your-project.your_dataset.orcid_aff_2026` a ON a.id = c.id AND a.section = 'employment' AND a.self_asserted AND a.cd > '2024-09-24'
  WHERE NOT EXISTS (SELECT 1 FROM keys k WHERE k.inst = c.inst AND ((k.key_type = 'id' AND k.k = a.org_id) OR (k.key_type = 'name' AND k.k = LOWER(TRIM(a.org)))))
), maintained_sys AS (
  SELECT c.inst FROM cohort c LEFT JOIN emp e26 ON e26.yr = 2026 AND e26.id = c.id AND e26.inst = c.inst
  WHERE c.inst IN (SELECT DISTINCT src FROM `your-project.your_dataset.orcid_inst_items` WHERE yr = 2026 AND cd > '2025-10-02' AND kind = 'work')
  GROUP BY 1 HAVING COUNTIF(e26.inst IS NULL OR NOT e26.any_open) >= 0.05 * COUNT(*) AND COUNT(*) >= 100
)
SELECT ms.inst IS NOT NULL maintained,
  CASE WHEN DATE_DIFF('2024-09-24', c.last_seen, DAY) <= 365 THEN '1 seen in the last year'
       WHEN DATE_DIFF('2024-09-24', c.last_seen, DAY) <= 730 THEN '2 last seen 1-2 years before'
       WHEN DATE_DIFF('2024-09-24', c.last_seen, DAY) <= 1826 THEN '3 last seen 2-5 years before'
       ELSE '4 last seen 5+ years before' END last_seen_2024,
  COUNT(*) pairs,
  COUNTIF(p.id IS NULL) record_gone,
  COUNTIF(p.id IS NOT NULL AND e26.any_open) still_open_2026,
  COUNTIF(p.id IS NOT NULL AND e26.inst IS NOT NULL AND NOT e26.any_open) ended_by_2026,
  COUNTIF(p.id IS NOT NULL AND e26.inst IS NULL) removed_by_2026,
  COUNTIF(n.id IS NOT NULL) new_job_elsewhere,
  COUNTIF(p.id IS NOT NULL AND e26.any_open AND n.id IS NOT NULL) still_open_but_new_job
FROM cohort c
LEFT JOIN pub p ON p.id = c.id
LEFT JOIN emp e26 ON e26.yr = 2026 AND e26.id = c.id AND e26.inst = c.inst
LEFT JOIN new_job n ON n.id = c.id AND n.inst = c.inst
LEFT JOIN maintained_sys ms ON ms.inst = c.inst
GROUP BY 1, 2 ORDER BY 1, 2
