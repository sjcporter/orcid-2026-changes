-- Headline view of the pairs, for pairs present in the 2026 file.
SELECT via_mp, any_aff, any_emp, any_work, COUNT(*) pairs, COUNT(DISTINCT id) researchers,
  COUNTIF(emp_2026 AND has_start) emp_start, COUNTIF(emp_2026 AND has_start_month) emp_start_month, COUNTIF(emp_2026 AND has_end) emp_end,
  APPROX_QUANTILES(n_months, 2)[OFFSET(1)] med_months, AVG(n_months) avg_months, APPROX_QUANTILES(n_years, 2)[OFFSET(1)] med_years,
  COUNTIF(n_months >= 2) two_plus_months, COUNTIF(n_years >= 3) three_plus_years, COUNTIF(new_26) new_last_year
FROM `your-project.your_dataset.orcid_inst_pairs` WHERE in_2026 GROUP BY 1, 2, 3, 4 ORDER BY pairs DESC
