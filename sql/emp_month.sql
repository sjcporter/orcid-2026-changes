SELECT SUBSTR(history.submission_date, 1, 7) ym, COUNT(*) profiles,
  ROUND(100*COUNTIF((SELECT COUNT(*) FROM UNNEST(activities.employments.groups) z WHERE z.last_modified_date IS NOT NULL) > 0)/COUNT(*),1) pct_employment
FROM `ds-open-datasets.orcid.summaries_2026`
WHERE history.submission_date BETWEEN '2023-06' AND '2024-09'
GROUP BY 1 ORDER BY 1
