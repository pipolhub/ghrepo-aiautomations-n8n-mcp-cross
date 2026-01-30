# Accounting - Facturas Proveedores

**ID:** `7VTaZuudWnUdYv1s`
**Status:** Active
**Created:** 2025-11-10
**Last Updated:** 2026-01-30

## Overview

This workflow automates the processing of supplier invoices (facturas proveedores). It monitors a Google Drive folder for new files (PDF, ZIP, PNG), extracts invoice data using AI, organizes files into Year/Month/Provider folder structure, and manages approval workflows with Google Sheets integration.

## Triggers

- **Google Drive Trigger** - Monitors "Prueba" folder for new files (runs hourly 10 AM - 7 PM, Mon-Fri)

## Workflow Flow

### 1. File Intake
1. **Google Drive Trigger** - Detects new files in monitored folder
2. **Filter PDF/ZIP/PNG** - Filters for supported file types (PDF, ZIP, PNG)
3. **Download File** - Downloads file content for processing
4. **Is .ZIP?** - Routes ZIP files for decompression
5. **Decompress Zips** - Extracts files from ZIP archives
6. **Filter PDFs** - Filters extracted files for PDFs

### 2. AI Processing
7. **Get Clients** - Retrieves client list from Google Sheets
8. **Get Client Email Map** - Maps cost centers to approver emails
9. **Analyze File** - AI-powered document analysis using Google Gemini
10. **Merge2** - Combines file data with client context
11. **Basic LLM Chain1** - Extracts structured invoice data with Gemini 2.5
12. **Structured Output Parser1** - Parses AI output into JSON schema
13. **Merge3** - Combines original file data with extracted invoice data

### 3. Validation & Routing
14. **Is Bill for Pipol?** - Checks if invoice recipient contains "PIPOL" (case-insensitive)

### 4. Folder Organization Circuit
15. **Move Files Loop** - Iterates through files to organize
16. **Search for Year Folder** - Checks if year folder exists
17. **Year Folder Exists** - Routes to create or use existing
18. **Create Year Folder** - Creates folder for invoice year
19. **Merge** - Continues with year folder ID
20. **Search Month Folder** - Checks if month folder exists
21. **Month Folder Exists** - Routes to create or use existing
22. **Create Month Folder** - Creates folder for invoice month (Spanish names)
23. **Merge1** - Continues with month folder ID
24. **Search Provider Folder** - Checks if provider folder exists
25. **Provider Folder Exists** - Routes to create or use existing
26. **Create Provider Folder** - Creates folder for supplier name
27. **Merge4** - Continues with provider folder ID
28. **Move file** - Moves file to final destination folder
29. **Collect Moved File** - Stores moved file data with constructed URL
30. **Get All Moved Files** - Retrieves all moved files after loop completes

### 5. Approval Workflow
31. **Approval Logic1** - Builds approval records with deduplication
32. **Prepare Share Permissions** - Prepares file sharing data
33. **Permissions Loop** - Iterates through files to share
34. **Wait** - Rate limiting between API calls
35. **Share file** - Grants reader access to approvers
36. **Add Row in Approval Sheet1** - Records pending approvals in Google Sheets
37. **Send a message1** - Sends approval notification emails via Gmail

### 6. Xubio Export
38. **Flatten for Xubio1** - Transforms data for Xubio accounting system
39. **Add Row per Bill/Line/Perception1** - Records detailed line items

## Key Features

- **Folder Organization**: Automatically organizes invoices into `Year/Month/Provider` structure
- **Duplicate Detection**: Approval Logic deduplicates invoices by number + supplier
- **Case-Insensitive Matching**: Pipol recipient check ignores case
- **Multi-Format Support**: Handles PDF, ZIP, and PNG files
- **Static Data Collection**: Uses workflow static data to collect files across loop iterations

## Integrations

| Service | Purpose |
|---------|---------|
| Google Drive | File monitoring, storage, and folder organization |
| Google Gemini 2.5 | AI document analysis and data extraction |
| Google Sheets | Client data, approvals tracking, Xubio export |
| Gmail | Approval notification emails |

## Nodes (41 total)

### Trigger & Intake
- Google Drive Trigger
- Filter PDF/ZIP/PNG
- Download File
- Is .ZIP?
- Decompress Zips
- Filter PDFs

### AI Processing
- Get Clients
- Get Client Email Map
- Analyze File
- Merge2
- Basic LLM Chain1
- Structured Output Parser1
- Gemini 2.5 Flash1
- Gemini 2.5 Pro1 (disabled)
- Merge3

### Validation
- Is Bill for Pipol?

### Folder Organization
- Move Files Loop (Loop Over Items)
- Search for Year Folder
- Year Folder Exists
- Create Year Folder
- Merge
- Search Month Folder
- Month Folder Exists
- Create Month Folder
- Merge1
- Search Provider Folder
- Provider Folder Exists
- Create Provider Folder
- Merge4
- Move file
- Collect Moved File
- Get All Moved Files

### Approval Workflow
- Approval Logic1
- Prepare Share Permisions
- Permissions Loop (Loop Over Items1)
- Wait
- Share file
- Add Row in Approval Sheet1
- Send a message1

### Xubio Export
- Flatten for Xubio1
- Add Row per Bill/Line/Perception1

### Disabled
- Upload Bills to Drive1 (replaced by folder organization circuit)
- Delete folder (utility node)
