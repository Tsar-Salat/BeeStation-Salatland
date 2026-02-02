# SMES Overlays & Emissive System

## Overview

The SMES (Superconducting Magnetic Energy Storage) unit uses a **dual-overlay pattern** for its visual indicators. For each visual state change (charging, outputting, charge level), the system adds two overlays:

1. A **visible overlay** — the standard image that players see under normal lighting
2. An **emissive overlay** — a special overlay that "glows" and remains visible even in complete darkness

This allows machine status lights and indicators to be readable regardless of ambient lighting conditions.

---

## How the Dual-Overlay Pattern Works

When the SMES updates its icon, it follows this pattern for each indicator:

```dm
// Add the emissive version (glows in the dark)
AddOverlays(emissive_appearance(icon, "icon-state-name"))

// Add the visible version (normal appearance)
AddOverlays(image(overlay_icon, "icon-state-name"))
```

Both overlays use the same icon state, but they render on different planes and serve different purposes.

---

## The Emissive Rendering System

### What Are Emissives?

Emissives are a rendering trick that allows certain overlays to "punch through" darkness. They appear to glow or emit light, making them visible even when the lighting system would otherwise hide them.

### How It Works (Technical)

The emissive system exploits BYOND's color matrix filter to handle light-emitting overlays:

1. **Emissive overlays** are created using `emissive_appearance()`, which:
   - Places them on a dedicated `EMISSIVE_PLANE` (a separate rendering layer)
   - Applies a special color matrix (`EMISSIVE_COLOR`) that converts the icon to a specific color value
   - Uses `BLEND_OVERLAY` blend mode

2. **Emissive blockers** can be created using `emissive_blocker()` for objects that should block emissive light (like opaque objects in front of a glowing screen)

3. **Rendering pipeline**:
   - Emissive overlays and blockers both go onto the same plane
   - Normal BYOND layering causes them to mask each other appropriately
   - A color matrix filter (`EM_MASK_MATRIX`) is applied to isolate emissive pixels
   - The resulting mask is used to alpha-mask the lighting plane
   - This creates the "glow through darkness" visual effect

### Color Matrices Used

| Matrix | Purpose |
|--------|---------|
| `EMISSIVE_COLOR` | Converts emissive overlays to a trackable color |
| `EM_BLOCK_COLOR` | Converts blocker overlays to a different trackable color |
| `EM_MASK_MATRIX` | Filters out everything except emissive pixels |

These matrices are designed to not overlap in RGB space, allowing the renderer to distinguish between emissive sources and blockers.

---

## SMES Icon States

The SMES uses several icon state prefixes for its overlays:

| Prefix | Purpose | States |
|--------|---------|--------|
| `smes-op` | **Output** indicator | `0` = off, `1` = outputting, `2` = high output |
| `smes-oc` | **Input/Charging** indicator | `0` = standby, `1` = charging, `2` = high charge rate |
| `smes-og` | **Charge gauge** (level) | `1` through `5` (1 = nearly empty, 5 = full) |
| `smes-panel` | Open maintenance panel | Single state (not emissive) |

The charge gauge uses `chargedisplay()` to calculate which level (1-5) to show based on current charge vs. capacity.

---

## Implementation Example

Here's a simplified example of how the SMES builds its overlays:

```dm
/obj/machinery/power/smes/on_update_icon()
    ClearOverlays()
    
    if(MACHINE_IS_BROKEN(src))
        return
    
    // Output status indicator
    AddOverlays(emissive_appearance(icon, "smes-op[outputting]"))
    AddOverlays(image(overlay_icon, "smes-op[outputting]"))
    
    // Input/charging indicator (only if actively charging)
    if(inputting == 2)
        AddOverlays(emissive_appearance(icon, "smes-oc2"))
        AddOverlays(image(overlay_icon, "smes-oc2"))
    else if(inputting == 1)
        AddOverlays(emissive_appearance(icon, "smes-oc1"))
        AddOverlays(image(overlay_icon, "smes-oc1"))
    else if(input_attempt)
        AddOverlays(emissive_appearance(icon, "smes-oc0"))
        AddOverlays(image(overlay_icon, "smes-oc0"))
    
    // Charge level gauge
    var/clevel = chargedisplay()  // Returns 0-5
    if(clevel)
        AddOverlays(emissive_appearance(icon, "smes-og[clevel]"))
        AddOverlays(image(overlay_icon, "smes-og[clevel]"))
    
    // Maintenance panel (not emissive - doesn't glow)
    if(panel_open)
        AddOverlays(image(overlay_icon, "smes-panel"))
```

---

## Best Practices

### When to Use Emissives

- Status indicator lights (LEDs, screens, gauges)
- Self-illuminating displays
- Any element that should be visible in darkness

### When NOT to Use Emissives

- Structural elements (panels, frames, handles)
- Elements that rely on ambient light to be visible
- Decorative elements without a light source

### Adding Emissives to New Machines

If you're adding emissive indicators to a machine:

```dm
// Always add BOTH overlays for lit elements
AddOverlays(emissive_appearance(icon, "your-light-state"))  // Glow effect
AddOverlays(image(icon, "your-light-state"))               // Visible sprite

// Non-lit elements only need the regular overlay
AddOverlays(image(icon, "your-panel-state"))
```

---

## Related Systems

- **Lighting System** — The emissive plane interacts with the lighting plane to create the glow-through-darkness effect
- **Render Targets** — Emissives use BYOND's render target system for compositing
- **Color Matrix Filters** — The core mechanism that makes emissive separation possible
