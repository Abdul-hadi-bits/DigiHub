import 'package:flutter/material.dart';

import '../state/inherited_chat_theme.dart';
import '../state/inherited_l10n.dart';

/// A class that represents send button widget.
class UpdateButton extends StatelessWidget {
  /// Creates send button widget.
  const UpdateButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        margin: InheritedChatTheme.of(context).theme.sendButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: Semantics(
          label: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
          child: IconButton(
            constraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 24,
            ),
            icon: InheritedChatTheme.of(context).theme.sendButtonIcon ??
                Icon(
                  Icons.check_circle_sharp,
                  size: 35,
                  color: Colors.grey.shade100,
                ),
            /* Image.asset(
                  'assets/icon-send.png',
                  color: InheritedChatTheme.of(context).theme.inputTextColor,
                  package: 'flutter_chat_ui',
                ), */
            onPressed: onPressed,
            //padding: padding,
            splashRadius: 24,
            tooltip:
                InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
          ),
        ),
      );
}
