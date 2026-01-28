# My workflow

**ID:** `T1jlpnMxVfkhSRqF`
**Status:** Inactive (Archived)
**Created:** 2025-10-10
**Last Updated:** 2025-11-10

## Overview

An experimental workflow that monitors Gmail for specific emails and uses AI to extract structured information from email HTML content. This workflow appears to be a prototype for email parsing and information extraction.

## Trigger

- **Gmail Trigger** - Polls every 5 minutes for emails matching the filter `email.monitor.devstage@mia.tech`

## Workflow Flow

1. **Gmail Trigger** - Monitors inbox for matching emails (includes spam/trash)
2. **Information Extractor** - Uses LangChain to extract structured data from email HTML:
   - `action`: forgot_password or confirm_user
   - `user_full_name`: Full name from the greeting
3. **Google Gemini Chat Model** - Powers the information extraction (using AQA model)

## Integrations

| Service | Purpose |
|---------|---------|
| Gmail | Email monitoring |
| Google Gemini (PaLM) | AI-powered information extraction |
| LangChain | Information extraction chain |

## Nodes (3 total)

- Gmail Trigger
- Information Extractor
- Google Gemini Chat Model

## Notes

This workflow is archived and was likely used for testing email parsing functionality. The extraction focuses on identifying password reset vs user confirmation emails.
