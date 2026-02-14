# Faye

Reactive UI toolkit for Roblox built in Luau. Not a framework with a virtual DOM — works directly with native Roblox instances as a lifecycle and reactivity toolkit.

## Project Structure

- `src/init.luau` — Main entry point, Thread class and all API exports
- `src/FayeTypes.luau` — Luau type definitions (50+ exported types)
- `src/Value.luau` — Reactive value system
- `src/Animation.luau` — Animation/tweening system
- `src/Create/` — Instance creation and defaults
- `src/Compile/` — Property compilation system with type-specific compilers
- `src/Signal/` — Signal handling (wraps SimpleSignal)
- `src/Misc/` — Utilities, base classes, FayeInstance wrapper
- `docs/` — Markdown documentation
- `Packages/` — Wally dependencies (SimpleSignal)

## Tooling

- **Language:** Luau
- **Package manager:** Wally (`wally.toml`)
- **Build tool:** Rojo 7.5.1 (`default.project.json` for dev, `pack.project.json` for release)
- **Toolchain:** Rokit (`rokit.toml`)
- **Docs:** Moonwave (`package.json`)
- **Dependency:** `mountaindouw/simplesignal@1.2.1`

## Architecture

Everything flows through the **Thread** object:

```lua
local Thread = Faye.new()
Thread:Create("Frame") { ... }   -- Create instances
Thread:Value(initial)             -- Reactive values
Thread:Animation(goal, info)     -- Animations
Thread:Destroy()                 -- Clean everything
```

**Compilation system** (`src/Compile/`) recursively processes property tables, dispatching to type-specific compilers (Values, Animations, States, Signals, Events). Simple property assignments return raw Instances; complex ones (functions, animations, nested props) return a `FayeInstance` wrapper.

**Cleanup** is three-tiered: priority items (connections) first, regular items in reverse order, then child threads recursively.

## Code Conventions

- String constants cached in locals for memory optimization: `local destroytxt = "Destroy"`
- `typeof()` cached as `tof`
- Metatable-based OOP: `mt.__index = mt` pattern
- Counter-based unique IDs: `idtxt..counter`
- No virtual DOM — all operations work on real Roblox Instances
- Types are comprehensive and exported from `FayeTypes.luau`

## Key Modules

| Module | Role |
|--------|------|
| `init.luau` | Thread class, public API surface |
| `Value.luau` / `Misc/ValueBase.luau` | Reactive values with `.Changed` signals |
| `Animation.luau` / `LoadAnimation.luau` | Reactive and one-off tweens, spring physics |
| `Compile/init.luau` | Recursive property compilation |
| `Create/init.luau` | Instance creation with property compilation |
| `Configure.luau` | Wraps existing instances |
| `Space.luau` | Task batching |
| `Iterate.luau` / `AdvancedIterate.luau` | Reactive table iteration |
| `Clean.luau` | Cleanup dispatcher (Instances, Connections, Functions, Tables, Threads) |

## Version

Current: 2.2.1 — published via Wally (`mountaindouw/faye@2.2.1`), Roblox Toolbox, and GitHub Releases.
