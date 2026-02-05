import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cart_stepper.dart';
import 'cart_stepper_config.dart';
import 'cart_stepper_enums.dart';
import 'cart_stepper_types.dart';

/// Provides theme-based styling for [CartStepper] widgets in a subtree.
///
/// Wrap your widget tree with [CartStepperTheme] to provide consistent
/// styling to all [ThemedCartStepper] widgets within.
///
/// Example:
/// ```dart
/// CartStepperTheme(
///   data: CartStepperThemeData(
///     style: CartStepperStyle.defaultOrange,
///     size: CartStepperSize.normal,
///   ),
///   child: Column(
///     children: [
///       ThemedCartStepper(quantity: 1, onQuantityChanged: (_) {}),
///       ThemedCartStepper(quantity: 2, onQuantityChanged: (_) {}),
///     ],
///   ),
/// )
/// ```
///
/// See also:
/// - [ThemedCartStepper] which uses this theme
/// - [CartStepperThemeData] for available theme properties
class CartStepperTheme extends InheritedWidget {
  /// The theme data to apply to descendant steppers.
  final CartStepperThemeData data;

  /// Creates a cart stepper theme.
  const CartStepperTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the theme data from the closest [CartStepperTheme] ancestor.
  ///
  /// Returns null if there is no ancestor.
  static CartStepperThemeData? maybeOf(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<CartStepperTheme>();
    return theme?.data;
  }

  /// Returns the theme data from the closest [CartStepperTheme] ancestor.
  ///
  /// Throws an assertion error if there is no ancestor.
  static CartStepperThemeData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No CartStepperTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CartStepperTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for [CartStepper] widgets.
///
/// Use this with [CartStepperTheme] to style multiple steppers consistently.
@immutable
class CartStepperThemeData {
  /// Visual style configuration.
  final CartStepperStyle style;

  /// Size variant.
  final CartStepperSize size;

  /// Animation configuration.
  final CartStepperAnimation animation;

  /// Whether to show delete icon at minimum quantity.
  final bool showDeleteAtMin;

  /// Whether delete triggers onQuantityChanged instead of onRemove.
  final bool deleteViaQuantityChange;

  /// Whether long-press enables rapid changes.
  final bool enableLongPress;

  /// Duration before auto-collapse after inactivity.
  final Duration? autoCollapseDelay;

  /// Loading indicator configuration.
  final CartStepperLoadingConfig? loadingConfig;

  /// Creates theme data for cart steppers.
  const CartStepperThemeData({
    this.style = CartStepperStyle.defaultOrange,
    this.size = CartStepperSize.normal,
    this.animation = const CartStepperAnimation(),
    this.showDeleteAtMin = true,
    this.deleteViaQuantityChange = false,
    this.enableLongPress = true,
    this.autoCollapseDelay,
    this.loadingConfig,
  });

  /// Creates a copy with the given fields replaced.
  CartStepperThemeData copyWith({
    CartStepperStyle? style,
    CartStepperSize? size,
    CartStepperAnimation? animation,
    bool? showDeleteAtMin,
    bool? deleteViaQuantityChange,
    bool? enableLongPress,
    Duration? autoCollapseDelay,
    CartStepperLoadingConfig? loadingConfig,
  }) {
    return CartStepperThemeData(
      style: style ?? this.style,
      size: size ?? this.size,
      animation: animation ?? this.animation,
      showDeleteAtMin: showDeleteAtMin ?? this.showDeleteAtMin,
      deleteViaQuantityChange:
          deleteViaQuantityChange ?? this.deleteViaQuantityChange,
      enableLongPress: enableLongPress ?? this.enableLongPress,
      autoCollapseDelay: autoCollapseDelay ?? this.autoCollapseDelay,
      loadingConfig: loadingConfig ?? this.loadingConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartStepperThemeData &&
        other.style == style &&
        other.size == size &&
        other.animation == animation &&
        other.showDeleteAtMin == showDeleteAtMin &&
        other.deleteViaQuantityChange == deleteViaQuantityChange &&
        other.enableLongPress == enableLongPress &&
        other.autoCollapseDelay == autoCollapseDelay &&
        other.loadingConfig == loadingConfig;
  }

  @override
  int get hashCode => Object.hash(
        style,
        size,
        animation,
        showDeleteAtMin,
        deleteViaQuantityChange,
        enableLongPress,
        autoCollapseDelay,
        loadingConfig,
      );

  @override
  String toString() {
    return 'CartStepperThemeData(style: $style, size: $size)';
  }
}

/// A [CartStepper] that automatically uses theme from [CartStepperTheme].
///
/// This widget looks up the nearest [CartStepperTheme] and applies its
/// settings, with local overrides taking precedence.
///
/// Example:
/// ```dart
/// CartStepperTheme(
///   data: CartStepperThemeData(
///     style: CartStepperStyle(backgroundColor: Colors.blue),
///   ),
///   child: ThemedCartStepper(
///     quantity: 5,
///     onQuantityChanged: (qty) => print(qty),
///   ),
/// )
/// ```
///
/// See also:
/// - [CartStepperTheme] for providing theme data
/// - [CartStepper] for the underlying widget
class ThemedCartStepper extends StatelessWidget {
  /// Current quantity value.
  final int quantity;

