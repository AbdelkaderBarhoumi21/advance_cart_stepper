import 'dart:async';

import 'package:flutter/foundation.dart';

import 'cart_stepper_types.dart';

/// A controller for managing cart stepper state externally.
///
/// This controller allows you to programmatically control the cart stepper
/// and listen to state changes. It's designed to work with any state
/// management solution.
///
/// ## Basic Example
/// ```dart
/// final controller = CartStepperController(initialQuantity: 0);
///
/// CartStepper(
///   quantity: controller.quantity,
///   onQuantityChanged: controller.setQuantity,
///   onRemove: controller.reset,
/// )
/// ```
///
/// ## Async Example with API calls
/// ```dart
/// final controller = CartStepperController(
///   initialQuantity: 0,
///   onError: (error, stack) => print('Error: $error'),
/// );
///
/// CartStepper(
///   quantity: controller.quantity,
///   isLoading: controller.isLoading,
///   onQuantityChangedAsync: (qty) => controller.setQuantityAsync(
///     qty,
///     () => api.updateCart(itemId, qty),
///   ),
/// )
/// ```
///
/// ## With Riverpod
/// ```dart
/// final cartItemProvider = StateNotifierProvider<CartStepperController, int>(
///   (ref) => CartStepperController(initialQuantity: 0),
/// );
/// ```
///
/// ## With Provider
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => CartStepperController(initialQuantity: 0),
/// )
/// ```
///
/// See also:
/// - [CartStepper] for the widget that displays the stepper
class CartStepperController extends ChangeNotifier with DiagnosticableTreeMixin {
  int _quantity;
  bool _isExpanded;
  bool _isLoading = false;
  int? _pendingQuantity;
  int _operationId = 0;
  bool _disposed = false;

  /// Whether this controller has been disposed.
  ///
  /// Once disposed, the controller should not be used.
  bool get isDisposed => _disposed;

  /// Minimum allowed quantity.
  final int minQuantity;

  /// Maximum allowed quantity.
  final int maxQuantity;

  /// Step value for increment/decrement operations.
  final int step;

  /// Optional validator for quantity changes.
  final QuantityValidator? validator;

  /// Optional error callback for async operations.
  final AsyncErrorCallback? onError;

  /// Optional callback when max quantity is reached.
  final VoidCallback? onMaxReached;

  /// Optional callback when min quantity is reached.
  final VoidCallback? onMinReached;

  /// Creates a cart stepper controller.
  ///
  /// The [initialQuantity] is clamped between [minQuantity] and [maxQuantity].
  CartStepperController({
    int initialQuantity = 0,
    this.minQuantity = 0,
    this.maxQuantity = 99,
    this.step = 1,
    this.validator,
    this.onError,
    this.onMaxReached,
    this.onMinReached,
  })  : assert(minQuantity >= 0, 'minQuantity must be >= 0'),
        assert(maxQuantity > minQuantity, 'maxQuantity must be > minQuantity'),
        assert(step > 0, 'step must be > 0'),
        _quantity = initialQuantity.clamp(minQuantity, maxQuantity),
        _isExpanded = initialQuantity > 0;

  /// Current quantity value.
  int get quantity => _quantity;

  /// Whether the stepper should be in expanded state.
  bool get isExpanded => _isExpanded;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Whether there's a pending operation.
  bool get hasPendingOperation => _pendingQuantity != null;

  /// The pending quantity value (for optimistic updates).
  int? get pendingQuantity => _pendingQuantity;

  /// Effective quantity to display (pending or actual).
  int get displayQuantity => _pendingQuantity ?? _quantity;

  /// Whether increment is possible from current state.
  bool get canIncrement => !_isLoading && displayQuantity + step <= maxQuantity;

  /// Whether decrement is possible from current state.
  bool get canDecrement => !_isLoading && displayQuantity - step >= minQuantity;

  /// Whether the quantity is at the minimum value.
  bool get isAtMin => displayQuantity <= minQuantity;

