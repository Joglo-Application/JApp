# Resto POS — Design System Specification

> **Scope:** Material 3 · Flutter Stable · Tablet-first (landscape 1024 dp+) · No hardcoded values  
> **Source:** Figma export — `design/image.png` (17 screens, FLOW series)

---

## 1. Color System

### Raw Palette (Design Tokens)

| Token | Hex | Usage in Design |
|---|---|---|
| `brand-gold` | `#C9A62B` | Primary brand color — header strips, category tabs, star ratings |
| `brand-gold-light` | `#F5E199` | Hover / pressed state of gold elements |
| `brand-gold-dark` | `#8E7210` | Active tab indicator underline |
| `surface-dark` | `#1E1E2E` | App shell header, cart panel background |
| `surface-mid` | `#2E2E3E` | Secondary panels, sidebar rows |
| `surface-white` | `#FFFFFF` | Main content area, product cards |
| `surface-tint` | `#F5F5F0` | Page scaffold background behind cards |
| `on-surface-dark` | `#FFFFFF` | Text / icons on dark panels |
| `on-surface-light` | `#1A1A1A` | Text on white/light surfaces |
| `on-surface-muted` | `#6B6B6B` | Secondary labels, helper text, timestamps |
| `success` | `#2E9E4F` | Confirm / checkout / add-to-cart buttons |
| `success-container` | `#D4EDDA` | Success badge backgrounds |
| `danger` | `#D93025` | Cancel / remove / delete buttons |
| `danger-container` | `#FDECEA` | Error badge backgrounds |
| `warning` | `#E8900A` | Low-stock indicator, discount badge |
| `outline` | `#E0E0E0` | Card borders, dividers |
| `outline-variant` | `#F0F0F0` | Subtle separators between list items |

### Material 3 Semantic Mapping

| M3 Role | Mapped Token | Hex |
|---|---|---|
| `primary` | `brand-gold` | `#C9A62B` |
| `onPrimary` | `on-surface-dark` | `#FFFFFF` |
| `primaryContainer` | `brand-gold-light` | `#F5E199` |
| `onPrimaryContainer` | `brand-gold-dark` | `#8E7210` |
| `secondary` | `surface-dark` | `#1E1E2E` |
| `onSecondary` | `on-surface-dark` | `#FFFFFF` |
| `secondaryContainer` | `surface-mid` | `#2E2E3E` |
| `onSecondaryContainer` | `on-surface-dark` | `#FFFFFF` |
| `tertiary` | `success` | `#2E9E4F` |
| `onTertiary` | `on-surface-dark` | `#FFFFFF` |
| `tertiaryContainer` | `success-container` | `#D4EDDA` |
| `error` | `danger` | `#D93025` |
| `onError` | `on-surface-dark` | `#FFFFFF` |
| `errorContainer` | `danger-container` | `#FDECEA` |
| `surface` | `surface-white` | `#FFFFFF` |
| `onSurface` | `on-surface-light` | `#1A1A1A` |
| `surfaceVariant` | `surface-tint` | `#F5F5F0` |
| `onSurfaceVariant` | `on-surface-muted` | `#6B6B6B` |
| `outline` | `outline` | `#E0E0E0` |
| `outlineVariant` | `outline-variant` | `#F0F0F0` |
| `background` | `surface-tint` | `#F5F5F0` |
| `onBackground` | `on-surface-light` | `#1A1A1A` |

---

## 2. Typography Hierarchy

**Font Family:** Inter (primary) — fallback `Roboto`, `sans-serif`  
**Base size:** 14 sp · **Scale ratio:** Material 3 type scale

