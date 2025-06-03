import 'package:flutter/material.dart';
import 'package:seekr_app/application/permission/permission_state.dart';

class PermissionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final PermissionResult result;
  final String label;
  final String semanticsLabel;
  const PermissionButton(
      {super.key,
      required this.icon,
      this.onTap,
      required this.result,
      required this.semanticsLabel,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
            onTap: result != PermissionResult.accepted ? onTap : null,
            tileColor: const Color(0xff01A0C7),
            leading: Icon(
              icon,
              color: Colors.white,
            ),
            textColor: Colors.white,
            title: Text(label),
            trailing: Icon(
              switch (result) {
                PermissionResult.accepted => Icons.done,
                PermissionResult.denied => Icons.close,
                PermissionResult.pending => Icons.arrow_forward,
              },
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
