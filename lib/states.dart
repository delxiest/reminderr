import 'package:june/june.dart';

class EmptyState extends JuneState { }

void refreshReminds() => June.getState(() => EmptyState(), tag: "Reminds").setState();