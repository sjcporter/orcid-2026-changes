# Thirty million researchers, and who writes their records

*The 2026 ORCID Public Data File is out, and it is now in BigQuery next to last year's. We compared the two releases to see what has changed over the year.*

The snapshot, taken on 14 October 2026, holds **29.99 million public records**, up 19.7% on 2025. Nearly 5 million of them are new since last year. Between them they list **145 million works**, 23 million more than a year ago. Most of the changes we found are about who adds information to records: researchers, publishers, citation indexes or universities.

## 1. New researchers now say where they work

Two-thirds of researchers who joined in the last two years list an employer. Before 2024, under a fifth of new accounts did. The change happened suddenly: [accounts created in February–March 2024](https://sjcporter.github.io/orcid-2026-changes/#employment) jumped from 18% to 66% with an employer, and the share has stayed there. That is when ORCID started prompting new users to add an employer at registration, suggested from their email domain where possible ([release notes, 23 February 2024](https://info.orcid.org/feature-friday)). The [ORCID 2025 Annual Report](https://doi.org/10.23640/07243.31846192) credits these suggestions with a large rise in records with affiliations. Across all records, the share with employment has gone from 27% to 36% to 42% over three releases.

Researchers enter almost all of this themselves: 98% of the 4.5 million employment entries added this year. Self-entered employment grew fastest in South Asia (+40%), Southeast Asia (+38%) and Sub-Saharan Africa (+37%). If you use ORCID to map the research workforce, note that recent cohorts carry country and institution data that older cohorts mostly lack, so compare countries only among records that list an employer.

## 2. Web of Science became a main source of works

Last year Clarivate's services added about 161,000 works to ORCID. This year they added about [5.0 million](https://sjcporter.github.io/orcid-2026-changes/#works), through Web of Science, Web of Science Researcher Profiles and Clarivate sign-on. Scopus grew too, from 4.1M to 5.7M. Overall, [indexing and discovery services](https://sjcporter.github.io/orcid-2026-changes/#sources) added 97% more works than last year.

In September–October 2025, Clarivate's old ORCID sync client dropped from about 55,000 works a month to about 4,000, and two new Clarivate clients started up. A [Clarivate training deck from December 2025](https://recursoscientificos.fecyt.es/sites/default/files/Sesi%C3%B3n%20B2_Administrar%20un%20perfil%20de%20investigador%20en%20Web%20of%20Science%20(Dic2025).pdf) describes a "revised ORCID connection" that asked users to re-grant wider permissions, which would explain the switch. The deck doesn't give a launch date, so we are going on the timing. About half of the works Web of Science sent this year were published before 2020, and 52% were already on the researcher's record from another source. So most of this is researchers' older publications, often ones ORCID already had.

These are syncs the researcher authorises: they connect the service once, and it then sends their works to ORCID. For most large publishers, these services now account for 40–57% of the work records created for the publisher's DOIs, more than Crossref's automatic update. (A paper sent by several systems counts once for each.)

## 3. Researchers still enter 7 million works by hand

Researchers entered [7.0 million works](https://sjcporter.github.io/orcid-2026-changes/#self) themselves this year, up 45%. 36% of those have no DOI: theses, reports, talks and outputs no integration covers. Of the 4.49M with a DOI, 84% have no copy from any integration on the researcher's record. For the rest, the DOI prefix shows which publishers leave the most work to researchers.

Crossref's automatic update adds a work to ORCID when the publisher includes authors' iDs in its DOI metadata. For Frontiers and Cureus it delivered none of this year's works. For Frontiers, indexes delivered 57% of works and researchers a third. MDPI is the only large publisher that sends works to ORCID itself at scale (36%). For publishers, the simplest way to reduce researchers' manual entry is to include iDs in every Crossref deposit.

## 4. Institutional integrations are mostly in Europe and Australia

We classified the 838 systems that wrote to ORCID this year, using their names. (The [ORCID 2025 Annual Report](https://doi.org/10.23640/07243.31846192) counts 708 member integrations adding 23.3M items in calendar 2025, private items included.) Universities' and hospitals' research information systems pushed [2.50 million works](https://sjcporter.github.io/orcid-2026-changes/#sources), up 19%. 68% came from European systems, 14.5% from Oceania and 13% from North America. Asia, Latin America, Africa and the Middle East together contributed under 4%, although about two-thirds of this year's new employment entries are at employers in those regions. Researchers in those regions are joining and stating where they work, but their institutions mostly aren't sending works to ORCID.

Australian institutional systems nearly doubled their output, from 185k to 357k works. Most of the rise came from [four universities loading researchers' past publications](https://sjcporter.github.io/orcid-2026-changes/#australia): the University of Sydney (from zero to 84.7k works across 982 researchers), Queensland, UniSC and Newcastle. Ireland (30k to 105k), Canada (18k to 60k) and Czechia (35k to 88k) also grew sharply.

## 5. DataCite: more automatic updates, and many more researcher claims

DataCite's [automatic update](https://sjcporter.github.io/orcid-2026-changes/#datacite), which fires when a DOI's metadata includes an ORCID iD, grew 46%, from 175k to 255k works. Its search-and-link tool, where researchers claim works themselves, grew about tenfold, from 1.5k to 14.3k. DataCite-registered preprints rose eightfold. Researchers tripled the software they enter themselves, from 3.7k to 11.2k. Preprints overall more than doubled (+126%) across all sources.

## 6. Links: LinkedIn and GitHub grow, X stalls, Bluesky has a foothold

Only about 6% of records list a website, a share that has barely moved. Within that group, [LinkedIn](https://sjcporter.github.io/orcid-2026-changes/#links) grew 31% to 518k profiles, and GitHub grew 47% to 75k, overtaking X/Twitter (65k, +5%).

[6,410 profiles](https://sjcporter.github.io/orcid-2026-changes/#bluesky) link to Bluesky, up 40%. New Bluesky links peaked at 895 in November 2024, after the US election, and have settled at about 140 a month. Researchers still add X links about 3.5 times as often. Of the 3,184 profiles that removed an X link this year, 503 (16%) now list Bluesky.

## Try it yourself

The 2026 file is in BigQuery as `ds-open-datasets.orcid.summaries_2026`, next to `summaries_2025`, with one row per public record and column descriptions for each field. For example, to count profiles that link to Bluesky:

```sql
SELECT COUNT(DISTINCT orcid_identifier.path) AS profiles
FROM `ds-open-datasets.orcid.summaries_2026`,
UNNEST(person.researcher_urls.urls) AS u
WHERE REGEXP_CONTAINS(LOWER(u.url), r'bsky\.(app|social)')
```

BigQuery charges by the columns a query reads, not by table size. A query like this reads a few gigabytes and costs a few cents.

## A few caveats

- The file holds public data only, so every count is a lower bound. About 1.16 million records in the snapshot are placeholders for locked, deprecated or deactivated accounts.
- Year-on-year comparisons use each item's created date, in 14 October to 14 October windows.
- ORCID doesn't record where an integration is based. We inferred each institutional system's country from the employers in the entries it writes. Every one of the 268 systems whose name identifies a country was assigned that country.
- Counts of entries sent by institutions include rewrites. 41% of this year's institutional employment entries recreate entries a system had already sent. Works are not affected in the same way: 99.4% of works sent by integrations carry over between releases.

The ORCID Public Data File is released by ORCID under CC0.
