import 'package:flutter/widgets.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:toastification/toastification.dart';

/// Extension to helps showing toast with consistent style
extension ShowToastX on BuildContext {
  /// Showing toast to user
  ///
  /// Use this whenever UI needs to show toast.
  ///
  /// Either [title] or [description] or both needs to be provided.
  ToastificationItem showToast({
    /// Toast type
    ToastificationType? type,

    /// Optional title of the toast
    String? title,

    /// Optional description of the toast
    String? description,

    /// Whether this toast can close automatically
    ///
    /// default to false
    bool autoClose = false,
  }) {
    assert(
      title != null || description != null,
      'Toast must have either title or description',
    );

    return toastification.show(
      context: this,
      type: type,
      title: title != null
          ? Text(
              title,
              style: text.titleMedium,
            )
          : null,
      description: description != null
          ? Text(
              description,
              style: text.bodyMedium,
            )
          : null,
      autoCloseDuration: autoClose ? kToastDuration : null,
    );
  }
}

/// Default duration for auto close toast
const kToastDuration = Duration(seconds: 5);
