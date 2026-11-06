-- Public works per release, counting each grouped work once per record (as the ORCID record displays it).
SELECT '2025' rel, SUM((SELECT COUNT(*) FROM UNNEST(activities.works.groups) g WHERE g.last_modified_date IS NOT NULL)) works
FROM `ds-open-datasets.orcid.summaries_2025`
UNION ALL
SELECT '2026', SUM((SELECT COUNT(*) FROM UNNEST(activities.works.groups) g WHERE g.last_modified_date IS NOT NULL))
FROM `ds-open-datasets.orcid.summaries_2026`
