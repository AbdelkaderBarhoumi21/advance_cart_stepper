# Cart Stepper

A highly customizable, animated cart quantity stepper widget for Flutter with async support, loading indicators, and theming.

[![pub package](https://img.shields.io/pub/v/advance_cart_stepper.svg)](https://pub.dev/packages/advance_cart_stepper)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

![Cart Stepper Demo](https://raw.githubusercontent.com/khaledsmq/advance_cart_stepper/main/screenshots/demo.gif)

## Features

- **Smooth Animations** - Elegant expand/collapse transitions between add button and stepper
- **Async Support** - Built-in loading indicators for API operations with error handling
- **Optimistic Updates** - Instant UI feedback with automatic revert on errors
- **Operation Management** - Throttling, cancellation, and pending operation tracking
- **Validation** - Custom validators with rejection callbacks for user feedback
- **Multiple Loading Indicators** - 15+ SpinKit animations plus Flutter's built-in indicators
- **Customizable Styling** - Full control over colors, borders, shadows, and typography
- **Size Variants** - Compact, normal, and large presets for different use cases
- **Theming** - Apply consistent styles across multiple steppers with `CartStepperTheme`
- **Long Press** - Hold to rapidly increment/decrement with configurable delays
- **Auto-Collapse** - Optionally collapse to badge view after inactivity
- **Quantity Formatters** - Built-in abbreviation for large numbers (1.5k, 2M)
- **State-Agnostic** - Works with any state management (Provider, Riverpod, Bloc, etc.)
- **Accessibility** - Full semantic support for screen readers
- **Controller Support** - Full async support with `CartStepperController`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  advance_cart_stepper: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:advance_cart_stepper/advance_cart_stepper.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return CartStepper(
      quantity: quantity,
      onQuantityChanged: (qty) => setState(() => quantity = qty),
      onRemove: () => setState(() => quantity = 0),
    );
  }
}
```

### Async with Loading Indicator

```dart
CartStepper(
  quantity: quantity,
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(itemId, qty);
    setState(() => quantity = qty);
  },
  onRemoveAsync: () async {
    await api.removeFromCart(itemId);
    setState(() => quantity = 0);
  },
  onError: (error, stackTrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  },
)
```

## Customization

### Size Variants

```dart
// Compact - for dense lists (32px height)
CartStepper(
  quantity: quantity,
  size: CartStepperSize.compact,
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)

// Normal - default size (40px height)
CartStepper(
  quantity: quantity,
  size: CartStepperSize.normal,
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)

// Large - for accessibility or prominent CTAs (48px height)
CartStepper(
  quantity: quantity,
  size: CartStepperSize.large,
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)
```

### Style Presets

```dart
// Orange (default)
CartStepper(
  quantity: quantity,
  style: CartStepperStyle.defaultOrange,
  onQuantityChanged: (qty) {},
)

// Dark theme
CartStepper(
  quantity: quantity,
  style: CartStepperStyle.dark,
  onQuantityChanged: (qty) {},
)

// Light/minimal
CartStepper(
  quantity: quantity,
  style: CartStepperStyle.light,
  onQuantityChanged: (qty) {},
)
```

### Custom Styling

```dart
CartStepper(
  quantity: quantity,
  style: CartStepperStyle(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    borderColor: Colors.blue,
    borderWidth: 2.0,
    elevation: 4.0,
    borderRadius: BorderRadius.circular(8),
    fontWeight: FontWeight.bold,
  ),
  onQuantityChanged: (qty) {},
)
```

### Add Button Styles

```dart
// Circle icon (default)
CartStepper(
  quantity: 0,
  addToCartConfig: AddToCartButtonConfig.circleIcon,
  onQuantityChanged: (qty) {},
)

// "Add" button
CartStepper(
  quantity: 0,
  addToCartConfig: AddToCartButtonConfig.addButton,
  onQuantityChanged: (qty) {},
)

// "Add to Cart" button
CartStepper(
  quantity: 0,
  addToCartConfig: AddToCartButtonConfig.addToCartButton,
  onQuantityChanged: (qty) {},
)

// Custom button
CartStepper(
  quantity: 0,
  addToCartConfig: AddToCartButtonConfig(
    style: AddToCartButtonStyle.button,
    buttonText: 'Buy Now',
    icon: Icons.shopping_bag,
    iconLeading: false,
    buttonWidth: 100,
  ),
  onQuantityChanged: (qty) {},
)
```

### Loading Indicators

```dart
// SpinKit animations
CartStepper(
  quantity: quantity,
  loadingConfig: CartStepperLoadingConfig(
    type: CartStepperLoadingType.fadingCircle,
    minimumDuration: Duration(milliseconds: 500),
    sizeMultiplier: 0.8,
  ),
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(qty);
  },
)

