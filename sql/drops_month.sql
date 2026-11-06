-- Monthly employment entries created by the systems whose additions fell, as seen in the 2026 snapshot.
SELECT r.source.source_name src, FORMAT_DATE('%Y-%m', DATE(r.created_date)) month, COUNT(*) n
FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
WHERE r.created_date >= '2024-10-14' AND r.created_date < '2026-10-15'
  AND r.source.source_name IN ('Aarhus University', 'University of Dundee', 'University of Southern Denmark', 'University of Oxford',
    'EUR & Erasmus MC Research Information Portal Pure', 'University of Groningen', 'City University of Hong Kong')
GROUP BY 1, 2 ORDER BY 1, 2
