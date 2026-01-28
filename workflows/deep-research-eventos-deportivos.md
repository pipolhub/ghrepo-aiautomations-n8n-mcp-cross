# Deep Research Eventos Deportivos

**ID:** `4SiGZn7kGjDKYrKN`
**Status:** Active
**Created:** 2025-12-01
**Last Updated:** 2026-01-27

## Overview

This workflow performs automated deep research on sports events using AI-powered web search and analysis. It generates comprehensive reports about sporting events and delivers them via email.

## Trigger

- **Schedule Trigger** - Runs on a scheduled basis

## Workflow Flow

1. **Events Target** - Defines the target sports events to research
2. **Research Prompt / Search Prompt** - Sets up the research parameters and prompts
3. **Start Deep Research** - Initiates the deep research process via HTTP request
4. **Wait 25min** - Waits for the research to complete
5. **Retrieve Deep Research** - Fetches the completed research results
6. **Gemini Web Search** - Performs additional AI-powered web searches using Google Gemini
7. **Merge** - Combines results from multiple sources
8. **Consolidador de Reporte** - Consolidates findings into a comprehensive report using Gemini AI
9. **Email Formatter** - Formats the report for email delivery using Gemini AI
10. **HTML only extractor** - Extracts HTML content from the formatted report
11. **Send a message / Send a message1** - Delivers the final report via Gmail

## Error Handling

- **If1** - Conditional logic for error handling
- **Stop and Error** - Handles errors and stops execution when needed

## Integrations

| Service | Purpose |
|---------|---------|
| Google Gemini | AI-powered web search and report generation |
| Gmail | Email delivery of reports |
| HTTP Request | External deep research API |

## Nodes (16 total)

- Merge
- Gemini Web Search
- Consolidador de Reporte
- If1
- Send a message1
- Schedule Trigger1
- Research Prompt
- Stop and Error
- Email Formatter
- HTML only extractor
- Retrieve Deep Research
- Start Deep Research
- Events Target
- Search Prompt
- Wait 25min
- Send a message