// Built-in Flutter indicator (no SpinKit dependency)
CartStepper(
  quantity: quantity,
  loadingConfig: CartStepperLoadingConfig.builtIn,
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(qty);
  },
)
```

**Available loading types:**
- `threeBounce` (default)
- `fadingCircle`
- `pulse`
- `dualRing`
- `spinningCircle`
- `wave`
- `chasingDots`
- `threeInOut`
- `ring`
- `ripple`
- `fadingFour`
- `pianoWave`
- `dancingSquare`
- `cubeGrid`
- `circular` (Flutter built-in)
- `linear` (Flutter built-in)

### Animation Configuration

```dart
// Fast animations
CartStepper(
  quantity: quantity,
  animation: CartStepperAnimation.fast,
  onQuantityChanged: (qty) {},
)

// Smooth with bounce
CartStepper(
  quantity: quantity,
  animation: CartStepperAnimation.smooth,
  onQuantityChanged: (qty) {},
)

// Custom
CartStepper(
  quantity: quantity,
  animation: CartStepperAnimation(
    expandDuration: Duration(milliseconds: 300),
    expandCurve: Curves.easeOutBack,
    enableHaptics: true,
  ),
  onQuantityChanged: (qty) {},
)
```

### Auto-Collapse with Badge

```dart
CartStepper(
  quantity: quantity,
  autoCollapseDelay: Duration(seconds: 3),
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)
```

### Quantity Formatting

```dart
// Abbreviate large numbers (1500 → "1.5k")
CartStepper(
  quantity: 1500,
  maxQuantity: 9999999,
  quantityFormatter: QuantityFormatters.abbreviated,
  onQuantityChanged: (qty) {},
)

// Show max indicator (99 → "99+")
CartStepper(
  quantity: 99,
  quantityFormatter: QuantityFormatters.abbreviatedWithMax(99),
  onQuantityChanged: (qty) {},
)
```

## Using Controller

For external state management:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final CartStepperController controller;

  @override
  void initState() {
    super.initState();
    controller = CartStepperController(
      initialQuantity: 0,
      minQuantity: 0,
      maxQuantity: 10,
    );
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CartStepper(
          quantity: controller.quantity,
          maxQuantity: controller.maxQuantity,
          onQuantityChanged: controller.setQuantity,
          onRemove: controller.reset,
        ),
        ElevatedButton(
          onPressed: controller.setToMax,
          child: Text('Set to Max'),
        ),
      ],
    );
  }
}
```

## Theming

Apply consistent styling across multiple steppers:

```dart
CartStepperTheme(
  data: CartStepperThemeData(
    style: CartStepperStyle(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    ),
    size: CartStepperSize.normal,
    enableLongPress: true,
  ),
  child: Column(
    children: [
      ThemedCartStepper(quantity: 1, onQuantityChanged: (qty) {}),
      ThemedCartStepper(quantity: 2, onQuantityChanged: (qty) {}),
      // Override specific properties
      ThemedCartStepper(
        quantity: 3,
        size: CartStepperSize.compact, // Override theme size
        onQuantityChanged: (qty) {},
      ),
    ],
  ),
)
```

## Composite Widgets

### CartProductTile

A complete product tile with integrated stepper:

```dart
CartProductTile(
  leading: Image.network(product.imageUrl),
  title: product.name,
  subtitle: 'In stock',
  price: '\$${product.price}',
  quantity: quantity,
  onQuantityChanged: (qty) => updateCart(product.id, qty),
  onRemove: () => removeFromCart(product.id),
)
```

### CartStepperGroup

For variant selection (sizes, colors):

```dart
CartStepperGroup(
  items: [
    CartStepperGroupItem(id: 'small', quantity: 0, label: 'S'),
    CartStepperGroupItem(id: 'medium', quantity: 1, label: 'M'),
    CartStepperGroupItem(id: 'large', quantity: 0, label: 'L'),
  ],
  onQuantityChanged: (index, qty) {
    setState(() => sizes[index] = qty);
  },
  maxTotalQuantity: 10, // Limit total across all variants
)
```

You can also attach typed data to each item:

```dart
CartStepperGroup<ProductVariant>(
  items: [
    CartStepperGroupItem(
      id: 'sku-123',
      quantity: 0,
      label: 'S',
      data: ProductVariant(sku: 'sku-123', price: 19.99),
    ),
    CartStepperGroupItem(
      id: 'sku-456',
      quantity: 1,
      label: 'M',
      data: ProductVariant(sku: 'sku-456', price: 21.99),
    ),
  ],
  onQuantityChanged: (index, qty) {
    final variant = items[index].data!;
    updateCart(variant.sku, qty);
  },
)
```

### CartBadge

Display cart count on icons:

```dart
CartBadge(
  count: totalItems,
  child: Icon(Icons.shopping_cart),
)
```

## Advanced Options

