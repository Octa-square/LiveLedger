# Quick Guide: Adding New Translations to LiveLedger

## Step 1: Add Localization Key

In `LocalizationManager.swift`, add your key to the `LocalizedKey` enum:

```swift
enum LocalizedKey: String {
    // ... existing keys ...
    case myNewKey = "my_new_key"
}
```

## Step 2: Add English Translation

In the `translations` dictionary, add to `.english`:

```swift
.english: [
    // ... existing translations ...
    .myNewKey: "My New Text in English"
]
```

## Step 3: Add Other Language Translations

Add to `.spanish`, `.french`, `.german`, etc.:

```swift
.spanish: [
    // ... existing translations ...
    .myNewKey: "Mi Nuevo Texto en Español"
],
.french: [
    // ... existing translations ...
    .myNewKey: "Mon Nouveau Texte en Français"
]
```

**Note**: If you skip a language, the English version will automatically be used as fallback!

## Step 4: Use in Your View

Replace hardcoded text with localized version:

```swift
// Before:
Text("My New Text")

// After:
Text(localization.localized(.myNewKey))
```

## Common Patterns

### Button Text
```swift
Button(localization.localized(.save)) {
    // action
}
```

### Section Headers
```swift
Section {
    // content
} header: {
    Text(localization.localized(.mySection))
}
```

### Navigation Titles
```swift
.navigationTitle(localization.localized(.myTitle))
```

### Alerts
```swift
.alert(localization.localized(.alertTitle), isPresented: $showAlert) {
    Button(localization.localized(.ok)) { }
} message: {
    Text(localization.localized(.alertMessage))
}
```

## Complete Translation Checklist

For each new feature, translate:
- [ ] All button labels
- [ ] All section headers
- [ ] All placeholder text
- [ ] All form labels
- [ ] All alert messages
- [ ] All navigation titles
- [ ] All hints and instructions
- [ ] All status messages

## Testing Your Translation

1. Run the app
2. Go to Settings → Language
3. Select the language you added
4. Navigate to your new feature
5. Verify all text appears in selected language
6. Try switching between languages
7. Check for any English text leaking through

## Translation Best Practices

### DO
✅ Keep translations concise
✅ Match the tone of existing translations
✅ Test with longest possible translation
✅ Consider cultural context
✅ Use native speakers when possible

### DON'T
❌ Translate brand names ("LiveLedger", "L²")
❌ Translate technical terms (CSV, PDF, etc.)
❌ Make translations too formal or casual
❌ Use machine translation without review
❌ Forget to test UI layout with long text

## Need Help?

- Check existing translations for similar phrases
- Use the English version as reference
- Test on device with selected language
- Ask native speakers to review
- Keep translations consistent across the app
