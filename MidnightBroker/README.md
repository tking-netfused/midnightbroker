# MidnightBroker

MidnightBroker is a Retail-focused World of Warcraft addon that provides:

- A standalone movable on-screen display for key stats
- Optional LibDataBroker data source output
- Per-element enable/disable, position persistence, and style customization

## Features

- Displays:
  - Current date + time (Time element)
  - Zone and subzone
  - Player coordinates
  - Durability
  - Total addon memory usage
  - Gold
  - Frame rate (FPS)
  - Latency
  - Broker metrics for Gold, Frame Rate, and Latency
- Every standalone element is independently configurable:
  - Enabled/disabled
  - Movable when unlocked
  - Position persistent across reloads
  - Font, font size, text color, background color, border color, alpha, and scale
  - Optional label/title visibility per element
- Graceful fallback when `LibDataBroker-1.1` is not available

## Install

1. Copy the `MidnightBroker` folder to your WoW addons directory:
   - `_retail_/Interface/AddOns/MidnightBroker`
2. Restart WoW or run `/reload`.
3. Configure with `/mb options`.

## Slash Commands

- `/mb` or `/midnightbroker` - show help
- `/mb options` - open the options panel
- `/mb lock` - lock display elements
- `/mb unlock` - unlock display elements for dragging
- `/mb toggle <time|zone|coords|durability|memory>` - toggle one element
- `/mb toggle <time|zone|coords|durability|memory|gold|fps|latency>` - toggle one element
- `/mb reset <time|zone|coords|durability|memory|gold|fps|latency|all>` - reset position(s)
- `/mb resetstyle <time|zone|coords|durability|memory|gold|fps|latency|all>` - reset style/color settings only

## Options UX Notes

- Font selection uses a built-in dropdown of WoW font choices (no external font library required).
- Font Size, Scale, and Alpha sliders display their current numeric values while adjusting.
- Label visibility can be toggled per selected element.
- Background and border visibility can be toggled per selected element.
- Element frame width auto-adjusts to content length (for example dynamic zone/subzone text), within safe min/max limits.
- Time element includes preset dropdowns for Date Format, Time Format, and Date/Time Layout.
- The single LibDataBroker text also includes Gold, FPS, and Latency.
- Broker tooltip shows Latency in `Home/World` format.
- Hovering the Memory standalone element shows a tooltip with loaded addons and current per-addon memory usage.
- Hovering the Latency standalone element shows a tooltip with separate Home and World latency values.
- Hovering the Durability standalone element shows per-item durability details for equipped gear.

## Configuration Model

Saved variable:

- `MidnightBrokerDB`

Data layout:

- `profile.unlocked` - global lock/unlock state
- `profile.brokerEnabled` - enables optional LDB source
- `profile.elements.<id>` - per-element config including style and position

Defaults are merged non-destructively at startup so new keys are added without removing user settings.

Recovery tip:

- If an element style becomes invalid/corrupted (for example invisible text/background/border),
  use `/mb resetstyle <element>` instead of deleting the entire saved variables file.

## Architecture

- `Core/` - bootstrap, constants, defaults, db merge, events, throttling, style helpers, slash commands
- `Display/` - runtime element manager
- `Elements/` - base element class + one module per metric
- `Broker/` - optional LibDataBroker integration
- `UI/` - options panel and reusable widget builders

## API Assumptions / Notes

- TOC `Interface` currently targets modern Retail (`120001`); bump as needed per patch.
- Coordinates use `C_Map.GetBestMapForUnit` and `C_Map.GetPlayerMapPosition`.
  - If those APIs change return shape in a future build, adjust `Elements/CoordsElement.lua`.
- Memory usage prefers `C_AddOns` API with fallback to legacy global APIs.
- Options panel registers through modern `Settings` API when available, with `InterfaceOptions` fallback.

## Verification Checklist (In-Game)

- `/reload` produces no Lua errors.
- All five elements render and update.
- Each element can be moved independently while unlocked.
- Positions persist through `/reload`.
- Style changes apply immediately and persist.
- `/mb toggle` and `/mb reset` work for each element and `all`.
- Broker text appears in LDB display launchers when `LibDataBroker-1.1` is present.
- Standalone UI still works fully when LDB is absent.
