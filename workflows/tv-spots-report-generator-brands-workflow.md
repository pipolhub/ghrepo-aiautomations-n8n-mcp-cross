# TV Spots Report Generator | Brands Workflow

**ID:** `okok3Ht8Fa4hMDAe`
**Status:** Active
**Created:** 2026-01-26
**Last Updated:** 2026-01-28

## Overview

The active sub-workflow that generates brand-specific advertising intelligence reports. Called by the main TV Spots Report Generator workflow, it analyzes TV spot data and produces professionally styled PDF reports in Spanish using MIA's AI-powered monitoring platform.

## Trigger

- **When Executed by Another Workflow** - Receives brand data from parent workflow

## Workflow Flow

1. **When Executed by Another Workflow** - Receives country, industry, date range, and brand list
2. **Convert Country Code to Name** - Maps country codes (AR, MX, BR, CL, PE, etc.) to Spanish names
3. **Loop Over Brands** - Iterates through each brand
4. **Get Top Spots per Brand** - BigQuery query for top 5 spots with content descriptions
5. **Aggregate** - Aggregates spot data for analysis
6. **TV Contents Analyzer** - Generates Markdown report using Gemini Pro/Flash
7. **Merger / HTML Formatter** - Converts to styled HTML with MIA brand design
8. **HTTP Request** - Converts HTML to PDF via cloud service
9. **Code in JavaScript** - Sets PDF filename to brand name
10. **Aggregate PDFs** - Combines all brand PDFs
11. **Gmail - Send Report** - Sends email with all PDF attachments

## Report Structure (Spanish)

1. **Header** - Brand name, country, industry, date range, MIA branding
2. **Executive Summary** - 2-3 sentence overview
3. **Advertising Activity Overview** - Brand metrics table
4. **Creative Strategy Analysis**
   - Messaging Strategy
   - Tone & Style
   - Value Proposition
   - Promotional Offers & Bonuses
5. **Spot-by-Spot Breakdown** - Table with frequency and key differentiators
6. **Key Insights & Recommendations** - Numbered strategic observations
7. **Footer** - MIA branding and link to get.mia.tech

## MIA Design System

- **Colors**: Primary Blue #1d4ed8, Text #191b1f
- **Typography**: Noto Sans
- **Layout**: Flat design, no shadows
- **Elements**: Summary boxes, insight circles, styled tables
- **Assets**: MIA logos from Google Cloud Storage

## Integrations

| Service | Purpose |
|---------|---------|
| Google BigQuery | MIA analytics layer data |
| Google Gemini Pro/Flash | AI report generation |
| Gmail | Report delivery |
| PDF Converter | Cloud Run service for HTML-to-PDF |

## Nodes (15 total)

- When Executed by Another Workflow
- Convert Country Code to Name
- Aggregate PDFs
- Gmail - Send Report
- Gemini Pro Latest
- Gemini Latest Flash
- Loop Over Brands
- Aggregate
- Get Top Spots per Brand
- TV Contents Analyzer
- Merger / HTML Formatter
- HTTP Request
- Code in JavaScript

## Recipients

- operaciones.digitales@pipolhub.com
- cuentas@pipolhub.com
- business.intelligence@pipolhub.com
- BCC: adrian@pipolhub.com, franco.tanaro@pipolhub.com

## Parent Workflow

Called by: **TV Spots Report Generator** (`rQt7uPmBYCFHcrZZ`)
