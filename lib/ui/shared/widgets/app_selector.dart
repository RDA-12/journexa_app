import 'package:flutter/material.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Status of [AppSelector]
enum SelectorStatus {
  /// No operation
  idle,

  /// Fetching data
  loading,

  /// Error occurred
  error,
}

/// Controller for [AppSelector]
class AppSelectorController<T> extends ChangeNotifier {
  /// Creates new [AppSelector] with [initialValue]
  AppSelectorController({
    required this.displayAsString,
    T? initialValue,
    List<T> initialItems = const [],
  }) : _value = initialValue,
       _items = initialItems,
       _textEditingController = TextEditingController(
         text: initialValue != null ? displayAsString(initialValue) : null,
       );

  final TextEditingController _textEditingController;

  /// Returns controller for text input
  TextEditingController get textEditingController => _textEditingController;

  /// Callback to convert item to string
  final String Function(T) displayAsString;

  T? _value;

  /// Returns current selected value
  T? get value => _value;

  /// Sets new value and notifies listeners
  set value(T? value) {
    if (_value == value) {
      return;
    }
    _value = value;
    if (value != null) {
      _textEditingController.text = displayAsString(value);
    } else {
      _textEditingController.clear();
    }
    notifyListeners();
  }

  List<T> _items;

  /// Returns list of available items
  List<T> get items => _items;

  /// Sets new list of items and notifies listeners
  set items(List<T> items) {
    if (_items == items) {
      return;
    }
    _items = items;
    _status = SelectorStatus.idle;
    notifyListeners();
  }

  SelectorStatus _status = SelectorStatus.idle;

  /// Returns current status
  SelectorStatus get status => _status;

  /// Returns whether the [status] is [SelectorStatus.loading] or not
  bool get isLoading => _status == SelectorStatus.loading;

  /// Sets new isLoading and notifies listeners
  set isLoading(bool isLoading) {
    if (isLoading && _status == SelectorStatus.loading) {
      return;
    }
    _status = SelectorStatus.loading;
    notifyListeners();
  }

  AppException? _lastError;

  /// Returns last error
  AppException? get lastError => _lastError;

  /// Sets new last error and notifies listeners
  set lastError(AppException? lastError) {
    if (_lastError == lastError) {
      return;
    }
    _lastError = lastError;
    _status = SelectorStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

/// Widget to allows users select value from list of items
class AppSelector<T extends Object> extends StatelessWidget {
  /// Creates new [AppSelector]
  const AppSelector({
    required this.controller,
    required this.isRequired,
    super.key,
    this.label,
    this.exceptionBuilder,
    this.onSearch,
  });

  /// Whether the selector is required or not
  final bool isRequired;

  /// Label to be displayed
  final String? label;

  /// Controller to manage selector state
  final AppSelectorController<T> controller;

  /// Optional builder when error
  final Widget Function(BuildContext, AppException)? exceptionBuilder;

  /// Callback when search button is pressed
  final void Function(String?)? onSearch;

  /// Shows bottom modal with list of items
  Future<T?> showItems(BuildContext context) {
    return context.showBottomModal<T>(
      builder: (context) {
        late final Widget child;
        switch (controller.status) {
          case SelectorStatus.loading:
            child = Center(
              child: LoadingIndicator(
                semanticsLabel: context.l10n.commonLoadingSemanticsLabel,
              ),
            );
          case SelectorStatus.error:
            if (exceptionBuilder != null) {
              child = Center(
                child: exceptionBuilder!(
                  context,
                  controller.lastError!,
                ),
              );
            } else {
              child = Center(
                child: AppExceptionBox(
                  title: context.l10n.appSelectorErrorTitle,
                  description: controller.lastError!.code.toLocalizedString(
                    context,
                  ),
                ),
              );
            }
          case SelectorStatus.idle:
            if (controller.items.isEmpty) {
              child = AppEmptyBox(
                description: context.l10n.appSelectorEmptyItemsDescription,
              );
            } else {
              child = ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return CheckboxListTile(
                    title: Text(controller.displayAsString(item)),
                    value: controller.value == item,
                    onChanged: (checked) {
                      if (checked == null) return;
                      if (checked) {
                        Navigator.pop(context, item);
                      } else {
                        controller.value = null;
                      }
                    },
                  );
                },
              );
            }
        }

        return Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onSearch != null)
              _AppSelectorSearchBox(
                onSearch: onSearch!,
              ),
            Expanded(
              child: child,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: controller.textEditingController,
      isRequired: isRequired,
      label: label,
      readOnly: true,
      onPressed: () async {
        final result = await showItems(context);
        controller.value = result;
      },
    );
  }
}

class _AppSelectorSearchBox extends StatefulWidget {
  const _AppSelectorSearchBox({required this.onSearch});

  final ValueChanged<String?> onSearch;

  @override
  State<_AppSelectorSearchBox> createState() => _AppSelectorSearchBoxState();
}

class _AppSelectorSearchBoxState extends State<_AppSelectorSearchBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onSearch);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onSearch)
      ..dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      widget.onSearch(null);
    } else {
      widget.onSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormField(
      controller: _controller,
      isRequired: false,
      icon: const Icon(Icons.search_rounded),
    );
  }
}
