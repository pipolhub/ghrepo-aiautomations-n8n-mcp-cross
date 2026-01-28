# TV Spots Report Generator | Brands Workflow (adrian copy)

**ID:** `m8fQNTL96UZWjdUh`
**Status:** Inactive
**Created:** 2026-01-28
**Last Updated:** 2026-01-28

## Overview

A sub-workflow designed to be executed by the main TV Spots Report Generator. It processes brand data to generate individual advertising intelligence reports in PDF format and sends them via email. This is Adrian's copy of the workflow.

## Trigger

- **When Executed by Another Workflow** - Receives brand data from parent workflow

## Workflow Flow

1. **When Executed by Another Workflow** - Receives input data (country, industry, date range, brand list)
2. **Loop Over Brands** - Iterates through each brand in the input
3. **Get Top Spots per Brand** - BigQuery query fetches top 5 spots per brand
4. **Aggregate** - Aggregates spot data for the brand
5. **TV Contents Analyzer** - Generates Markdown report using Gemini AI (Spanish output)
6. **Merger / HTML Formatter** - Converts Markdown to styled HTML using MIA brand design
7. **HTTP Request** - Sends HTML to PDF converter service
8. **Code in JavaScript** - Sets filename based on brand name
9. **Aggregate PDFs** - Combines all PDF reports
10. **Gmail - Send Report** - Sends email with PDF attachments

## Report Content (Generated in Spanish)

- Brand Advertising Intelligence Report header
- Executive Summary
- Advertising Activity Overview
- Creative Strategy Analysis (Messaging, Tone, Value Proposition, Promotions)
- Spot-by-Spot Breakdown
- Key Insights & Recommendations
- MIA branding footer

## Design System

Uses MIA's flat design system with:
- Primary Blue: #1d4ed8
- Noto Sans typography
- Professional PDF-optimized styling
- MIA watermark and logos

## Integrations

| Service | Purpose |
|---------|---------|
| Google BigQuery | Spot data from MIA analytics layer |
| Google Gemini Pro/Flash | AI content analysis and generation |
| Gmail | Report delivery to operations team |
| PDF Converter Service | HTML to PDF conversion |

## Nodes (14 total)

- When Executed by Another Workflow
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
