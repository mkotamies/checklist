# Card Preview Implementation Plan

**Goal:** Show checklist items with checkboxes inside the card preview to fill empty space.

**Approach:** Modify the card view in `ContentView.swift` to display checklist items below the title. Items will show checkbox icons (filled/empty) based on checked state. Cards remain square; items that don't fit are hidden. The count moves to the bottom.

---

### Task 1: Add item preview to card

**Files:**
- Modify: `ios/iOSApp/ContentView.swift` (lines 32-44)

**Steps:**
1. Replace the current VStack content with title, items preview, and count
2. Use `ForEach` to show first 4-5 items with checkbox icons
3. Position count at bottom using Spacer

**Code:**

Replace lines 32-44:
```swift
VStack(alignment: .leading, spacing: 6) {
    Text(list.name)
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(AppTheme.tileText)
        .lineLimit(2)
        .minimumScaleFactor(0.8)

    // Item preview
    let previewItems = Array(list.fields.prefix(5))
    ForEach(previewItems) { field in
        HStack(spacing: 6) {
            Image(systemName: field.isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(field.isChecked ? .green.opacity(0.7) : .gray.opacity(0.5))
            Text(field.name)
                .font(.system(size: 12))
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(1)
        }
    }

    Spacer()

    // Progress count
    let total = list.fields.count
    let done = list.fields.count(where: { $0.isChecked })
    Text("\(done)/\(total)")
        .foregroundColor(.black.opacity(0.5))
        .font(.caption)
}
```

---

### Task 2: Adjust padding for more item space

**Files:**
- Modify: `ios/iOSApp/ContentView.swift` (line 45)

**Steps:**
1. Reduce padding from 16 to 12 to fit more items

**Code:**

Change line 45:
```swift
.padding(12)
```

---

## Summary

- Cards show title + up to 5 checklist items + count
- Checkboxes reflect checked/unchecked state visually
- View-only (tapping card navigates to detail view)
- Square card shape preserved
