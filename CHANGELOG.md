# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0

Initial release of Advance Cart Stepper.

### Features

- **CartStepper Widget** - Expandable cart quantity stepper with smooth animations
- **Size Variants** - Compact (32px), Normal (40px), and Large (48px) presets
- **Add-to-Cart Styles** - Circle icon, text buttons, and customizable configurations
- **Async Support** - Built-in loading indicators with 15+ SpinKit animations
- **Optimistic Updates** - Instant UI feedback with automatic error revert
- **Debounce Mode** - Batch rapid changes into single API calls
- **Error Handling** - onError callback and errorBuilder for inline error display
- **Validation** - Custom validators with rejection callbacks
- **Long Press** - Hold buttons for rapid increment/decrement
- **Auto-Collapse** - Collapse to badge view after inactivity
- **Quantity Formatters** - Built-in abbreviation (1.5k, 2M) and max indicators (99+)
- **Manual Input** - Tap quantity to type directly with keyboard
- **Theming** - CartStepperTheme for consistent styling across widgets
- **Haptic Feedback** - Optional haptics on button interactions
- **Theme-Aware Colors** - CartBadge uses theme colors by default

### Components

- **CartStepper** - Main stepper widget
- **CartStepperController** - External state management with ChangeNotifier
- **CartBadge** - Display count badges on icons
- **CartStepperGroup** - Horizontal variant selection with generic type support
- **CartProductTile** - Complete product tile with integrated stepper
- **ThemedCartStepper** - Theme-aware stepper variant
- **AnimatedCounter** - Standalone animated number display
- **StepperButton** - Reusable button with long-press support

### Configuration Classes

- **CartStepperStyle** - Colors, borders, typography customization
- **CartStepperAnimation** - Duration, curves, haptics configuration
- **CartStepperLoadingConfig** - Loading indicator type and behavior
- **AddToCartButtonConfig** - Initial button appearance and behavior
- **CartStepperGroupItem** - Generic item with required `id` for stable keys
