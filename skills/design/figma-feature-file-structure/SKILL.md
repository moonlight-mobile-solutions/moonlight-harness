---
name: figma-feature-file-structure
description: "How to organize and maintain an app's Figma design file so it never promises more than the code does: page per feature, status Sections (App hoje / Aprovado / Proposta / Arquivo) tied to issues, the lifecycle from proposal to shipped, and the traps when building app screens from code through the Figma MCP (`use_figma`). Invoke when creating, reorganizing or updating screens in a product's Figma file, moving designs between statuses after an approval or a merge, or opening a design issue."
---

# Figma File by Feature, with Status Sections

## Why

A design file that mixes shipped screens with proposals ends up lying: people implement from a screen that was never approved, or assume the app already does what a mockup shows. The fix is a fixed structure where every screen sits in a **Section whose name says its status and the issue behind it**, and screens move between statuses only on real events (approval, merge).

## Pages

| Page | Content |
|---|---|
| `Leia-me` | How the file works, the status legend and the lifecycle below. Keep it current. |
| `Components` | The library: variables (colors with every theme mode, spacing, radius), text styles and components. Screens use only these. One Section per category (e.g. Fundamentos, Ações, Campos, Navegação, Conteúdo, Feedback, plus feature-specific ones), each component with its name and the code widget written above it, laid out on a grid with fixed gaps. New components go into their category's Section in a free slot, never on top of another; a single catch-all Section ends up as an overlapping pile. |
| `———` | Separator page (empty). |
| One page per feature | Named after the feature (`Login`, `Onboarding`, `Perfil`, `Busca`...). A new feature gets a new page. No catch-all "Screens" page. |
| `———` | Separator page. |
| `Arquivo` | Screens the app no longer uses. Nothing is deleted. |

## Status Sections

Inside a feature page, every group of screens lives in a Figma **Section**. The name and fill color encode the status:

| Status | Section name | Fill |
|---|---|---|
| Shipped | `App hoje` | green `#E0F5E3` |
| Approved, waiting for code | `Aprovado: #NNN Nome → implementar na #MMM` | yellow `#FFF5CC` |
| In review | `Proposta: #NNN Nome` | blue `#E0EBFF` |
| Replaced | moved to the `Arquivo` page, in a Section `Substituído por #NNN (data)` | gray `#EDEDED` |

`#NNN` is the design issue, `#MMM` the implementation issue. Put a short note inside approved Sections (approval date, which issue implements it, what moves to `Arquivo` when it ships). Mark approved Sections as **Ready for dev** in Dev Mode: the Plugin API cannot set `devStatus` (it throws "not a supported API"), so this is a manual click; say so to the user.

A screen that spans two features (e.g. a profile edit reused from onboarding) goes on the page where the user reaches it, with a note pointing to the other page.

## Lifecycle

1. **Proposal**: open a design issue (Issue Type `Task`, label `design`, sub-issue of the implementation issue when it blocks one). Build the screens in a blue `Proposta: #NNN` Section on the feature page. Keep the current screen visible next to it (in `App hoje`) for comparison.
2. **Approval**: rename/recolor the Section to yellow `Aprovado: #NNN → implementar na #MMM`, comment on the design issue with the file link and the decisions the implementation must follow (new strings, scope changes), tick its acceptance criteria and close it.
3. **Shipped**: when the PR of `#MMM` is merged, the Section becomes green `App hoje`, and the screens it replaces move to `Arquivo` in a `Substituído por #MMM (data)` Section.

Screens only become `App hoje` when the code exists. Never promote on approval.

## Building app screens from code (Figma MCP)

Load `figma-use` (and `figma-generate-design` for screens, `figma-generate-library` for components) before any `use_figma` call. On top of those:

- **Reference = the running app.** Capture each state from a device or emulator with test data (fakes/mock server), and compare the Figma render to it. Measure colors from both screenshots (darkest pixel of a text, a border) instead of eyeballing.
- **Convert to dp**: device px divided by the density (e.g. 1080 px wide at 2.625 = 412 dp frame). Account for tap targets: Flutter chips and buttons reserve 48 dp, so visual gaps are bigger than the widget spacing in code.
- **Screens are instances, not drawings.** Every control is an instance of a `Components` component; colors bound to variables, text in the library text styles. Componentize anything that repeats.
- **Bound colors need a real base color.** Pass the resolved value to `setBoundVariableForPaint` (`{color: resolvedRGB}`), never black: some renders fall back to the base color and show black blocks.
- **Paint opacity on bound colors is not inherited by instances.** A main component with `onSurface` at 12% shows 100% in its instances. Create alpha variables instead (`States/On Surface 12%`, `States/On Surface 38%`, `States/Primary 40%`, one value per mode with the alpha baked in) and bind those. Fixed overlays (scrim) can use plain black with opacity.
- **`resize()` resets auto-layout sizing to FIXED**: set `primaryAxisSizingMode = 'AUTO'` again after resizing a hugging component, or variants collapse and overlap.
- **Text properties and auto width**: chips/labels must use `textAutoResize = 'WIDTH_AND_HEIGHT'` so instances grow with overridden text.
- **Floating labels** positioned at `y < 0` need `clipsContent = false` up the chain and some top padding in the parent component.
- **Brand fonts** not in Figma's catalog are invisible to the MCP even when installed on the Mac; they must be uploaded as team/shared fonts. Families can come with odd style names (e.g. `Gilroy-Regular / ☞`): read them with `listAvailableFontsAsync()`.
- **Icons**: if the app uses Material icons, a component holding a `Material Icons` (font) glyph with a text property for the ligature name covers every icon (`Icons.calendar_month` → `calendar_month`).
- **Frames**: device width, fixed 917-ish height for single-screen states (bottom bars pinned with a growing spacer), full height when the screen scrolls.
- **Texts in the product language**, copied from the app's localization files, not invented.

## Hygiene

- Keep a state ledger (node ids of pages, Sections, components) in a scratch file during long builds; ids are not stable across sessions otherwise.
- Remove only scaffolding you created (duplicates, temporary labels); never delete user nodes by name prefix.
- After any restructure, update the `Leia-me` page.
