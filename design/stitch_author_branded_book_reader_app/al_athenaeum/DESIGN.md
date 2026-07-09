---
name: Al-Athenaeum
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#404944'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#707974'
  outline-variant: '#bfc9c3'
  surface-tint: '#2b6954'
  primary: '#003527'
  on-primary: '#ffffff'
  primary-container: '#064e3b'
  on-primary-container: '#80bea6'
  inverse-primary: '#95d3ba'
  secondary: '#9b4500'
  on-secondary: '#ffffff'
  secondary-container: '#fd8a42'
  on-secondary-container: '#682c00'
  tertiary: '#2d2e2c'
  on-tertiary: '#ffffff'
  tertiary-container: '#444442'
  on-tertiary-container: '#b2b1ae'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b0f0d6'
  primary-fixed-dim: '#95d3ba'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#0b513d'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb68e'
  on-secondary-fixed: '#331200'
  on-secondary-fixed-variant: '#763300'
  tertiary-fixed: '#e4e2de'
  tertiary-fixed-dim: '#c8c6c3'
  on-tertiary-fixed: '#1b1c1a'
  on-tertiary-fixed-variant: '#474744'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
typography:
  display-lg:
    fontFamily: Noto Serif Ethiopic
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 60px
  display-lg-mobile:
    fontFamily: Noto Serif Ethiopic
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Noto Serif Ethiopic
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-reading:
    fontFamily: Noto Serif Ethiopic
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 32px
  arabic-citation:
    fontFamily: Amiri
    fontSize: 22px
    fontWeight: '400'
    lineHeight: 40px
  label-sm:
    fontFamily: Source Sans 3
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1120px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style
The design system is a digital sanctuary for Islamic scholarship, specifically tailored for the Amharic-speaking community. It draws from the **Classical Islamic** and **Ethiopian Manuscript** traditions, blending historical prestige with modern accessibility. The aesthetic is a refined mix of **Minimalism** and **Tactile/Skeuomorphic** elements, where whitespace serves as a "breath of silence" for contemplation, while subtle parchment textures and geometric patterns provide a sense of physical permanence.

The target audience includes scholars, students of knowledge, and the faithful seeking a premium, focused reading environment. The UI should evoke an emotional response of serenity, reverence, and intellectual clarity. Visual elements should feel "curated" rather than "generated," emphasizing the sacred nature of the texts housed within.

## Colors
The palette is rooted in the symbolism of Islamic art and the materiality of ancient manuscripts.
- **Deep Emerald (#064E3B):** The primary color, representing growth and the traditional color of the Ummah. Used for key navigation, primary actions, and branding.
- **Rich Gold (#B45309):** The secondary color, used sparingly for accents, highlights, and secondary buttons to signify "illumination" (Tazhib).
- **Warm Parchment (#FDFBF7):** The surface color. It is a soft, off-white hue that reduces eye strain during long reading sessions and mimics high-quality paper.
- **Ink Charcoal (#1F2937):** The neutral color for primary text, providing high contrast without the harshness of pure black.

Secondary surfaces use a slightly darker "Aged Parchment" (#F3EFE7) to create subtle contrast between the page and the background container.

## Typography
The typography system prioritizes the rhythm and flow of Ethiopic and Arabic scripts. 
- **Noto Serif Ethiopic** is the cornerstone, providing a dignified and scholarly feel for Amharic text. 
- **Amiri** is utilized for Arabic religious citations; it is scaled larger than the surrounding Amharic text (22px vs 18px) to account for the intricate x-height of the Arabic script and to ensure diacritics (Tashkeel) remain legible.
- **Source Sans 3** is used for functional labels and metadata to provide a clean, modern counterpoint to the decorative serif text.

Line heights are intentionally generous (1.6x to 1.8x for body text) to accommodate the vertical complexity of both Ethiopic and Arabic characters, ensuring a comfortable reading experience for dense theological texts.

## Layout & Spacing
The layout follows a **Fixed Grid** philosophy on desktop to mimic the proportions of a physical book. Content is centered with wide margins to promote focus. 
- **Desktop:** 12-column grid within a 1120px container. Large "meditation margins" are encouraged.
- **Mobile:** A single-column flow with 16px side margins. 
- **Vertical Rhythm:** A strict 8px baseline grid is used. Spacing between paragraphs and sections should be generous to signify the transition between different thoughts or chapters.

Navigation should be persistent but unobtrusive, allowing the manuscript content to remain the focal point.

## Elevation & Depth
Depth is conveyed through **Tonal Layers** and **Low-Contrast Outlines** rather than aggressive shadows. 
- **The Page:** The main reading area is the highest "visual" elevation, often styled as a card with a subtle 1px border (#E5E7EB) and no shadow, sitting atop the slightly darker Parchment background.
- **Overlays:** Modals and menus use a soft, diffused "Sacred Shadow" (8% opacity of the Deep Emerald color) to feel like a light object resting on paper.
- **Separators:** Instead of harsh lines, use thin, elegant dividers with a central geometric motif (like an 8-pointed star) to break up long sections of text.

## Shapes
The shape language is **Soft (0.25rem)**. While modern, the slight rounding of corners mimics the natural wear of aged manuscript pages. 
- **Interactive Elements:** Buttons and input fields use a consistent 4px (Soft) radius.
- **Decorative Elements:** Use 45-degree rotations and 8-pointed geometric containers for icons and pagination indicators to reflect Islamic architectural influences.
- **Containers:** Large cards (like book covers) use the `rounded-lg` (0.5rem) setting to feel substantial.

## Components
- **Buttons:** Primary buttons are Solid Emerald with Gold text. Secondary buttons are Gold outlines with Emerald text. Hover states should involve a subtle shift in tonal warmth rather than a change in brightness.
- **Cards:** Used for book entries. They should feature a "spine" accent (a 4px vertical bar of Emerald or Gold on the left/right side depending on the text direction).
- **Arabic Citations:** Specialized components for Quranic verses or Hadith. These should be centered, wrapped in a subtle decorative frame, and set in the 'Amiri' font with a slightly larger font size.
- **Reading Progress:** A thin, Gold progress bar at the top of the viewport that fills as the user scrolls through a manuscript.
- **Inputs:** Search fields should be minimalist, using an underline style rather than a full box to maintain the "ink on paper" aesthetic.
- **Chips:** Used for "Topic Tags" (e.g., Fiqh, Akidah). These should use the Aged Parchment background with Emerald text and no border.