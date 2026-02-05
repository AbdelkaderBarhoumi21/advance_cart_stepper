/// Callback type for synchronous quantity changes.
typedef QuantityChangedCallback = void Function(int quantity);

/// Callback type for asynchronous quantity changes with loading state.
///
/// When this callback is used instead of [QuantityChangedCallback],
/// the stepper will show a loading indicator while the future completes.
typedef AsyncQuantityChangedCallback = Future<void> Function(int quantity);

/// Callback for validating quantity changes before they occur.
///
/// Return `true` to allow the change, `false` to prevent it.
typedef QuantityValidator = bool Function(int currentQuantity, int newQuantity);

/// Callback for handling errors during async operations.
///
/// This is called when [onQuantityChangedAsync] or [onRemoveAsync] throws.
/// The loading state is cleaned up automatically regardless of whether
/// this callback is provided.
typedef AsyncErrorCallback = void Function(Object error, StackTrace stackTrace);

/// Callback when a quantity change is rejected by the validator.
///
/// Provides the attempted new quantity that was rejected.
/// Useful for showing feedback like "Cannot add more items".
typedef ValidationRejectedCallback = void Function(
    int currentQuantity, int attemptedQuantity);

/// Callback when an async operation is cancelled.
///
/// This is called when a new operation starts before the previous one completes,
/// or when the widget is disposed during an operation.
typedef OperationCancelledCallback = void Function(int attemptedQuantity);

/// Enum representing the type of quantity change operation.
enum QuantityChangeType {
  /// User tapped increment button
  increment,

  /// User tapped decrement button
  decrement,

  /// User tapped add button (from collapsed state)
  add,

  /// User tapped delete/remove button
  remove,

  /// Long press rapid increment
  longPressIncrement,

  /// Long press rapid decrement
  longPressDecrement,
}
