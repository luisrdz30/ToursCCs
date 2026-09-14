---
name: Vibrant Cultural Explorer
colors:
  surface: '#fff8f6'
  surface-dim: '#eed5cd'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1ed'
  surface-container: '#ffe9e3'
  surface-container-high: '#fde3db'
  surface-container-highest: '#f7ddd5'
  on-surface: '#261814'
  on-surface-variant: '#594139'
  inverse-surface: '#3c2d28'
  inverse-on-surface: '#ffede8'
  outline: '#8d7168'
  outline-variant: '#e1bfb5'
  surface-tint: '#ab3500'
  primary: '#ab3500'
  on-primary: '#ffffff'
  primary-container: '#ff6b35'
  on-primary-container: '#5f1900'
  inverse-primary: '#ffb59d'
  secondary: '#27657c'
  on-secondary: '#ffffff'
  secondary-container: '#a8e2fd'
  on-secondary-container: '#28667d'
  tertiary: '#00677e'
  on-tertiary: '#ffffff'
  tertiary-container: '#00a7cb'
  on-tertiary-container: '#003744'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd0'
  primary-fixed-dim: '#ffb59d'
  on-primary-fixed: '#390c00'
  on-primary-fixed-variant: '#832600'
  secondary-fixed: '#bce9ff'
  secondary-fixed-dim: '#95cfe9'
  on-secondary-fixed: '#001f29'
  on-secondary-fixed-variant: '#004d63'
  tertiary-fixed: '#b5ebff'
  tertiary-fixed-dim: '#59d5fb'
  on-tertiary-fixed: '#001f28'
  on-tertiary-fixed-variant: '#004e60'
  background: '#fff8f6'
  on-background: '#261814'
  surface-variant: '#f7ddd5'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 120px
---

## Brand & Style
The design system is built to evoke the excitement of discovery and the warmth of hospitality. It targets modern travelers who seek a blend of logistical reliability and cultural immersion. 

The aesthetic merges **Modern Minimalism** with **Tactile/Skeuomorphic** accents. While the layout remains clean and functional, interactive elements utilize high-quality shadows and soft rounding to feel "touchable." The emotional response should be one of optimism and ease, removing the stress of travel through a friendly, guiding interface.

## Colors
The palette is inspired by natural landscapes and local festivities. 
- **Primary (Sunset Orange):** Used for primary actions, calls to action, and active states. It drives energy and focus.
- **Secondary (Deep Teal):** Used for global navigation, headers, and grounded structural elements to provide a sense of stability and trust.
- **Accent (Sunshine Yellow):** Reserved for gamification, highlights, and secondary interactive cues.
- **Background (Soft Blue/Off-white):** A cool, neutral base that allows the vibrant primary colors to pop without causing eye fatigue.
- **Success (Emerald):** Specifically designated for progress tracking, completed milestones, and badge unlocks.

## Typography
This design system utilizes **Plus Jakarta Sans** for headings and UI labels to provide a soft, modern, and high-energy feel. Its rounded terminals complement the overall shape language. 

For long-form content, logistics details, and descriptions, **Be Vietnam Pro** is used. It offers exceptional legibility at smaller sizes and a contemporary "tech-forward" warmth that aligns with the friendly brand personality. Use bold weights sparingly for emphasis in body text to maintain a clean hierarchy.

## Layout & Spacing
The layout follows a **Fluid Grid** model with generous safe areas. 
- **Mobile:** A 4-column grid with 20px outside margins. Vertical rhythm is strictly based on 8px increments to maintain visual balance.
- **Desktop:** A 12-column grid centered with a maximum width of 1280px. 

Spacing is intentional and "airy," prioritizing whitespace to prevent information overload during travel. Group related content items (like "Time" and "Location") using `sm` (12px) spacing, while separating distinct content sections using `lg` (40px) spacing.

## Elevation & Depth
Depth is conveyed through **Ambient Shadows** rather than stark borders. The goal is to make cards and buttons appear to float slightly above the off-white background.

- **Level 1 (Cards/Inputs):** A soft, multi-layered shadow with a 15% opacity tint of the Secondary color (#004E64) to ground the element.
- **Level 2 (Interactive/Hover):** Increased blur and slightly more vertical offset (Y-axis) to indicate "lift" when a user interacts.
- **Mascota AI Widget:** This element uses the highest elevation tier, featuring a vibrant glow or high-diffusion shadow to signal its "floating" nature independent of the page scroll.

## Shapes
The shape language is extremely soft and approachable. A base roundedness of **20px (rounded-lg)** is the standard for content cards. 
- **Buttons and Chips:** Use "Pill-shaped" (Full Rounding) to maximize the friendly, modern aesthetic.
- **Logistics Containers:** May use 16px rounding to feel slightly more structured than purely creative cards, but should never have sharp corners.
- **Mascota IA:** Should be represented within a circular or organic, blob-like container to emphasize its personality.

## Components

### Mascota IA (Floating Widget)
A circular or organically shaped floating action button (FAB) located in the bottom-right. It should feature a subtle "breath" animation. Upon interaction, it expands into a chat bubble or a modal with rounded corners (32px).

### Navigation
- **Bottom Bar:** Uses a frosted glass effect (Glassmorphism) with high-contrast icons in Deep Teal. Active states use Sunset Orange with a small dot indicator.
- **Top Bar:** Transparent background on scroll, transitioning to solid Off-white with a Level 1 shadow upon scrolling down.

### Gamification & Progress
- **Sticker Album Cards:** Use a "slot" metaphor. Empty slots have a dashed border and 10% opacity; unlocked stickers have high saturation and a slight Level 2 elevation.
- **Progress Bars:** Thick (12px height), pill-shaped tracks in Off-white with the fill in Emerald (#06D6A0).

### Buttons & Fields
- **Primary Button:** Pill-shaped, Sunset Orange background, white text, bold weight. Includes a subtle inner-glow to feel tactile.
- **Input Fields:** Soft Blue background (matching the page background but 5% darker), 16px rounding, and a 2px Deep Teal border that appears only on focus.

### Content Cards
Elevated white containers with 24px internal padding. Logistics cards (flight/bus) use a vertical divider; culture cards prioritize high-quality imagery with text overlays using a gradient scrim for legibility.