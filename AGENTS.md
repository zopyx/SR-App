# SR Radio Player - Agent Guide

## Project Overview

A native macOS/iOS radio player for Saarländischer Rundfunk (SR) stations, built with:
- **Frontend**: React 19 + TypeScript + Vite
- **Backend**: Tauri v2 (Rust)
- **UI**: Native macOS vibrancy effects

### Supported Stations
- **SR1 Europawelle** (Red) - News and pop music
- **SR2 KulturRadio** (Gold) - Culture and classical music  
- **SR3 Saarlandwelle** (Blue) - Regional music

## Architecture

```
sr2/
├── src/                      # React frontend
│   ├── components/
│   │   ├── RadioPlayer.tsx   # Main player component
│   │   └── AboutDialog.tsx   # About modal
│   ├── data/
│   │   └── stations.ts       # Station definitions
│   ├── App.tsx               # Root component
│   └── index.css             # Global styles
├── src-tauri/                # Rust backend
│   ├── src/
│   │   ├── main.rs           # Desktop entry point
│   │   └── lib.rs            # Shared library
│   ├── Cargo.toml            # Rust dependencies
│   └── tauri.conf.json       # Tauri configuration
├── public/                   # Static assets
│   ├── sr1_logo.png
│   ├── sr2_logo.png
│   └── sr3_logo.png
└── package.json
```

## Key Features

| Feature | Implementation |
|---------|---------------|
| Station switching | Dropdown selector with auto-play |
| Volume control | Range slider (0-100%) |
| Play/Pause | Click logo or Space key |
| About dialog | ℹ button + native menu |
| Keyboard shortcuts | Space, Cmd+Q, Cmd+M |
| Visual effects | Glass morphism, equalizer animation |

## Coding Conventions

### TypeScript
- Use strict types, avoid `any`
- Prefer interfaces over types
- Use functional components with hooks
- Export components as named exports

### CSS
- Use CSS variables for theming
- Mobile-first responsive design
- macOS vibrancy: `backdrop-filter: blur(20px)`
- Station colors via CSS custom properties

### Rust
- Follow Rust naming conventions
- Use `?` operator for error handling
- Platform-specific code behind `#[cfg(target_os = "macos")]`

## Development Commands

```bash
# Development (hot reload)
npm run tauri:dev

# Build release
npm run tauri:build

# Build universal macOS binary
npm run tauri:build:universal
```

## UI Patterns

### Color Scheme
- Background: `rgba(30, 30, 30, 0.65)` with blur
- Text primary: `rgba(255, 255, 255, 0.95)`
- Text secondary: `rgba(255, 255, 255, 0.6)`
- Station colors: SR1=#e60005, SR2=#ffb700, SR3=#0082c9

### Animations
- Use `cubic-bezier(0.34, 1.56, 0.64, 1)` for spring effects
- Respect `prefers-reduced-motion`
- Duration: 150ms fast, 250ms base, 400ms slow

## Adding New Stations

1. Add to `src/data/stations.ts`:
```typescript
{
  id: 'sr4',
  name: 'SR 4',
  shortName: 'SR4',
  description: 'Description',
  streamUrl: 'https://...',
  logoUrl: '/sr4_logo.png',
  color: '#00ff00',
  website: 'https://...'
}
```

2. Add logo to `public/`

## Common Tasks

### Update stream URLs
Edit `src/data/stations.ts` - URLs use `liveradio.sr.de` CDN

### Modify player behavior
Edit `src/components/RadioPlayer.tsx`
- `attemptPlay()` - Playback logic
- `handleStationSelect()` - Station switching

### Add keyboard shortcuts
Edit `src-tauri/src/lib.rs` for global shortcuts
Edit component `onKeyDown` handlers for local shortcuts

### Style the UI
Edit `src/index.css` - uses CSS variables for consistency

## Testing

Test on macOS with:
- Light/Dark mode
- Different window sizes (400x600 fixed)
- Keyboard navigation (Tab, Space, Enter)
- Multiple stations switching

## Build Output

```
src-tauri/target/release/bundle/
├── macos/SR2 Radio.app      # Main app bundle
└── dmg/                     # Installer (optional)
```

## Known Limitations

- iOS build needs proper bundle ID setup for device deployment
- Stream requires internet connection (no offline mode)
- Volume is app-level, not system-level

## Agent Workflow (Yolo Mode)

This project uses **Yolo Mode** - agents should be decisive and make minimal changes to achieve goals efficiently.

### Using Subagents

For parallel task execution, use the `Task` tool to spawn subagents:

**When to use subagents:**
- Multiple independent file modifications
- Parallel research or fact-checking
- Testing different approaches simultaneously
- Large refactoring tasks that can be split

**Example - Parallel file updates:**
```typescript
// Update multiple components in parallel
const tasks = [
  { path: 'src/components/Button.tsx', description: 'Update Button styles' },
  { path: 'src/components/Input.tsx', description: 'Update Input styles' },
  { path: 'src/components/Modal.tsx', description: 'Update Modal styles' }
];

// Spawn subagents for each task
```

**Best practices:**
- Spawn subagents for independent tasks only
- Provide complete context in the prompt (subagents don't see your history)
- Use descriptive task descriptions (3-5 words)
- Limit parallel tasks to avoid context overflow

### Testing Requirements

**Write a test for every bug fix or regression:**
- When fixing a bug, add a test that reproduces the issue
- When modifying behavior, update or add tests
- Tests prevent regressions and document expected behavior
- Run `npm test` before committing changes

**Use red/green TDD:**
- Write failing test first (red)
- Implement minimal code to make it pass (green)
- Refactor while keeping tests passing
- This ensures tests actually verify the behavior

**Example workflow:**
```
1. Identify bug → Write failing test (red) → Fix bug (green) → Refactor
2. Add feature → Write failing test (red) → Implement (green) → Refactor
```

### Git Workflow

**Do not commit and push at your own will:**
- Only commit and push when explicitly requested by the user
- Wait for user confirmation before making git mutations
- This applies even if changes are complete and tests pass

**No commit, no push if tests are failing:**
- Always run tests before committing
- All tests must pass before commit and push
- Fix failing tests first, then commit

**Optional CI/CD local check:**
- You can run `act` to test CI/CD workflows locally before committing and pushing

### UI Constraints

**No scrolling in default window:**
- All UI elements must fit within the fixed window size (320x480)
- No overflow-y or scrollbars in the main player view
- Content must be responsive and scale appropriately
- Use compact mode or truncation for long text
- Test layout at minimum window size

## Resources

- [Tauri Docs](https://tauri.app/v2/api/)
- [SR Streams](https://www.sr.de/sr/home/radio/index.html)
- Design: macOS Human Interface Guidelines
