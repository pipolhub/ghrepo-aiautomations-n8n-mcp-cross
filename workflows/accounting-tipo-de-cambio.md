# Accounting - Tipo de Cambio

**ID:** `RLukfx7b8HMpfqJC`
**Status:** Active
**Created:** 2025-11-13
**Last Updated:** 2025-12-23

## Overview

This workflow automatically fetches daily exchange rates for USD/ARS (Argentine Peso) from multiple sources and records them in a Google Sheets spreadsheet for accounting purposes. It retrieves both the official BNA (Banco Nacion Argentina) rate and the MEP (electronic payment market) rate.

## Trigger

- **Schedule Trigger** - Runs daily at 10:00 PM (22:00)

## Workflow Flow

1. **Schedule Trigger** - Triggers at 10 PM daily
2. **USDARS BNA Request** - Fetches USD/ARS rate from Banco Nacion via Ambito API
3. **USDARS MEP Request** - Fetches USD/ARS MEP rate via Ambito API
4. **Merge** - Combines both exchange rate responses
5. **Code in JavaScript** - Processes and validates the exchange rate data
   - Validates that data is from today's date
   - Formats date and extracts rate values
   - Returns structured data with BNA and MEP rates
6. **Append or update row in sheet** - Updates Google Sheets with:
   - Fecha (Date)
   - USDARS BNA Vendedor (Official selling rate)
   - USDARS MEP Ultimo (MEP rate)
   - USDBRL Vendedor (USD/BRL rate via GOOGLEFINANCE formula)

## Data Sources

- **Ambito Financiero API** - `mercados.ambito.com`
  - `/dolarnacion/grafico/` - Official BNA exchange rate
  - `/dolarrava/mep/grafico/` - MEP exchange rate

## Output

Data is stored in the Google Sheets document: `Tipos de Cambio`
URL: https://docs.google.com/spreadsheets/d/10QDynjboLlmvrgzzGUhhEDijmZAJwoJL6yi0wNKvhnY

## Integrations

| Service | Purpose |
|---------|---------|
| HTTP Request | Fetch exchange rates from Ambito API |
| Google Sheets | Store exchange rate history |

## Nodes (6 total)

- Schedule Trigger
- USDARS BNA Request
- USDARS MEP Request
- Merge
- Code in JavaScript
- Append or update row in sheet