```dart
CartStepper(
  quantity: quantity,
  minQuantity: 1,           // Minimum allowed (default: 0)
  maxQuantity: 99,          // Maximum allowed (default: 99)
  step: 5,                  // Increment/decrement step (default: 1)
  enabled: true,            // Enable/disable interactions
  showDeleteAtMin: true,    // Show delete icon at min quantity
  enableLongPress: true,    // Enable rapid changes on long press
  longPressInterval: Duration(milliseconds: 100),
  initialLongPressDelay: Duration(milliseconds: 400),
  autoCollapse: true,       // Collapse when quantity reaches 0
  initiallyExpanded: null,  // Force initial state (null = auto)
  onMaxReached: () => showSnackBar('Maximum quantity reached'),
  onMinReached: () => showSnackBar('Minimum quantity reached'),
  onQuantityChanged: (qty) => setState(() => quantity = qty),
  onRemove: () => setState(() => quantity = 0),
)
```

## Optimistic Updates

For snappier UI, update immediately while API call happens in background:

```dart
CartStepper(
  quantity: quantity,
  optimisticUpdate: true,     // Show new value immediately
  revertOnError: true,        // Revert if operation fails
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(itemId, qty);
    setState(() => quantity = qty);
  },
  onError: (error, stack) {
    // UI already reverted, just show message
    showErrorSnackBar(error.toString());
  },
)
```

## Error Builder

Display inline error UI with retry functionality:

```dart
CartStepper(
  quantity: quantity,
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(itemId, qty);
    setState(() => quantity = qty);
  },
  onError: (error, stack) {
    // Optional: log error or show snackbar
  },
  errorBuilder: (context, error, retry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Failed to update',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
        TextButton(
          onPressed: retry,
          child: Text('Retry'),
        ),
      ],
    );
  },
)
```

## Debounce Mode

Batch rapid changes into a single API call for better UX:

```dart
CartStepper(
  quantity: quantity,
  debounceDelay: Duration(milliseconds: 500),
  onQuantityChangedAsync: (qty) async {
    // Only called after user stops interacting for 500ms
    await api.updateCart(itemId, qty);
    setState(() => quantity = qty);
  },
)
```

With debounce:
- User sees immediate UI feedback
- User can rapidly adjust quantity without waiting
- Only one API call is made after user stops interacting
- Long press works smoothly without blocking

## Manual Input

Allow users to type quantities directly:

```dart
CartStepper(
  quantity: quantity,
  enableManualInput: true,
  onQuantityChanged: (qty) => setState(() => quantity = qty),
  onManualInputSubmitted: (value) {
    print('User entered: $value');
  },
)
```

Custom input builder:

```dart
CartStepper(
  quantity: quantity,
  enableManualInput: true,
  manualInputBuilder: (context, currentValue, onSubmit, onCancel) {
    return MyCustomNumberPicker(
      value: currentValue,
      onConfirm: (value) => onSubmit(value.toString()),
      onCancel: onCancel,
    );
  },
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)
```

## Validation with Feedback

Prevent invalid quantities with user feedback:

```dart
CartStepper(
  quantity: quantity,
  maxQuantity: 100,
  validator: (current, newQty) {
    // Check stock availability
    return newQty <= availableStock;
  },
  onValidationRejected: (current, attempted) {
    showSnackBar('Only $availableStock items in stock');
  },
  onQuantityChanged: (qty) => setState(() => quantity = qty),
)
```

## Operation Cancellation

Handle superseded operations gracefully:

```dart
CartStepper(
  quantity: quantity,
  onOperationCancelled: (attemptedQty) {
    // Previous operation was cancelled by a newer one
    debugPrint('Operation for $attemptedQty was cancelled');
  },
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(itemId, qty);
    setState(() => quantity = qty);
  },
)
```

## Throttle Configuration

Control rapid operation handling:

```dart
CartStepper(
  quantity: quantity,
  throttleInterval: Duration(milliseconds: 100), // Default: 80ms
  allowLongPressForAsync: false, // Disable rapid fire for async
  onQuantityChangedAsync: (qty) async {
    await api.updateCart(itemId, qty);
  },
)
```

## Async Controller Usage

For complex state management with async operations:

```dart
final controller = CartStepperController(
  initialQuantity: 0,
  validator: (current, newQty) => newQty <= maxStock,
  onError: (error, stack) => showError(error),
  onMaxReached: () => showMessage('Maximum reached'),
);

// Async increment with optimistic update
await controller.incrementAsync(
  (newQty) => api.updateCart(itemId, newQty),
  optimistic: true,
);

// Async decrement
await controller.decrementAsync(
  (newQty) => api.updateCart(itemId, newQty),
);

// Direct async set
await controller.setQuantityAsync(
  10,
  () => api.setQuantity(itemId, 10),
  optimistic: true,
);

// Cancel pending operations
controller.cancelOperation();
```

## Example App

See the [example](example/) folder for a complete demo showcasing all features.

```bash
cd example
flutter create .
flutter run
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