| M3 Style | Size | Weight | Line Height | Letter Spacing | Usage |
|---|---|---|---|---|---|
| `displayLarge` | 57 sp | 400 | 64 sp | −0.25 | Not used |
| `displayMedium` | 45 sp | 400 | 52 sp | 0 | Not used |
| `displaySmall` | 36 sp | 400 | 44 sp | 0 | Not used |
| `headlineLarge` | 32 sp | 700 | 40 sp | 0 | Restaurant name in shell header |
| `headlineMedium` | 28 sp | 700 | 36 sp | 0 | Page section titles |
| `headlineSmall` | 24 sp | 700 | 32 sp | 0 | Cart totals, summary headers |
| `titleLarge` | 22 sp | 600 | 28 sp | 0 | Panel titles (Order Summary, Voucher) |
| `titleMedium` | 16 sp | 600 | 24 sp | +0.15 | Product names, category tab labels |
| `titleSmall` | 14 sp | 600 | 20 sp | +0.1 | Cart item row labels, section headers |
| `labelLarge` | 14 sp | 600 | 20 sp | +0.1 | Button labels |
| `labelMedium` | 12 sp | 500 | 16 sp | +0.5 | Chip labels, tags, badge text |
| `labelSmall` | 11 sp | 500 | 16 sp | +0.5 | Rating counts, timestamps |
| `bodyLarge` | 16 sp | 400 | 24 sp | +0.5 | Descriptions, notes input |
| `bodyMedium` | 14 sp | 400 | 20 sp | +0.25 | List secondary text, order item descriptions |
| `bodySmall` | 12 sp | 400 | 16 sp | +0.4 | Helper text, footnotes, subtext |

### Typography Rules
- Price values: `titleLarge` weight `700`, color `primary`
- Discounted price strikethrough: `bodyMedium` weight `400`, color `onSurfaceVariant`
- Quantity digits in quantity controls: `titleMedium` weight `700`
- Currency symbol: `titleSmall` weight `600`, baseline-aligned with price

---

## 3. Spacing Scale

**Base unit:** 4 dp

| Token | Value | Usage |
|---|---|---|
| `space-1` | 4 dp | Icon internal padding, tight inline gaps |
| `space-2` | 8 dp | Between icon and label, chip internal horizontal |
| `space-3` | 12 dp | Card internal vertical rhythm, list item row gaps |
| `space-4` | 16 dp | Card padding (default), section inner padding |
| `space-5` | 20 dp | Page horizontal margin (mobile) |
| `space-6` | 24 dp | Between sections on a page |
| `space-8` | 32 dp | Panel padding (tablet sidebar) |
| `space-10` | 40 dp | Hero section top padding |
| `space-12` | 48 dp | Large section separators |
| `space-16` | 64 dp | Full-bleed panel top offset |

### Layout Grid (Tablet Landscape 1024 dp+)
- **Columns:** 12
- **Gutter:** 16 dp
- **Margin:** 24 dp
- **Content panel:** 8 cols (product grid)
- **Sidebar panel:** 4 cols (order/cart summary) — fixed, not scrollable

### Layout Grid (Phone 360–599 dp)
- **Columns:** 4
- **Gutter:** 8 dp
- **Margin:** 16 dp

---

## 4. Border Radius Scale

| Token | Value | Usage |
|---|---|---|
| `radius-xs` | 4 dp | Input fields, table cells, small tags |
| `radius-sm` | 8 dp | Buttons (primary/secondary), quantity controls |
| `radius-md` | 12 dp | Product cards, cart item rows, stat cards |
| `radius-lg` | 16 dp | Bottom sheets, modals, panel containers |
| `radius-xl` | 24 dp | Hero image containers, large dialog sheets |
| `radius-full` | 999 dp | Category filter chips, badge pills, FABs |

---

## 5. Elevation & Shadow Usage

Material 3 tonal elevation is used; box shadows are minimal and purposeful.

| Level | dp | Component | Shadow |
|---|---|---|---|
| Level 0 | 0 | Page background, dividers | None |
| Level 1 | 1 | Flat cards (product list rows) | `0 1 2 rgba(0,0,0,0.08)` |
| Level 2 | 3 | Product cards (default), stat cards | `0 2 4 rgba(0,0,0,0.10)` |
| Level 3 | 6 | Cart/order panel, floating summary bar | `0 4 8 rgba(0,0,0,0.12)` |
| Level 4 | 8 | App bar / header strip | `0 2 6 rgba(0,0,0,0.14)` |
| Level 5 | 12 | Bottom sheets, dialogs, modals | `0 8 24 rgba(0,0,0,0.18)` |

**Rules:**
- Dark panels (`surface-dark`) do not use shadow — their contrast with the light page provides separation.
- Pressed state of cards: elevation drops from Level 2 → Level 1.
- Hovering a product card: Level 2 → Level 3.
- The order summary sidebar is permanently at Level 3.

---

## 6. Reusable Components

