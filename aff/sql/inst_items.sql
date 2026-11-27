-- One row per item written by an institution's own system, in any section, in each snapshot.
CREATE OR REPLACE TABLE `your-project.your_dataset.orcid_inst_items` AS
  SELECT 2024 yr, 'work' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'funding' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'peer_review' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'research_resource' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'employment' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'education' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'qualification' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'invited_position' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'membership' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'service' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'external_id' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'url' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'keyword' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'other_name' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2024 yr, 'address' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2024` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'work' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'funding' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'peer_review' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'research_resource' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'employment' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'education' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'qualification' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'invited_position' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'membership' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'service' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'external_id' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'url' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'keyword' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'other_name' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2025 yr, 'address' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2025` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'work' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.works.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'funding' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.fundings.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'peer_review' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.peer_reviews.groups) g0, UNNEST(g0.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'research_resource' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.research_resources.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'employment' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.employments.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'education' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.educations.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'qualification' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.qualifications.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'invited_position' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.invited_positions.records) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'membership' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.memberships.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'service' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.activities.services.groups) g, UNNEST(g.records) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'external_id' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.external_identifiers.identifiers) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'url' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.researcher_urls.urls) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'keyword' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.keywords.keywords) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'other_name' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.other_names.names) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
  UNION ALL
  SELECT 2026 yr, 'address' kind, t.orcid_identifier.path id, IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) src, IFNULL(r.source.assertion_origin_client_id.path, r.source.assertion_origin_orcid.path) origin, r.created_date cd, r.last_modified_date lmd
  FROM `ds-open-datasets.orcid.summaries_2026` t, UNNEST(t.person.addresses.addresses) r
  WHERE IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IS NOT NULL AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) != t.orcid_identifier.path AND IFNULL(r.source.source_client_id.path, r.source.source_orcid.path) IN (SELECT client_id FROM `your-project.your_dataset.orcid_inst_sources` UNION ALL SELECT 'APP-4B3XYWJHXCC1VLVV')
