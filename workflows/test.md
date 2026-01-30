# TEST

**ID:** `BxA30jm1nuQreOKV`
**Status:** Active
**Created:** 2026-01-27
**Last Updated:** 2026-01-28

## Overview

Downloads PDF and ZIP files from a Google Drive folder on a business-hours schedule, outputting binary data for downstream processing.

## Trigger

- **Type:** Google Drive Trigger
- **Event:** File Created
- **Folder:** Prueba (`1trp-Ky0iigIwSgfZ_gHAaxINuJE8tROz`)
- **Schedule:** Hourly, 10:00-19:00, Mon-Fri (`0 10-19 * * 1-5`)

## Workflow Flow

```
Google Drive Trigger → Filter PDF/ZIP → Download File
      (cron)              (If node)       (Drive node)
```

1. **Google Drive Trigger** - Monitors the "Prueba" folder for new files on business-hours schedule
2. **Filter PDF/ZIP** - Filters to only process PDF and ZIP files based on MIME type
3. **Download File** - Downloads the actual file binary data

## File Type Filter

The workflow only processes files with the following MIME types:
- `application/pdf` (PDF files)
- `application/zip` (ZIP archives)
- `application/x-zip-compressed` (ZIP archives - alternative MIME type)

## Output

The workflow outputs binary file data in the `binary.data` property, ready for downstream processing.

## Integrations

- Google Drive (OAuth2 - AI Automations User)

## Nodes (3 total)

| Node | Type | Purpose |
|------|------|---------|
| Google Drive Trigger | `n8n-nodes-base.googleDriveTrigger` | Polls folder for new files on cron schedule |
| Filter PDF/ZIP | `n8n-nodes-base.if` | Filters to only PDF and ZIP files |
| Download File | `n8n-nodes-base.googleDrive` | Downloads file binary data |

## Credentials Used

- `Google Drive AI Automations User` (Google Drive OAuth2)
