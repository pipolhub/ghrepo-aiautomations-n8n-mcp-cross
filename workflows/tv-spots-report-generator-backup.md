# TV Spots Report Generator Backup

**ID:** `V0A6DDQdl2kCDloy`
**Status:** Inactive
**Created:** 2026-01-17
**Last Updated:** 2026-01-17

## Overview

This is a backup copy of the TV Spots Report Generator workflow. It generates competitive intelligence reports analyzing TV advertising spots across multiple countries and industries using MIA's (Multitouch Investment Attribution) AI-powered ad monitoring platform.

## Triggers

- **Schedule Trigger1** - Runs every 15 days
- **When clicking 'Execute workflow'** - Manual execution (disabled)

## Workflow Flow

1. **Set Parameters** - Configures countries (AR, MX, BR, CL) and date range (last 15 days)
2. **Split Countries** - Splits the segments for parallel processing
3. **Loop Over Countries** - Iterates through each country/industry combination
4. **Get Top 5 Brands by Country** - BigQuery query to get top brands by spot quantity
5. **Loop Over Brands** - Iterates through each brand
6. **Execute a SQL query** - Fetches top 5 spots per brand from BigQuery
7. **Aggregate Spots for Brand** - Aggregates spot data
8. **Basic LLM Chain** - Generates Markdown reports using Gemini Pro/Flash
9. **Aggregate Brand Reports** - Combines all brand reports
10. **Prepare HTML Data** - Formats data for PDF conversion
11. **Convert HTML to PDF** - Converts reports to PDF format
12. **Aggregate PDFs** - Combines all PDF attachments
13. **Gmail - Send Report** - Sends consolidated report via email

## Report Features

- MIA-branded professional reports
- Executive summaries
- Advertising activity overview
- Creative strategy analysis
- Spot-by-spot breakdown
- Key insights and recommendations

## Integrations

| Service | Purpose |
|---------|---------|
| Google BigQuery | Ad monitoring data (MIA analytics layer) |
| Google Gemini Pro/Flash | AI report generation |
| Gmail | Report delivery |
| HTML to PDF | Report formatting |

## Nodes (21 total)

- When clicking 'Execute workflow'
- Convert HTML to PDF
- Execute a SQL query
- Analysis Prompt
- Schedule Trigger
- Set Parameters
- Split Countries
- Prepare HTML Data
- Aggregate PDFs
- Gmail - Send Report
- Schedule Trigger1
- Convert HTML to PDF1
- Basic LLM Chain
- Gemini Pro Latest
- Gemini Latest Flash
- Loop Over Countries
- Get Top 5 Brands by Country
- Loop Over Brands
- Aggregate Brand Reports
- Aggregate Spots for Brand

## Notes

This is a backup version of the main TV Spots Report Generator workflow. See the active version for current implementation.