  /// Whether the quantity is at the maximum value.
  bool get isAtMax => displayQuantity >= maxQuantity;

  /// Set quantity directly.
  ///
  /// The value is clamped between [minQuantity] and [maxQuantity].
  /// Notifies listeners if the value changes.
  /// If called during an async operation, the pending operation is cancelled.
  void setQuantity(int value) {
    _checkDisposed();
    final newValue = value.clamp(minQuantity, maxQuantity);
    
    // Cancel any pending async operation to prevent race conditions
    if (_isLoading) {
      _operationId++;
      _isLoading = false;
    }
    
    if (_quantity != newValue || _pendingQuantity != null) {
      _quantity = newValue;
      _isExpanded = _quantity > 0;
      _pendingQuantity = null;
      notifyListeners();
    }
  }

  /// Set quantity asynchronously with loading state management.
  ///
  /// The [operation] is the async operation to perform (e.g., API call).
  /// Optionally set [optimistic] to true to update the display immediately.
  ///
  /// Example:
  /// ```dart
  /// await controller.setQuantityAsync(
  ///   newQty,
  ///   () => api.updateCart(itemId, newQty),
  ///   optimistic: true,
  /// );
  /// ```
  Future<bool> setQuantityAsync(
    int value,
    Future<void> Function() operation, {
    bool optimistic = false,
  }) async {
    _checkDisposed();
    final newValue = value.clamp(minQuantity, maxQuantity);

    // Check validator
    if (validator != null && !validator!(_quantity, newValue)) {
      return false;
    }

    final myOperationId = ++_operationId;
    final previousQuantity = _quantity;

    // Batch state changes and notify once to avoid multiple rebuilds
    if (optimistic) {
      _pendingQuantity = newValue;
    }
    _isLoading = true;
    notifyListeners();

    try {
      await operation();

      // Check if this operation was superseded
      if (_operationId != myOperationId) {
        return false;
      }

      _quantity = newValue;
      _isExpanded = _quantity > 0;
      _pendingQuantity = null;

      // Trigger callbacks
      if (_quantity >= maxQuantity) {
        onMaxReached?.call();
      } else if (_quantity <= minQuantity) {
        onMinReached?.call();
      }

      return true;
    } catch (error, stackTrace) {
      // Check if this operation was superseded or controller disposed
      if (_operationId != myOperationId || _disposed) {
        return false;
      }

      // Revert optimistic update
      if (optimistic) {
        _pendingQuantity = null;
        _quantity = previousQuantity;
      }

      // Safely call error callback, catching any exceptions it might throw
      try {
        onError?.call(error, stackTrace);
      } catch (callbackError, callbackStack) {
        assert(() {
          debugPrint('CartStepperController: Error in onError callback - $callbackError');
          debugPrint('Original error: $error');
          debugPrint('Callback stack trace: $callbackStack');
          return true;
        }());
      }
      return false;
    } finally {
      if (_operationId == myOperationId && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Increment quantity by [step].
  ///
  /// Does nothing if already at [maxQuantity] or loading.
  void increment() {
    _checkDisposed();
    if (canIncrement) {
      final newQty = displayQuantity + step;

      // Check validator
      if (validator != null && !validator!(displayQuantity, newQty)) {
        return;
      }

      setQuantity(newQty);
      if (_quantity >= maxQuantity) {
        onMaxReached?.call();
      }
    }
  }

  /// Increment quantity asynchronously.
  ///
  /// The [operation] is called with the new quantity value.
  Future<bool> incrementAsync(
    Future<void> Function(int newQty) operation, {
    bool optimistic = false,
  }) async {
    _checkDisposed();
    if (!canIncrement) return false;

    final newQty = displayQuantity + step;

    // Check validator
    if (validator != null && !validator!(displayQuantity, newQty)) {
      return false;
    }

    return setQuantityAsync(
      newQty,
      () => operation(newQty),
      optimistic: optimistic,
    );
  }

  /// Decrement quantity by [step].
  ///
  /// Does nothing if already at [minQuantity] or loading.
  void decrement() {
    _checkDisposed();
    if (canDecrement) {
      final newQty = displayQuantity - step;

      // Check validator
      if (validator != null && !validator!(displayQuantity, newQty)) {
        return;
      }

      setQuantity(newQty);
      if (_quantity <= minQuantity) {
        onMinReached?.call();
      }
    }
  }

  /// Decrement quantity asynchronously.
  ///
  /// The [operation] is called with the new quantity value.
  Future<bool> decrementAsync(
    Future<void> Function(int newQty) operation, {
    bool optimistic = false,
  }) async {
    _checkDisposed();
    if (!canDecrement) return false;

    final newQty = displayQuantity - step;

    // Check validator
    if (validator != null && !validator!(displayQuantity, newQty)) {
      return false;
    }

    return setQuantityAsync(
      newQty,
      () => operation(newQty),
      optimistic: optimistic,
    );
  }

  /// Reset to initial state (quantity = minQuantity, collapsed if minQuantity is 0).
  ///
  /// Respects [minQuantity] constraint - quantity is set to minQuantity, not 0.
  void reset() {
    _checkDisposed();
    final targetQty = minQuantity;
    if (_quantity != targetQty || _isExpanded || _pendingQuantity != null) {
      _quantity = targetQty;
      _isExpanded = targetQty > 0;
      _pendingQuantity = null;
      _isLoading = false;
      notifyListeners();
      
      // Trigger callback if at minimum
      if (_quantity <= minQuantity) {
        onMinReached?.call();
      }
    }
  }

  /// Reset asynchronously with an operation.
  ///
  /// Respects [minQuantity] constraint - quantity is set to minQuantity, not 0.
  Future<bool> resetAsync(Future<void> Function() operation) async {
    _checkDisposed();
    final myOperationId = ++_operationId;
    final targetQty = minQuantity;

    _isLoading = true;
    notifyListeners();

    try {
      await operation();

      if (_operationId != myOperationId) return false;

      _quantity = targetQty;
      _isExpanded = targetQty > 0;
      _pendingQuantity = null;
      
      // Trigger callback if at minimum
      if (_quantity <= minQuantity) {
        onMinReached?.call();
      }
      
      return true;
    } catch (error, stackTrace) {
      if (_operationId != myOperationId || _disposed) return false;
      // Safely call error callback, catching any exceptions it might throw
      try {
        onError?.call(error, stackTrace);
      } catch (callbackError, callbackStack) {
        assert(() {
          debugPrint('CartStepperController: Error in onError callback - $callbackError');
          debugPrint('Original error: $error');
          debugPrint('Callback stack trace: $callbackStack');
          return true;
        }());
      }
      return false;
    } finally {
      if (_operationId == myOperationId && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Cancel any pending async operation.
  void cancelOperation() {
    _checkDisposed();
    if (_pendingQuantity != null || _isLoading) {
      _operationId++;
      _pendingQuantity = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Expand the stepper.
  ///
  /// If quantity is 0, sets it to [minQuantity] or [step] (whichever is greater than 0),
  /// clamped to [maxQuantity].
  void expand() {
    _checkDisposed();
    if (!_isExpanded) {
      if (_quantity == 0) {
        // Calculate initial quantity, clamped to valid range
        final initialQty = minQuantity > 0 ? minQuantity : step;
        _quantity = initialQty.clamp(minQuantity, maxQuantity);
      }
      _isExpanded = true;
      notifyListeners();
    }
  }

  /// Collapse the stepper and reset quantity to [minQuantity].
  ///
  /// Respects [minQuantity] constraint - quantity is set to minQuantity, not 0.
  void collapse() {
    _checkDisposed();
    final targetQty = minQuantity;
    if (_isExpanded || _quantity != targetQty) {
      _isExpanded = false;
      _quantity = targetQty;
      _pendingQuantity = null;
      notifyListeners();
      
      // Trigger callback if at minimum
      if (_quantity <= minQuantity) {
        onMinReached?.call();
      }
    }
  }

  /// Set quantity to [maxQuantity].
  void setToMax() {
    setQuantity(maxQuantity);
  }

  /// Set quantity to [minQuantity].
  void setToMin() {
    setQuantity(minQuantity);
  }

  /// Throws an assertion error in debug mode if this controller has been disposed.
  ///
  /// This is used internally to catch programming errors where the controller
  /// is used after being disposed.
  void _checkDisposed() {
    assert(() {
      if (_disposed) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.',
        );
      }
      return true;
    }());
  }

  @override
  void dispose() {
    _disposed = true;
    // Increment operation ID to cancel any pending async operations
    _operationId++;
    _pendingQuantity = null;
    _isLoading = false;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('quantity', quantity));
    properties.add(IntProperty('displayQuantity', displayQuantity));
    properties.add(IntProperty('minQuantity', minQuantity));
    properties.add(IntProperty('maxQuantity', maxQuantity));
    properties.add(IntProperty('step', step));
    properties.add(FlagProperty('isExpanded', value: isExpanded, ifTrue: 'expanded'));
    properties.add(FlagProperty('isLoading', value: isLoading, ifTrue: 'loading'));
    properties.add(FlagProperty('canIncrement', value: canIncrement, ifFalse: 'atMax'));
    properties.add(FlagProperty('canDecrement', value: canDecrement, ifFalse: 'atMin'));
    properties.add(FlagProperty('isDisposed', value: _disposed, ifTrue: 'disposed'));
    if (_pendingQuantity != null) {
      properties.add(IntProperty('pendingQuantity', _pendingQuantity));
    }
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    final loading = _isLoading ? ', loading' : '';
    final pending = _pendingQuantity != null ? ', pending: $_pendingQuantity' : '';
    return 'CartStepperController(quantity: $_quantity, min: $minQuantity, max: $maxQuantity, step: $step$loading$pending)';
  }
}

/// Extension for easy integration with common state management patterns.
extension CartStepperControllerExtensions on CartStepperController {
  /// Create a copy with different parameters.
  ///
  /// Useful for creating derived controllers with adjusted limits.
  /// Note: Callbacks (validator, onError, etc.) are not copied.
  CartStepperController copyWith({
    int? initialQuantity,
    int? minQuantity,
    int? maxQuantity,
    int? step,
    QuantityValidator? validator,
    AsyncErrorCallback? onError,
    VoidCallback? onMaxReached,
    VoidCallback? onMinReached,
  }) {
    return CartStepperController(
      initialQuantity: initialQuantity ?? quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      step: step ?? this.step,
      validator: validator ?? this.validator,
      onError: onError ?? this.onError,
      onMaxReached: onMaxReached ?? this.onMaxReached,
      onMinReached: onMinReached ?? this.onMinReached,
    );
  }

  /// Convert to a map for serialization.
  ///
  /// The resulting map can be stored in persistent storage or sent over network.
  /// Note: Callbacks are not serialized.
  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'step': step,
      'isExpanded': isExpanded,
      'isLoading': isLoading,
    };
  }
}

/// Extension for creating a controller from JSON.
extension CartStepperControllerFromJson on Map<String, dynamic> {
  /// Create a [CartStepperController] from a JSON map.
  ///
  /// This is the inverse of [CartStepperControllerExtensions.toJson].
  CartStepperController toCartStepperController() {
    return CartStepperController(
      initialQuantity: this['quantity'] as int? ?? 0,
      minQuantity: this['minQuantity'] as int? ?? 0,
      maxQuantity: this['maxQuantity'] as int? ?? 99,
      step: this['step'] as int? ?? 1,
    );
  }
}
