# PaisaJi (Paisaजी) Official Brand Identity Guidelines

> **Version 4.0 — Unified Brand System (No Tagline)**  
> **Approved for:** Flutter Mobile Application, Website, Administration Portal, Marketing, and Enterprise Communications

---

## 1. Executive Summary & Brand Overview

**PaisaJi** is India's premier financial technology super platform, delivering seamless digital payments, utility management, credit discovery, and intelligent AI assistance across Bharat.

Under the definitive Brand Identity system, the brand identity has been refined for enterprise maturity and universal cross-platform clarity. **The tagline has been permanently removed across all visual marks, user interfaces, and codebases.** The visual identity is strictly anchored by the approved wordmark **Paisaजी** and the standalone **P + ₹ monogram**.

| Brand Attribute | Official Standard | Notes |
| :--- | :--- | :--- |
| **Official Brand Name** | **PaisaJi** | English capitalization: Capital 'P', Capital 'J'. Used in textual and legal documents. |
| **Official Logo Wordmark**| **Paisaजी** | English "Paisa" in Navy (`#0A2342`) + Hindi Devanagari "जी" in Bright Blue (`#007BFF`). |
| **Official Monogram** | **P + ₹ Monogram** | Integrated capital 'P' with Indian Rupee symbol '₹' curvature. |
| **Primary Navy** | `#0A2342` | RGB(10, 35, 66) — Represents trust, security, and institutional strength. |
| **Primary Blue** | `#007BFF` | RGB(0, 123, 255) — Represents digital innovation, speed, and modern accessibility. |
| **Tagline** | **None (Not Used)** | The slogan / tagline has been permanently retired. Do not add any replacement. |

---

## 2. Logo Family & Approved Variations

All logos are deployed from the approved master package without taglines. Bounding boxes, canvas padding, and visual centering have been mathematically recalculated to eliminate residual whitespace.

### A. Primary Horizontal Logo (`paisaji_primary.png`)
- **Composition**: P + ₹ monogram on the left, followed by the "Paisaजी" wordmark on the right.
- **Colorway**: Primary Navy (`#0A2342`) for the monogram body & "Paisa", Primary Blue (`#007BFF`) for the ₹ swoop & "जी".
- **Primary Usage**: Website desktop headers, app welcome screens, invoices, official letterheads, and horizontal banners.

### B. Horizontal Wordmark (`paisaji_wordmark.png`)
- **Composition**: "Paisa" in English (Navy) + "जी" in Devanagari (Bright Blue) without symbol.
- **Primary Usage**: In-app navigation bars, compact headers, mobile sticky headers, and editorial inline branding.

### C. Stacked Logo (`paisaji_stacked.png`)
- **Composition**: Centered P + ₹ monogram situated above the centered "Paisaजी" wordmark.
- **Primary Usage**: App splash screens, square/portrait marketing materials, social media avatars, and event collateral.

### D. Standalone Monogram (`paisaji_monogram.png`)
- **Composition**: Standalone P + ₹ monogram symbol.
- **Primary Usage**: Mobile app launcher icons, browser favicons, notification icons, compact avatars, and collapsed dashboard sidebars.

### E. Background & Color Adaptations
1. **Light Backgrounds**: Use standard full-color assets (`paisaji_primary.png`, `paisaji_wordmark.png`).
2. **Dark & Navy Backgrounds (`#0A2342`, `#0B0F19`)**: Use `paisaji_white_darkbg.png` (white monogram & Paisa with vivid `#007BFF` "जी") or `paisaji_primary_white.png`.
3. **Monochrome Black (`paisaji_monochrome_black.png`)**: Single-color black `#000000` or `#0A2342` for single-color print, newspaper, or thermal receipts.
4. **Monochrome White (`paisaji_monochrome_white.png`)**: Pure white `#FFFFFF` for dark overlays and video watermarks.

---

## 3. Strict Rules & Typography Standards

1. **Wordmark Language Integrity**: 
   - Never transliterate Hindi **जी** into English "Ji" in the visual logo artwork. The logo artwork is always **Paisaजी**.
   - In running body text, prose, and metadata, write the company name as **PaisaJi** or **Paisaजी**.
2. **Tagline Prohibition**:
   - Never display or append "है, ना!", "है ना", "Hai Na", or any alternate tagline to the logo.
   - Do not replace the tagline with any alternate slogan, motto, or subtitle.
   - Do not reserve empty vertical space or padding below the logo for a tagline.
3. **Proportions & Clear Space**:
   - Maintain a minimum clear space equal to 50% of the monogram height (`0.5H`) around the logo on all sides.
   - Never stretch, skew, compress, rotate, or alter the aspect ratio of the logo.
4. **Color Accuracy**:
   - Do not invert or arbitrarily recolor the logo elements (e.g., never make "Paisa" green or "जी" red).

---

## 4. Cross-Platform Asset Directory Structure

```
assets/branding/
├── paisaji_primary.png              # High-resolution primary horizontal logo
├── paisaji_primary_transparent.png  # Transparent alpha horizontal logo
├── paisaji_primary_white.png        # White horizontal logo for dark surfaces
├── paisaji_white_darkbg.png         # White + Bright Blue horizontal logo for dark backgrounds
├── paisaji_primary_black.png        # Monochrome black horizontal logo
├── paisaji_monochrome_black.png     # Monochrome black variant
├── paisaji_monochrome_white.png     # Monochrome white variant
├── paisaji_wordmark.png             # Official wordmark without symbol
├── paisaji_wordmark_no_tagline.png  # Backward-compatible alias
├── paisaji_stacked.png              # Stacked monogram + wordmark
├── paisaji_stacked_primary.png      # Stacked primary variant
├── paisaji_stacked_white.png        # Stacked white variant
├── paisaji_stacked_transparent.png  # Stacked transparent variant
├── paisaji_monogram.png             # Standalone P + ₹ monogram
├── paisaji_monogram_white.png       # White monogram
├── paisaji_monogram_black.png       # Black monogram
├── paisaji_monogram_transparent.png # Transparent monogram
└── responsive/
    ├── paisaji_primary@1x.png, @2x.png, @3x.png
    ├── paisaji_wordmark@1x.png, @2x.png, @3x.png
    ├── paisaji_stacked@1x.png, @2x.png, @3x.png
    └── paisaji_monogram@1x.png, @2x.png, @3x.png
```

---

## 5. Implementation Reference

### Flutter Implementation
```dart
// Standard Horizontal Branding
Image.asset(
  'assets/branding/paisaji_primary.png',
  fit: BoxFit.contain,
)

// Monogram for Compact Space / Avatars
Image.asset(
  'assets/branding/paisaji_monogram.png',
  width: 40,
  height: 40,
  fit: BoxFit.contain,
)
```

### Next.js & React Implementation
```tsx
// Light Header
<img
  src="/branding/paisaji_wordmark.png"
  alt="Paisaजी"
  className="h-9 w-auto object-contain"
/>

// Dark Footer / Dark Login Card
<img
  src="/branding/paisaji_white_darkbg.png"
  alt="Paisaजी"
  className="h-10 w-auto object-contain"
/>
```

---
*Authorized by Brand Identity & Architecture Governance — PaisaJi Ecosystem*
