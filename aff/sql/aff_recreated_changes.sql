-- For institution-written pairs recreated with changes (one distinct version on each side), which fields changed.
WITH d AS (
  SELECT yr, id, section, src, org, ANY_VALUE(STRUCT(sy, sm, ey, em, role, dept)) v, COUNT(DISTINCT TO_JSON_STRING(STRUCT(sy, sm, ey, em, role, dept))) nv
  FROM `your-project.your_dataset.orcid_aff_detail` WHERE NOT self_asserted GROUP BY 1, 2, 3, 4, 5
), f AS (
  SELECT f.*, a.v va, b.v vb FROM `your-project.your_dataset.orcid_aff_pair_fate` f
  JOIN `your-project.your_dataset.orcid_aff_sources` s ON s.client_id = f.src AND s.bucket = "Institution's own system"
  JOIN d a ON a.yr = f.yr AND a.id = f.id AND a.section = f.section AND a.src = f.src AND a.nv = 1
  JOIN d b ON b.yr = f.yr + 1 AND b.id = f.id AND b.section = f.section AND b.src = f.src AND b.org = a.org AND b.nv = 1
  WHERE f.fate IN ('recreated, changed', 'kept, edited or added to')
)
SELECT fate, COUNT(*) pairs,
  COUNTIF(va.ey IS NULL AND vb.ey IS NOT NULL) end_added, COUNTIF(va.ey IS NOT NULL AND vb.ey IS NULL) end_removed,
  COUNTIF(va.ey IS NOT NULL AND vb.ey IS NOT NULL AND (va.ey != vb.ey OR IFNULL(va.em,'') != IFNULL(vb.em,''))) end_moved,
  COUNTIF(va.sy IS NULL AND vb.sy IS NOT NULL) start_added, COUNTIF(va.sy IS NOT NULL AND vb.sy IS NULL) start_removed,
  COUNTIF(va.sy IS NOT NULL AND vb.sy IS NOT NULL AND (va.sy != vb.sy OR IFNULL(va.sm,'') != IFNULL(vb.sm,''))) start_moved,
  COUNTIF(va.role != vb.role) role_changed, COUNTIF(va.role = '' AND vb.role != '') role_added,
  COUNTIF(va.dept != vb.dept) dept_changed
FROM f GROUP BY 1