  /// Synchronous callback when quantity changes.
  final QuantityChangedCallback? onQuantityChanged;

  /// Asynchronous callback when quantity changes.
  final AsyncQuantityChangedCallback? onQuantityChangedAsync;

  /// Callback when item should be removed.
  final VoidCallback? onRemove;

  /// Async callback when item should be removed.
  final Future<void> Function()? onRemoveAsync;

  /// Callback when add button is pressed.
  final VoidCallback? onAdd;

  /// Async callback when add button is pressed.
  final Future<void> Function()? onAddAsync;

  /// Minimum allowed quantity.
  final int minQuantity;

  /// Maximum allowed quantity.
  final int maxQuantity;

  /// Step value for increment/decrement.
  final int step;

  /// Size variant (overrides theme).
  final CartStepperSize? size;

  /// Visual style (overrides theme).
  final CartStepperStyle? style;

  /// Animation configuration (overrides theme).
  final CartStepperAnimation? animation;

  /// Loading configuration (overrides theme).
  final CartStepperLoadingConfig? loadingConfig;

  /// Whether the stepper is enabled.
  final bool enabled;

  /// Whether to show delete icon at min (overrides theme).
  final bool? showDeleteAtMin;

  /// Whether delete triggers onQuantityChanged (overrides theme).
  final bool? deleteViaQuantityChange;

  /// Whether long-press enables rapid changes (overrides theme).
  final bool? enableLongPress;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Auto-collapse delay (overrides theme).
  final Duration? autoCollapseDelay;

  /// Force initial expanded state.
  final bool? initiallyExpanded;

  /// Error callback for async operations.
  final AsyncErrorCallback? onError;

  /// Initial delay before long-press repeat starts.
  final Duration? initialLongPressDelay;

  /// Custom quantity formatter.
  final String Function(int quantity)? quantityFormatter;

  /// Configuration for the add button.
  final AddToCartButtonConfig? addToCartConfig;