### 6.1 AppShellHeader
- Background: `surface-dark`
- Height: 64 dp (tablet), 56 dp (phone)
- Left: Restaurant logo + name (`headlineLarge`, `on-surface-dark`)
- Center: Category tab row (see `CategoryTabBar`)
- Right: Session info / operator name (`bodyMedium`, `on-surface-dark`)

### 6.2 CategoryTabBar
- Background: `surface-dark`
- Item: text label (`titleSmall`) + optional icon
- Active state: `brand-gold` text + 2 dp underline indicator (`brand-gold`)
- Inactive: `on-surface-dark` at 60% opacity
- Scrollable horizontally on phone; full-width on tablet
- Min tap target: 48 × 48 dp

### 6.3 ProductCard
- Background: `surface-white`
- Elevation: Level 2
- Radius: `radius-md`
- Image: 16:9 aspect, top-rounded, `ClipRRect`
- Name: `titleMedium`, 2-line max, overflow ellipsis
- Price: `titleLarge` weight 700, `primary` color
- Rating row: `StarRating` widget + count (`bodySmall`, `on-surface-muted`)
- Add button: icon-only `FilledIconButton`, `success` background, `radius-sm`
- Unavailable state: image overlaid with 50% black scrim + "Habis" label

### 6.4 StarRating
- Filled star: `brand-gold` (`Icons.star`)
- Half star: `brand-gold` (`Icons.star_half`)
- Empty star: `outline` (`Icons.star_border`)
- Size: 14 dp (compact), 18 dp (default), 24 dp (large)
- Tap on each star updates rating (form context only)

### 6.5 QuantityControl
- Layout: Row — `[-]` [count] `[+]`
- Button shape: `radius-sm`, 36 × 36 dp min
- Decrement button: `outlined` style, border `outline`
- Increment button: `filled` style, background `primary`
- Count text: `titleMedium` weight 700, center-aligned, min 32 dp wide

### 6.6 CartItemRow
- Background: `surface-white`
- Radius: `radius-md` (within cart panel)
- Layout: [Image 56×56] [Name + modifier text] [QuantityControl] [Price]
- Separator: `outline-variant` divider, 1 dp
- Swipe-to-delete: reveals `danger` background with trash icon

### 6.7 OrderSummaryPanel
- Width: fixed 360 dp (tablet landscape)
- Background: `surface-dark`
- Header: order number + table label (`titleLarge`, `on-surface-dark`)
- Body: `CartItemRow` list, scrollable
- Footer: sticky — subtotal row, tax row, total row, then `ActionButtonRow`
- Total row: `headlineSmall` weight 700, `brand-gold`

### 6.8 PriceSummaryRow
- Layout: label (left, `bodyMedium`) + value (right, `bodyMedium` weight 600)
- Total row: `titleMedium` weight 700 (label) + `headlineSmall` weight 700 (value)
- Divider above total: 1 dp `outline`
- Tax/discount rows: `on-surface-muted` color

### 6.9 ActionButtonRow
- Two-button layout: [Secondary/Cancel] [Primary/Confirm]
- Cancel button: `OutlinedButton`, border `danger`, text `danger`, `radius-sm`
- Confirm button: `FilledButton`, background `success`, text white, `radius-sm`
- Height: 48 dp, full-width each (flex equal)
- Spacing between: `space-3`

### 6.10 AppTextField (notes / search)
- Border: 1 dp `outline`, `radius-xs`
- Focus border: 2 dp `primary`
- Background: `surface-white`
- Label: floating (`bodySmall`, `on-surface-muted`)
- Hint: `bodyMedium`, `on-surface-muted`
- Multiline variant: min 3 lines, max 6 lines (for order notes)

### 6.11 VoucherInputCard
- Container: `surface-white`, `radius-md`, Level 2 elevation
- Row: text field (flex) + "Pakai" button (`FilledButton`, `primary`, `radius-sm`)
- Applied state: green checkmark icon + voucher code + discount amount
- Remove voucher: small `IconButton` with `Icons.close`, `danger`

### 6.12 CategoryChip
- Default: `outlined` chip, border `outline`, label `on-surface-muted`
- Selected: `filled` chip, background `primaryContainer`, label `onPrimaryContainer`
- Shape: `radius-full`
- Height: 32 dp

