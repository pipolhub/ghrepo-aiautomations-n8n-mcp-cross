# Customer Success Workflow

**ID:** `F5SqBaQ4xKPTuOpY`
**Status:** Inactive
**Created:** 2025-12-03
**Last Updated:** 2025-12-04

## Overview

This workflow is designed to support customer success operations by querying Google BigQuery for customer data, filtering results, and sending consolidated email notifications via Gmail.

## Trigger

- **Schedule Trigger** - Runs daily at 1:00 PM (13:00)

## Workflow Flow

1. **Schedule Trigger** - Triggers the workflow at the scheduled time
2. **Execute a SQL query / Execute a SQL query1 / Execute a SQL query2** - Three parallel BigQuery queries to retrieve customer data
3. **Filter / Filter1 / Filter2** - Filters results from each query based on specified conditions
4. **Merge** - Combines filtered results from all three data sources (3 inputs)
5. **Send a message** - Sends consolidated notification via Gmail

## Integrations

| Service | Purpose |
|---------|---------|
| Google BigQuery | Customer data queries |
| Gmail | Email notifications (with BCC support) |

## Nodes (9 total)

- Schedule Trigger
- Execute a SQL query
- Filter
- Send a message
- Execute a SQL query1
- Filter1
- Merge
- Filter2
- Execute a SQL query2

## Notes

This workflow appears to be in development or inactive state. The BigQuery queries and filter conditions are not fully configured.
