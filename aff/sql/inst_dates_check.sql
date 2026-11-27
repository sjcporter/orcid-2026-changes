-- first_seen / last_seen against the explicit dates on the institution's own employment entry (2026 file).
-- Starts are only compared where the explicit start is after the system's first-ever assertion.
SELECT
  COUNTIF(has_end) with_end,
  COUNTIF(has_end AND EXTRACT(YEAR FROM last_seen_non_aff) BETWEEN end_year - 1 AND end_year + 1) end_within_1y,
  COUNTIF(has_end AND EXTRACT(YEAR FROM last_seen_non_aff) > end_year + 1) seen_after_end,
  COUNTIF(has_end AND EXTRACT(YEAR FROM last_seen_non_aff) < end_year - 1) last_seen_before_end,
  COUNTIF(has_start AND start_year > EXTRACT(YEAR FROM inst_first_seen)) with_start_after_go_live,
  COUNTIF(has_start AND start_year > EXTRACT(YEAR FROM inst_first_seen) AND EXTRACT(YEAR FROM first_seen) BETWEEN start_year - 1 AND start_year + 1) start_within_1y,
  COUNTIF(any_open) open_entries,
  COUNTIF(any_open AND last_seen_non_aff >= '2025-10-02') open_seen_last_year,
  COUNTIF(any_open AND last_seen_non_aff < '2024-10-14') open_not_seen_2y,
  COUNTIF(any_open AND last_seen_non_aff < '2021-10-14') open_not_seen_5y,
  COUNTIF(any_open AND last_seen_non_aff IS NULL) open_no_other_items
FROM `your-project.your_dataset.orcid_inst_pairs` WHERE in_2026 AND emp_2026 AND any_work
