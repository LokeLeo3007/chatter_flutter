import 'package:chatter_flutter/app.dart';
import 'package:chatter_flutter/screen/my_home_screen.dart';
import 'package:chatter_flutter/screen/select_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatter_flutter/themes.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  final client = StreamChatClient(streamKey);
  runApp(
      MyApp(
        appTheme: AppTheme(),
        client: client,
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appTheme,
    required this.client
  });
  final AppTheme appTheme;
  final StreamChatClient client;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,
      builder: (context,child){
        return StreamChatCore(
            client: client,
            child: ChannelsBloc(
              child: UsersBloc(child: child!),
            )
        );
      },
      home: const SelectUserScreen()
    );
  }
}