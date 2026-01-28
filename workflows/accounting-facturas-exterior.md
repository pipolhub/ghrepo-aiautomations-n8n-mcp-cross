# Accounting - Facturas Exterior

**ID:** `wx3RIlNGOC9Mj3iE`
**Status:** Active
**Created:** 2025-11-12
**Last Updated:** 2026-01-21

## Overview

This workflow automates the processing of international/exterior invoices (facturas exterior). It monitors Gmail for incoming invoices, uses AI to analyze and extract data from documents, manages approvals, and stores information in Google Sheets while uploading files to Google Drive.

## Trigger

- **Gmail Trigger** - Monitors incoming emails for invoice attachments

## Workflow Flow

1. **Gmail Trigger** - Receives emails with invoice attachments
2. **Split Attachments** - Separates multiple attachments
3. **Decompress Zips** - Extracts files from ZIP archives
4. **Filter PDFs** - Filters for PDF files
5. **Analyze Documents w/Filter** - AI document analysis using Google Gemini
6. **Basic LLM Chain** - Processes invoices with Gemini 2.5 (Flash/Pro)
7. **Structured Output Parser** - Parses AI output into structured data
8. **Get Accounts Info** - Retrieves account information from Google Sheets
9. **Create Accounts Mapping** - Creates account mappings for processing
10. **Merge / Merge1 / Merge2** - Combines data from multiple sources
11. **Flattening and Filtering / Flattening and Filtering full** - Data transformation
12. **Get Organization Data** - Retrieves organization information
13. **Extract Company Name** - Extracts company name from documents
14. **Get Company Map** - Maps companies to internal IDs
15. **Get Approver Data** - Retrieves approver information
16. **Build Client Email Map** - Creates email routing for clients
17. **Approval Logic** - Determines approval requirements
18. **If** - Conditional routing based on processing status
19. **Upload Bills to Drive** - Stores invoices in Google Drive
20. **Prepare Share Permissions** - Sets up file sharing
21. **Loop Over Items / Loop Over Items1** - Iterates for file sharing
22. **Share file** - Shares files with appropriate users
23. **Add Row / Add Row in Approval Sheet** - Records data in spreadsheets
24. **Send Mail to Approver** - Sends approval request emails
25. **Upload Non-Processable File** - Handles files that can't be processed
26. **Send Mail For Unprocessable Files** - Notifies about failed processing
27. **Delete a file** - Cleans up temporary files

## Integrations

| Service | Purpose |
|---------|---------|
| Gmail | Email monitoring and notifications |
| Google Gemini 2.5 | AI document analysis and data extraction |
| Google Sheets | Data storage and reference lookups |
| Google Drive | Document storage and sharing |

## Nodes (35 total)

- Gmail Trigger
- Basic LLM Chain
- Structured Output Parser
- Gemini 2.5 Flash
- Add Row
- Gemini 2.5 Pro
- Flattening and Filtering
- Analyze Documents w/Filter
- Get Accounts Info
- Create Accounts Mapping
- Merge
- Merge1
- Upload Bills to Drive
- Add Row in Approval Sheet
- Send Mail to Approver
- Approval Logic
- Get Organization Data
- Extract Company Name
- Get Company Map
- Loop Over Items
- Get Approver Data
- Merge2
- Build Client Email Map
- Flattening and Filtering full
- Upload Non-Processable File
- Send Mail For Unprocessable Files
- Delete a file
- Split Attachments
- Decompress Zips
- Filter PDFs
- Share file
- Prepare Share Permissions
- Loop Over Items1
- Wait
- If

## Notes

This is the more comprehensive version for handling international invoices, with additional logic for:
- Multi-company support
- Client email mapping
- Enhanced error handling for unprocessable files
- Organization and approver data lookups
