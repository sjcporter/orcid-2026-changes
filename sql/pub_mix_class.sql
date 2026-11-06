WITH w AS (
  SELECT r.source.source_client_id.path cid, r.source.source_orcid.path = t.orcid_identifier.path self,
    (SELECT REGEXP_EXTRACT(LOWER(IFNULL(i.normalized, i.value)), r'(10\.\d{4,9})/') FROM UNNEST(r.external_ids.identifiers) i WHERE i.type = 'doi' LIMIT 1) prefix
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE r.created_date >= '2025-10-14' AND r.created_date < '2026-10-15')
SELECT prefix,
  CASE WHEN IFNULL(self, FALSE) THEN 'Self-entered'
       WHEN c.source_name = 'Crossref' THEN 'Crossref auto-update'
       ELSE IFNULL(c.source_subclass, 'Other / unclassified') END cls,
  COUNT(*) n
FROM w LEFT JOIN `your-project.your_dataset.orcid_source_classes` c ON c.client_id = w.cid
WHERE prefix IN ('10.1002','10.1006','10.1007','10.1016','10.1021','10.1023','10.1038','10.1039','10.1046','10.1053','10.1057','10.1080','10.1088','10.1093','10.1096','10.1097','10.1101','10.1103','10.1109','10.1111','10.1112','10.1113','10.1136','10.1140','10.1161','10.1177','10.1186','10.1201','10.1208','10.1212','10.1213','10.1227','10.1245','10.1249','10.13140','10.1371','10.14309','10.14814','10.1519','10.1557','10.1681','10.18429','10.20944','10.2106','10.2139','10.2147','10.23919','10.26434','10.2903','10.3109','10.3389','10.3390','10.3758','10.3760','10.4135','10.4161','10.4324','10.48550','10.5281') GROUP BY 1, 2