### 6.13 StatusBadge
- Shape: pill (`radius-full`), min 24 dp height
- Variants: success (`success-container` + `success` text), danger (`danger-container` + `danger` text), warning (`#FFF3CD` + `warning` text)
- Text style: `labelMedium` weight 600

### 6.14 EmptyStateWidget
- Icon: 64 dp, `on-surface-muted`
- Title: `titleMedium`, `on-surface-muted`
- Subtitle: `bodyMedium`, `on-surface-muted`
- CTA button (optional): `TextButton`, `primary`
- Centered within available space, padding `space-10`

### 6.15 LoadingOverlay
- Barrier: `Colors.black54`
- Spinner: `CircularProgressIndicator`, `primary`
- Centered with no label

---

## 7. Material 3 ThemeData Mapping

### ColorScheme Seed
```
seedColor: Color(0xFFC9A62B)   // brand-gold
brightness: Brightness.light
```

### Component Theme Overrides

| Component | Override |
|---|---|
| `AppBarTheme` | `backgroundColor: surface-dark`, `foregroundColor: on-surface-dark`, `elevation: 4`, `centerTitle: false` |
| `CardTheme` | `elevation: 3`, `shape: RoundedRectangleBorder(radius-md)`, `margin: EdgeInsets.zero` |
| `FilledButtonTheme` | `shape: StadiumBorder` → `RoundedRectangleBorder(radius-sm)`, `minimumSize: Size(88, 48)` |
| `OutlinedButtonTheme` | `shape: RoundedRectangleBorder(radius-sm)`, `minimumSize: Size(88, 48)` |
| `TextButtonTheme` | `minimumSize: Size(48, 40)` |
| `InputDecorationTheme` | `border: OutlineInputBorder(radius-xs)`, `filled: true`, `fillColor: surface-white` |
| `ChipTheme` | `shape: StadiumBorder`, `padding: EdgeInsets.symmetric(horizontal: space-3)` |
| `NavigationBarTheme` | `backgroundColor: surface-white`, `indicatorColor: primaryContainer`, `height: 64` |
| `DividerTheme` | `color: outline-variant`, `thickness: 1`, `space: 0` |
| `SnackBarTheme` | `behavior: SnackBarBehavior.floating`, `shape: RoundedRectangleBorder(radius-md)` |
| `DialogTheme` | `shape: RoundedRectangleBorder(radius-lg)`, `elevation: 5` |
| `BottomSheetTheme` | `shape: RoundedRectangleBorder(topLeft: radius-lg, topRight: radius-lg)` |
| `ListTileTheme` | `contentPadding: EdgeInsets.symmetric(horizontal: space-4, vertical: space-2)` |
| `IconTheme` | `size: 24`, `color: onSurfaceVariant` |

### TextTheme
```
fontFamily: 'Inter'
fontFamilyFallback: ['Roboto', 'sans-serif']
```
All sizes and weights as specified in Section 2.

### Breakpoints
| Name | Min Width | Layout |
|---|---|---|
| `compact` | 0 dp | Single-column, bottom nav |
| `medium` | 600 dp | Two-column split begins |
| `expanded` | 1024 dp | Full tablet layout — fixed sidebar |

---

## 8. Design Patterns & Conventions

### Split-Panel Layout (Tablet)
- Left panel (8/12 cols): scrollable product grid
- Right panel (4/12 cols, `surface-dark`): fixed order summary
- Panels are never nested inside each other
- Divider: 1 dp `outline` at panel boundary

### Confirmation Flow Pattern
All destructive or payment actions follow a 2-step pattern:
1. Primary action button triggers a `BottomSheet` or `AlertDialog`
2. Sheet contains: summary, then `ActionButtonRow` (cancel + confirm)
3. Confirm executes action; Cancel dismisses without state change

### Voucher Flow
- Input field → validate → show applied chip → recompute totals
- Error state: input border becomes `danger`, helper text in `danger`

### Notes Flow
- Tap "Tambah Catatan" → inline multiline `AppTextField` expands
- Character limit: 200 characters, shown as `bodySmall` counter at bottom-right

### Discount Badge on Product Card
- Positioned: top-right of card image, `StatusBadge` warning variant
- Format: "-20%" or "PROMO"

---

*End of Design System — v1.0*