  /// Creates a themed cart stepper.
  const ThemedCartStepper({
    super.key,
    required this.quantity,
    this.onQuantityChanged,
    this.onQuantityChangedAsync,
    this.onRemove,
    this.onRemoveAsync,
    this.onAdd,
    this.onAddAsync,
    this.minQuantity = 0,
    this.maxQuantity = 99,
    this.step = 1,
    this.size,
    this.style,
    this.animation,
    this.loadingConfig,
    this.enabled = true,
    this.showDeleteAtMin,
    this.deleteViaQuantityChange,
    this.enableLongPress,
    this.semanticLabel,
    this.autoCollapseDelay,
    this.initiallyExpanded,
    this.onError,
    this.initialLongPressDelay,
    this.quantityFormatter,
    this.addToCartConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CartStepperTheme.maybeOf(context);

    return CartStepper(
      quantity: quantity,
      onQuantityChanged: onQuantityChanged,
      onQuantityChangedAsync: onQuantityChangedAsync,
      onRemove: onRemove,
      onRemoveAsync: onRemoveAsync,
      onAdd: onAdd,
      onAddAsync: onAddAsync,
      minQuantity: minQuantity,
      maxQuantity: maxQuantity,
      step: step,
      size: size ?? theme?.size ?? CartStepperSize.normal,
      style: style ?? theme?.style ?? CartStepperStyle.defaultOrange,
      animation: animation ?? theme?.animation ?? const CartStepperAnimation(),
      loadingConfig: loadingConfig ??
          theme?.loadingConfig ??
          const CartStepperLoadingConfig(),
      enabled: enabled,
      showDeleteAtMin: showDeleteAtMin ?? theme?.showDeleteAtMin ?? true,
      deleteViaQuantityChange:
          deleteViaQuantityChange ?? theme?.deleteViaQuantityChange ?? false,
      enableLongPress: enableLongPress ?? theme?.enableLongPress ?? true,
      semanticLabel: semanticLabel,
      autoCollapseDelay: autoCollapseDelay ?? theme?.autoCollapseDelay,
      initiallyExpanded: initiallyExpanded,
      onError: onError,
      initialLongPressDelay:
          initialLongPressDelay ?? const Duration(milliseconds: 400),
      quantityFormatter: quantityFormatter,
      addToCartConfig: addToCartConfig ?? const AddToCartButtonConfig(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('quantity', quantity));
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

/// A horizontal row of cart steppers for variant selection.
///
/// Useful for showing multiple size/color variants with quantities.
///
/// Example:
/// ```dart
/// CartStepperGroup(
///   items: [
///     CartStepperGroupItem(id: 'small', quantity: 0, label: 'S'),
///     CartStepperGroupItem(id: 'medium', quantity: 1, label: 'M'),
///     CartStepperGroupItem(id: 'large', quantity: 0, label: 'L'),
///   ],
///   onQuantityChanged: (index, qty) {
///     setState(() => sizes[index] = qty);
///   },
/// )
/// ```
class CartStepperGroup<T> extends StatelessWidget {
  /// The items to display.
  final List<CartStepperGroupItem<T>> items;

  /// Callback when an item's quantity changes.
  final void Function(int index, int quantity)? onQuantityChanged;

  /// Callback when an item should be removed.
  final void Function(int index)? onRemove;

  /// Size variant for all steppers.
  final CartStepperSize size;

  /// Visual style for all steppers.
  final CartStepperStyle style;

  /// Spacing between items.
  final double spacing;

  /// Layout direction.
  final Axis direction;

  /// Maximum total quantity across all items.
  final int maxTotalQuantity;

  /// Creates a group of cart steppers.
  const CartStepperGroup({
    super.key,
    required this.items,
    this.onQuantityChanged,
    this.onRemove,
    this.size = CartStepperSize.compact,
    this.style = CartStepperStyle.defaultOrange,
    this.spacing = 8,
    this.direction = Axis.horizontal,
    this.maxTotalQuantity = 999,
  });

  /// Total quantity across all items.
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final currentTotal = totalQuantity;
        final maxForThis = item.maxQuantity
            .clamp(0, maxTotalQuantity - currentTotal + item.quantity);

        return Column(
          // Use item's unique id for stable keys when items are reordered/removed
          key: ValueKey('cart_stepper_group_${item.id}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.label != null)
              Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    item.label!,
                    style: TextStyle(
                      fontSize: size == CartStepperSize.compact ? 10 : 12,
                      // Use theme-aware color that adapts to light/dark mode
                      color: Theme.of(context).textTheme.bodySmall?.color ?? 
                             Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            CartStepper(
              quantity: item.quantity,
              minQuantity: item.minQuantity,
              maxQuantity: maxForThis,
              size: size,
              style: style,
              onQuantityChanged: (qty) => onQuantityChanged?.call(index, qty),
              onRemove: () => onRemove?.call(index),
            ),
          ],
        );
      }),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('itemCount', items.length));
    properties.add(IntProperty('totalQuantity', totalQuantity));
    properties.add(IntProperty('maxTotalQuantity', maxTotalQuantity));
  }
}

/// Item data for [CartStepperGroup].
///
/// The type parameter [T] allows for type-safe associated data.
@immutable
class CartStepperGroupItem<T> {
  /// Unique identifier for this item.
  ///
  /// Used for stable widget keys when items are reordered or removed.
  /// Should be unique within a [CartStepperGroup].
  final String id;

