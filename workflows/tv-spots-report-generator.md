# TV Spots Report Generator

**ID:** `rQt7uPmBYCFHcrZZ`
**Status:** Active
**Created:** 2026-01-16
**Last Updated:** 2026-01-27

## Overview

The main orchestrator workflow for generating TV advertising spot reports. It runs weekly, queries Google BigQuery for top advertising brands across multiple countries and industries, and delegates report generation to a sub-workflow for each country/industry segment.

## Trigger

- **Schedule Trigger** - Runs every 7 days at 11:59 PM

## Workflow Flow

1. **Schedule Trigger** - Triggers weekly execution
2. **Set Parameters** - Configures:
   - Country/Industry segments: MX/IGAMING, MX/FINTECH, AR/IGAMING, BR/IGAMING, CL/IGAMING, PE/IGAMING
   - Date range: Last 15 days (calculated automatically)
3. **Split Countries** - Splits segments for iteration
4. **Loop Over Countries** - Processes each segment sequentially
5. **Get Top 5 Brands by Country** - BigQuery query returns:
   - Brand ID and name
   - Spot quantity count
   - Country, industry, date range (passed to sub-workflow)
6. **Execute Workflow** - Calls the Brands Workflow sub-workflow for each segment

## Segments Covered

| Country | Industry |
|---------|----------|
| Mexico (MX) | IGAMING |
| Mexico (MX) | FINTECH |
| Argentina (AR) | IGAMING |
| Brazil (BR) | IGAMING |
| Chile (CL) | IGAMING |
| Peru (PE) | IGAMING |

## Data Sources

- **BigQuery Project**: mia-dw-analytics-prod
- **Tables**:
  - `analytics_layer.sl_off_auditoria__proveedores` - Spot audit data
  - `analytics_layer.sl_brd__marca` - Brand information

## Integrations

| Service | Purpose |
|---------|---------|
| Google BigQuery | MIA analytics data warehouse |
| Execute Workflow | Calls Brands Workflow sub-workflow |

## Nodes (6 total)

- Schedule Trigger
- Set Parameters
- Split Countries
- Loop Over Countries
- Get Top 5 Brands by Country
- Execute Workflow

## Sub-Workflow

Calls: **TV Spots Report Generator | Brands Workflow** (`okok3Ht8Fa4hMDAe`)

## Configuration

To modify countries or industries, update the `Set Parameters` node's JSON configuration:

```json
{
  "segments": [
    { "country": "MX", "industry": "IGAMING" },
    { "country": "AR", "industry": "IGAMING" }
    // Add or remove segments as needed
  ]
}
```
