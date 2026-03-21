# Visual Regression Tests

This directory contains visual regression tests using Playwright.

## Running Tests

```bash
# Run all visual tests
npm run test:visual

# Update baseline screenshots
npm run test:visual:update

# Run with UI mode for debugging
npm run test:visual:ui
```

## Test Coverage

### Main Screen (`main-screen.spec.ts`)
- Default view
- Station selector open
- Hover states
- No visual regression

### About Screen (`about-screen.spec.ts`)
- Default view
- Stations section
- App information section
- Scrolling behavior
- No content overflow
- Clickable station cards

### Compact Mode (`compact-mode.spec.ts`)
- Minimized view
- Elements visibility
- Responsive layout at 320x400

## Screenshots

Baseline screenshots are stored in `__snapshots__/` directories next to each test file.

## Adding New Tests

1. Create a new `.spec.ts` file in this directory
2. Use `page.setViewportSize({ width: 320, height: 400 })` to match app dimensions
3. Take screenshots with `expect(page).toHaveScreenshot('name.png')`
4. Run `npm run test:visual:update` to generate baselines
