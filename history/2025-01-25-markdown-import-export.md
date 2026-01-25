# Markdown Import/Export Feature Design

**Date:** 2025-01-25
**Goal:** Enable users to edit checklists via browser LLM UI (ChatGPT/Claude) by copying/pasting markdown

## User Story

As a user, I want to export my checklists as markdown and import markdown from LLMs, so that I can:
- Ask an LLM to generate new checklists and import them into the app
- Export existing checklists, ask an LLM to refine/expand them, and re-import

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Check state in markdown | Ignore (all import as unchecked) | Simpler format, cleaner LLM interaction |
| UI location | Ellipsis menu in toolbar | Groups secondary actions, keeps plus button prominent |
| Export scope | All checklists at once | User requested bulk export |
| Import scope | Multiple checklists per paste | Match export capability |
| Export method | Copy to clipboard | Simple, predictable |
| Import method | Read from clipboard with preview | Quick workflow, user confirmation before adding |
| Import behavior | Upsert by name | Enables edit-via-LLM workflow without duplicates |

## Markdown Format

### Export Format

```markdown
# Checklist Name

- Item one
- Item two

# Another Checklist

- Item three
- Item four
```

### Import Parsing Rules

1. Lines starting with `# ` become checklist names
2. Lines starting with `-`, `*`, or `+` become items under the current checklist
3. Checkbox syntax (`[ ]` or `[x]`) is stripped, all items imported as unchecked
4. Empty lines and other content are ignored
5. Items before any heading go into a checklist named "Imported Checklist"
6. Empty checklists (header with no items) are preserved

## UI Flow

### Export

1. User taps ellipsis menu (⊙) → "Export to Clipboard"
2. All checklists are formatted as markdown
3. Markdown is copied to clipboard
4. Toast confirms: "Copied to clipboard"

### Import

1. User copies markdown from browser (ChatGPT/Claude)
2. Opens app, taps ellipsis menu (⊙) → "Import from Clipboard"
3. App reads clipboard and parses markdown
4. Preview sheet shows: list of checklist names with item counts and "update" or "new" badge
5. User taps "Import" to confirm or "Cancel" to abort
6. Checklists are upserted: existing lists (by name) are replaced, new lists are added

## Architecture

### New Files

**`MarkdownParser.swift`**
```swift
func parseMarkdown(_ text: String) -> [Checklist]
func formatMarkdown(_ checklists: [Checklist]) -> String
```

**`ImportPreviewView.swift`**
- SwiftUI sheet displaying parsed checklists before import
- Shows checklist names, item counts, and "update"/"new" badges
- "Import" and "Cancel" buttons

### Modified Files

**`ContentView.swift`**
- Add ellipsis menu (⊙) to toolbar with Export/Import actions
- Export: format → copy to clipboard → show toast
- Import: read clipboard → parse → show preview sheet → upsert to store

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No checklists to export | Disable export button or show "Nothing to export" |
| Empty clipboard on import | Alert: "Clipboard is empty" |
| No parseable items | Alert: "No checklist items found in clipboard" |
| Matching checklist name | Upsert: replace existing list with imported version |

## Data Flow

```
Export: store.lists → formatMarkdown() → UIPasteboard.general.string

Import: UIPasteboard.general.string → parseMarkdown() → ImportPreviewView → upsert into store.lists
```
