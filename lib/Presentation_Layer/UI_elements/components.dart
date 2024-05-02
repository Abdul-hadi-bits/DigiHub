// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;

  ProgressHUD({
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];
    widgetList.add(child);
    if (inAsyncCall) {
      final modal = new Stack(
        children: [
          new Opacity(
            opacity: opacity,
            child:
                ModalBarrier(dismissible: false, color: Colors.grey.shade300),
          ),
          new Center(
            child:
                new CupertinoActivityIndicator(color: Colors.blue, radius: 15),
          ),
        ],
      );
      widgetList.add(modal);
    } else {}
    return Stack(
      children: widgetList,
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? prefixText;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? errorMsg;
  final String? label;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final void Function(String)? onChanged;
  final int? maxLength;

  const MyTextField(
      {super.key,
      this.label,
      this.textInputAction,
      this.controller,
      this.maxLengthEnforcement,
      this.prefixText,
      required this.hintText,
      required this.obscureText,
      required this.keyboardType,
      this.suffixIcon,
      this.onTap,
      this.prefixIcon,
      this.validator,
      this.focusNode,
      this.maxLength,
      this.errorMsg,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        focusNode: focusNode,
        maxLength: maxLength,
        maxLengthEnforcement: maxLengthEnforcement,
        onTap: onTap,
        textInputAction: textInputAction,
        onChanged: onChanged,
        decoration: InputDecoration(
          label: label == null ? null : Text(label!),
          suffixIcon: suffixIcon,
          prefixText: prefixText,
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          errorText: errorMsg,
        ),
      ),
    );
  }
}

errorDialog(BuildContext context, String error) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Colors.white,
    icon: Icon(Icons.error, size: 30),
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "REASON : $error",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    ),
    elevation: 0,
    title: Text("Failed"),
    contentPadding: const EdgeInsets.all(10),
  );
  showDialog(
    barrierDismissible: true,
    barrierColor: Colors.transparent.withOpacity(0.3),
    context: context,
    builder: (BuildContext _) {
      return PopScope(canPop: true, child: alert);
    },
  );
}

confirmDialog(
    {required BuildContext context,
    required String alertText,
    required TextButton confirmButton,
    required TextButton cancelButton}) {
  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    backgroundColor: Colors.white,
    icon: Icon(Icons.error, size: 30),
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [confirmButton, cancelButton],
      ),
    ),
    elevation: 0,
    title: Text(alertText),
    contentPadding: const EdgeInsets.all(10),
  );
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.transparent.withOpacity(0.3),
    context: context,
    builder: (BuildContext _) {
      return PopScope(canPop: true, child: alert);
    },
  );
}

class MyAppBar extends AppBar {
  final Color? backGroundColor;
  final String ttle;
  final void Function()? onPressed;
  final bool? fitTitle;
  final bool? statusBarDark;
  final bool? italikTitle;
  final bool? showLeading;
  final double? titleSpacing;

  final Icon? icons;
  final List<Widget>? actions;
  MyAppBar(
      {required BuildContext context,
      this.showLeading,
      this.titleSpacing,
      this.italikTitle,
      this.backGroundColor,
      required this.ttle,
      this.statusBarDark,
      this.fitTitle,
      this.icons,
      this.actions,
      this.onPressed})
      : super(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          backgroundColor: backGroundColor ?? Colors.white,
          actions: actions,
          titleSpacing: titleSpacing ?? 0,
          leading: showLeading == false
              ? null
              : IconButton(
                  icon: icons ?? Icon(CupertinoIcons.back, color: Colors.black),
                  onPressed: onPressed,
                ),
          title: fitTitle != null
              ? FittedBox(
                  child: Text(
                    ttle,
                    style: TextStyle(
                        fontSize: 30,
                        fontStyle: italikTitle == true
                            ? FontStyle.italic
                            : FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                )
              : Text(
                  ttle,
                  style: TextStyle(
                      fontStyle: italikTitle == true
                          ? FontStyle.italic
                          : FontStyle.normal,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                statusBarDark == null ? Brightness.light : Brightness.dark,
            statusBarColor:
                statusBarDark == null ? Colors.black : Colors.transparent,
            systemNavigationBarColor: Colors.black,
          ),
        );
}

class MySmallElevatedTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? width;
  final Color? disableColor;
  final Color? color;
  final Widget? child;
  const MySmallElevatedTextButton({
    Key? key,
    this.onPressed,
    this.child,
    this.color,
    this.width,
    this.disableColor,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.3,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child ??
            FittedBox(
              child: Text(text,
                  style: TextStyle(
                    color: disableColor != null ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w900,
                  )),
            ),
        style: ElevatedButton.styleFrom(
          //  elevation: 5,
          backgroundColor:
              disableColor ?? color ?? const Color.fromARGB(255, 255, 160, 0),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

class MyLongElevatedTextButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  const MyLongElevatedTextButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

void myCustomShowDialog(
    {required BuildContext context,
    required Widget child,
    bool? blur,
    Color? barrierColor,
    bool? dissmissable,
    double? sigmaX,
    double? sigmaY}) {
  showDialog(
    barrierDismissible: dissmissable ?? false,
    context: context,
    barrierColor: barrierColor ?? null,
    useSafeArea: true,
    builder: (_) {
      return blur != false
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: sigmaX ?? 10,
                sigmaY: sigmaY ?? 10,
              ),
              child: child,
            )
          : child;
    },
  );
}

class MySimpleDialog extends StatelessWidget {
  final List<Widget> children;
  final Widget titleChild;
  const MySimpleDialog({
    Key? key,
    required this.children,
    required this.titleChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: titleChild,
      elevation: 0,
      contentPadding: const EdgeInsets.all(10),
      children: children,
    );
  }
}

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  const BackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const AlignmentDirectional(20, -1.2),
          child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.5),
            ), //Theme.of(context).colorScheme.tertiary),
          ),
        ),
        Align(
          alignment: const AlignmentDirectional(-2.7, -1.2),
          child: Container(
              height: MediaQuery.of(context).size.width / 1.3,
              width: MediaQuery.of(context).size.width / 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.5),
              ) //Theme.of(context).colorScheme.secondary),
              ),
        ),
        Align(
          alignment: const AlignmentDirectional(2.7, -1.2),
          child: Container(
              height: MediaQuery.of(context).size.width / 1.3,
              width: MediaQuery.of(context).size.width / 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.5),
              ) //Theme.of(context).colorScheme.primary),
              ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
          child: Container(),
        ),
        child,
      ],
    );
  }
}

class MyPinCodeTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final void Function(String)? onCompleted;
  const MyPinCodeTextField({
    Key? key,
    required this.onChanged,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      pastedTextStyle: TextStyle(
        color: Colors.green.shade600,
        fontWeight: FontWeight.bold,
      ),
      length: 6,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        inactiveColor: Colors.orange,
        borderWidth: 1,
        inactiveFillColor: Colors.grey,
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(15),
        fieldHeight: 50,
        fieldWidth: 50,
        activeFillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
      boxShadows: const [
        BoxShadow(
          offset: Offset(0, 1),
          color: Colors.black12,
          blurRadius: 10,
        )
      ],
      onCompleted: onCompleted,
      onChanged: onChanged,
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
    );
  }
}

/// Partially visible bottom sheet that can be dragged into the screen.
/// Provides different views for expanded and collapsed states.
class DraggableBottomSheet extends StatefulWidget {
  /// This widget will hide behind the sheet when expanded.
  final Widget backgroundWidget;

  /// Child to be displayed when sheet is not expended.
  final Widget previewChild;

  /// Child of expended sheet.
  final Widget expandedChild;

  final double setHeight;

  /// Alignment of the sheet.
  final Alignment alignment;

  /// Whether to blur the background while sheet expnasion (true: modal-sheet
  /// false: persistent-sheet)
  final bool blurBackground;

  /// Extent from the min-height to change from [previewChild] to
  /// [expandedChild].
  final double expansionExtent;

  /// Max-extent for sheet expansion.
  final double maxExtent;

  /// Min-extent for the sheet, also the original height of the sheet.
  final double minExtent;

  /// Scroll direction of the sheet.
  final Axis scrollDirection;

  const DraggableBottomSheet({
    Key? key,
    required this.backgroundWidget,
    required this.previewChild,
    required this.expandedChild,
    this.alignment = Alignment.bottomLeft,
    this.blurBackground = true,
    this.expansionExtent = 10,
    this.setHeight = 10,
    this.maxExtent = double.infinity,
    this.minExtent = 20,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  _DraggableBottomSheetState createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  late double currentHeight;
  double? newHeight;

  @override
  void initState() {
    currentHeight = widget.minExtent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.backgroundWidget,
        (currentHeight - widget.minExtent < 10 || !widget.blurBackground)
            ? const SizedBox()
            : Positioned.fill(
                child: GestureDetector(
                onTap: () => setState(() => currentHeight > widget.minExtent),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  ),
                ),
              )),
        Align(
          alignment: widget.alignment,
          child: GestureDetector(
            child: SizedBox(
              width: (widget.scrollDirection == Axis.vertical)
                  ? double.infinity
                  : widget.setHeight,
              height: (widget.scrollDirection == Axis.horizontal)
                  ? double.infinity
                  : widget.setHeight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (widget.scrollDirection == Axis.vertical)
                      ? double.infinity
                      : widget.setHeight,
                  maxHeight: (widget.scrollDirection == Axis.horizontal)
                      ? double.infinity
                      : widget.setHeight,
                ),
                child: (widget.setHeight <= widget.minExtent)
                    ? widget.previewChild
                    : widget.expandedChild,
                /*  (currentHeight - widget.minExtent < widget.expansionExtent)
                        ? widget.previewChild
                        : widget.expandedChild, */
              ),
            ),
          ),
        ),
      ],
    );
  }
}
