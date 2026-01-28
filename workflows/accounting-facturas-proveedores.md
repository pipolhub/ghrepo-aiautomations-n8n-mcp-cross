# Accounting - Facturas Proveedores

**ID:** `7VTaZuudWnUdYv1s`
**Status:** Active
**Created:** 2025-11-10
**Last Updated:** 2026-01-27

## Overview

This workflow automates the processing of supplier invoices (facturas proveedores). It monitors Gmail for incoming invoices, extracts data using AI, processes attachments, and stores the information in Google Sheets while uploading documents to Google Drive.

## Triggers

- **Gmail Trigger** - Monitors incoming emails for invoice attachments
- **Schedule Trigger** - Runs periodic tasks

## Workflow Flow

1. **Gmail Trigger** - Receives emails with invoice attachments
2. **Split Attachments** - Separates multiple attachments from emails
3. **If1** - Conditional check for attachment types
4. **Decompress Zips** - Extracts files from ZIP archives
5. **Filter PDFs** - Filters for PDF invoice files
6. **Analyze document1** - AI-powered document analysis using Google Gemini
7. **Basic LLM Chain1** - Processes invoice data with Gemini 2.5 (Flash/Pro)
8. **Structured Output Parser1** - Parses AI output into structured data
9. **Merge2 / Merge3** - Combines data from multiple processing paths
10. **Get row(s) in sheet1** - Retrieves reference data from Google Sheets
11. **Code in JavaScript** - Custom data processing logic
12. **Approval Logic1** - Determines approval requirements
13. **If2** - Conditional routing based on approval status
14. **Upload Bills to Drive1** - Stores invoices in Google Drive
15. **Prepare Share Permissions** - Sets up file sharing
16. **Loop Over Items1 / Share file** - Shares files with appropriate users
17. **Add Row in Approval Sheet1** - Records pending approvals
18. **Flatten for Xubio1** - Prepares data for Xubio accounting system
19. **Add Row per Bill/Line/Perception1** - Records line items in sheets
20. **Send a message1** - Sends notification emails

## Integrations

| Service | Purpose |
|---------|---------|
| Gmail | Email monitoring and notifications |
| Google Gemini 2.5 | AI document analysis and data extraction |
| Google Sheets | Data storage and reference lookups |
| Google Drive | Document storage and sharing |

## Nodes (27 total)

- Gmail Trigger
- Split Attachments
- If1
- Decompress Zips
- Filter PDFs
- Get row(s) in sheet1
- Code in JavaScript
- Analyze document1
- Merge2
- Basic LLM Chain1
- Structured Output Parser1
- Gemini 2.5 Flash1
- Gemini 2.5 Pro1
- Merge3
- If2
- Upload Bills to Drive1
- Approval Logic1
- Send a message1
- Add Row in Approval Sheet1
- Flatten for Xubio1
- Add Row per Bill/Line/Perception1
- Prepare Share Permisions
- Loop Over Items1
- Wait
- Share file
- Schedule Trigger
- Search files and folders
