---
name: Granada Colonial Modern
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf3'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d5e3fc'
  on-surface: '#0d1c2e'
  on-surface-variant: '#4f4633'
  inverse-surface: '#233144'
  inverse-on-surface: '#eaf1ff'
  outline: '#817660'
  outline-variant: '#d3c5ac'
  surface-tint: '#785a00'
  primary: '#785a00'
  on-primary: '#ffffff'
  primary-container: '#eab308'
  on-primary-container: '#604700'
  inverse-primary: '#f7be1d'
  secondary: '#a53c19'
  on-secondary: '#ffffff'
  secondary-container: '#fb7b54'
  on-secondary-container: '#6b1a00'
  tertiary: '#9b4427'
  on-tertiary: '#ffffff'
  tertiary-container: '#ffa488'
  on-tertiary-container: '#813116'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdf9a'
  primary-fixed-dim: '#f7be1d'
  on-primary-fixed: '#251a00'
  on-primary-fixed-variant: '#5a4300'
  secondary-fixed: '#ffdbd1'
  secondary-fixed-dim: '#ffb59f'
  on-secondary-fixed: '#3a0a00'
  on-secondary-fixed-variant: '#842503'
  tertiary-fixed: '#ffdbd0'
  tertiary-fixed-dim: '#ffb59e'
  on-tertiary-fixed: '#3a0b00'
  on-tertiary-fixed-variant: '#7c2d12'
  background: '#f8f9ff'
  on-background: '#0d1c2e'
  surface-variant: '#d5e3fc'
typography:
  headline-xl:
    fontFamily: Work Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Work Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-sm:
    fontFamily: Work Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1'
    letterSpacing: -0.02em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 20px
  margin: 32px
---

## Brand & Style

This design system bridges the gap between the historic charm of Granada, Nicaragua, and the rigorous functional demands of an ERP/POS environment. The brand personality is rooted in "Confianza Local" (Local Trust)—combining the reliability of a long-standing cultural landmark with the efficiency of modern inventory management.

The design style is **Corporate / Modern** with a **Tactile** twist. It utilizes the structured layout of professional SaaS applications but softens the digital "coldness" with a palette and material influence derived from colonial architecture. The user experience should feel like walking through a well-maintained courtyard: open, airy, organized, and grounded in warm, earthy permanence. 

Targeted at high-paced retail and warehouse staff, the UI prioritizes data density and legibility without sacrificing its distinct cultural identity.

## Colors

The palette is a direct reflection of Granada’s iconic facades and clay-tiled roofs.

- **Colonial Yellow (Primary):** A vibrant mustard used for primary actions, status highlights, and branding elements. It is energetic but sufficiently warm to prevent eye strain.
- **Terracotta Red (Secondary):** Inspired by clay roof tiles, this earth tone is used for critical warnings, important headers, or secondary navigational cues.
- **Warm Whites & Stone Grays:** The background (Stone 50) and surfaces (White) avoid the harshness of pure blue-ish grays, opting instead for a "parchment" or "stucco" feel that makes long hours of screen time more comfortable.
- **Semantic Colors:** Success is represented by a mossy green, and warnings utilize the secondary Terracotta to maintain a cohesive atmospheric profile.

## Typography

This design system employs a dual-font strategy to balance character with utility.

1.  **Work Sans (Headlines):** Chosen for its professional yet slightly quirky geometric nature, mirroring the bold lettering often found in traditional Nicaraguan signage.
2.  **Inter (Body & Data):** The industry standard for high-density ERP interfaces. It provides exceptional legibility for part numbers, quantities, and financial data.

The hierarchy is tight. We use `body-sm` as the primary engine for data tables and sidebars to maximize information density, while `headline-xl` is reserved for page titles and major dashboard metrics.

## Layout & Spacing

The layout follows a **Fixed-Fluid Hybrid** model. The sidebar remains a fixed width (260px) to provide a constant "anchor," while the main content area utilizes a fluid 12-column grid.

- **Rhythm:** An 8px base unit is used for component spacing, while 4px increments are used for tighter data layouts (tables and form groups).
- **Density:** The system defaults to a "Compact" density to accommodate the "Tornillo Flojo" inventory complexity.
- **Margins:** Large outer margins (32px) ensure the interface feels intentional and not cluttered, even when the data within the tables is dense.

## Elevation & Depth

To reflect the flat, sun-drenched surfaces of colonial walls, this design system avoids heavy shadows.

- **Tonal Layering:** Depth is primarily communicated through color shifts. The main background is Stone 50, while active cards and data containers are pure White.
- **Low-Contrast Outlines:** Instead of shadows, use 1px borders in `Stone 200` to define boundaries. 
- **The "Shadow Accent":** For floating elements like modals or dropdowns, use a single, sharp "clay-tinted" shadow. Instead of a neutral black shadow, use a very low-opacity Terracotta (#9A3412 at 8% opacity) to give a warm, ambient lift that feels integrated into the environment.

## Shapes

The shape language is **Soft (0.25rem)**. This mimics the slightly weathered but still sharp corners of hand-carved stone and wood found in Granada's historic district.

- **Standard Elements:** Buttons, inputs, and cards use a 4px radius.
- **Feature Elements:** Progress bars or promotional banners may use `rounded-lg` (8px) to stand out.
- **Strictness:** Avoid pill-shapes for functional POS elements; keep them rectangular to maintain a sense of structural integrity and professional order.

## Components

- **Buttons:** Primary buttons use Colonial Yellow with dark Slate text for maximum contrast. Secondary buttons use a Terracotta outline. The "sharp but clean" edge requirement is met with a consistent 4px radius and 1px border.
- **Input Fields:** Use a solid White background with a Stone 300 border. Upon focus, the border shifts to Colonial Yellow with a subtle 2px glow of the same color.
- **Data Tables:** These are the heart of the ERP. Use a "Zebra" stripe pattern with Stone 50. Row hover states should utilize a pale Colonial Yellow (#FEF9C3).
- **Chips/Badges:** Status chips (In Stock, Low Stock, Out of Order) use highly saturated versions of the palette with lowercase, bold labels.
- **Inventory Cards:** Used in the POS view. These should feature a top-heavy layout with the part image, followed by a bold price in Terracotta Red.
- **The "Tornillo" Sidebar:** The primary navigation should be dark (Slate 900) to contrast against the warm white content area, creating a clear mental model of "Navigation vs. Execution."