  /// Current quantity.
  final int quantity;

  /// Minimum allowed quantity.
  final int minQuantity;

  /// Maximum allowed quantity.
  final int maxQuantity;

  /// Optional label displayed above the stepper.
  final String? label;

  /// Optional typed data associated with this item.
  ///
  /// Useful for storing product variant IDs or other metadata.
  final T? data;

  /// Creates a group item.
  const CartStepperGroupItem({
    required this.id,
    required this.quantity,
    this.minQuantity = 0,
    this.maxQuantity = 99,
    this.label,
    this.data,
  });

  /// Creates a copy with the given fields replaced.
  CartStepperGroupItem<T> copyWith({
    String? id,
    int? quantity,
    int? minQuantity,
    int? maxQuantity,
    String? label,
    T? data,
  }) {
    return CartStepperGroupItem<T>(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      label: label ?? this.label,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartStepperGroupItem<T> &&
        other.id == id &&
        other.quantity == quantity &&
        other.minQuantity == minQuantity &&
        other.maxQuantity == maxQuantity &&
        other.label == label &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(id, quantity, minQuantity, maxQuantity, label, data);

  @override
  String toString() {
    return 'CartStepperGroupItem(id: $id, quantity: $quantity, label: $label)';
  }
}

/// Vertical list variant for product cards.
///
/// Combines product info with cart stepper in a card layout.
///
/// Example:
/// ```dart
/// CartProductTile(
///   leading: Image.network(product.imageUrl),
///   title: product.name,
///   subtitle: product.description,
///   price: '\$${product.price}',
///   quantity: cartQuantity,
///   onQuantityChanged: (qty) => updateCart(product.id, qty),
///   onRemove: () => removeFromCart(product.id),
/// )
/// ```
class CartProductTile extends StatelessWidget {
  /// Leading widget (typically an image).
  final Widget? leading;

  /// Product title.
  final String title;

  /// Optional subtitle or description.
  final String? subtitle;

  /// Optional price display.
  final String? price;

  /// Current quantity in cart.
  final int quantity;

  /// Callback when quantity changes.
  final QuantityChangedCallback? onQuantityChanged;

  /// Callback when item should be removed.
  final VoidCallback? onRemove;

  /// Callback when tile is tapped.
  final VoidCallback? onTap;

  /// Minimum allowed quantity.
  final int minQuantity;

  /// Maximum allowed quantity.
  final int maxQuantity;

  /// Size variant for the stepper.
  final CartStepperSize stepperSize;

  /// Visual style for the stepper.
  final CartStepperStyle stepperStyle;

  /// Padding around the tile content.
  final EdgeInsetsGeometry padding;

  /// Background color of the tile.
  final Color? backgroundColor;

  /// Border radius of the tile.
  final double borderRadius;

  /// Creates a cart product tile.
  const CartProductTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.price,
    required this.quantity,
    this.onQuantityChanged,
    this.onRemove,
    this.onTap,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.stepperSize = CartStepperSize.compact,
    this.stepperStyle = CartStepperStyle.defaultOrange,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.cardColor;
    final priceColor = stepperStyle.backgroundColor ?? theme.primaryColor;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          // Use theme-aware color that adapts to light/dark mode
                          color: theme.textTheme.bodySmall?.color ?? 
                                 theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        price!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: priceColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CartStepper(
                quantity: quantity,
                minQuantity: minQuantity,
                maxQuantity: maxQuantity,
                size: stepperSize,
                style: stepperStyle,
                onQuantityChanged: onQuantityChanged,
                onRemove: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IntProperty('quantity', quantity));
    properties.add(StringProperty('price', price));
  }
}
