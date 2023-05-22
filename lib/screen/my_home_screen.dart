import 'package:chatter_flutter/app.dart';
import 'package:chatter_flutter/helpers.dart';
import 'package:chatter_flutter/page/calls_page.dart';
import 'package:chatter_flutter/page/contacts_page.dart';
import 'package:chatter_flutter/page/notifications_page.dart';
import 'package:chatter_flutter/screen/profile_screen.dart';
import 'package:chatter_flutter/themes.dart';
import 'package:chatter_flutter/widget/avatar.dart';
import 'package:chatter_flutter/widget/glowing_action_button.dart';
import 'package:chatter_flutter/widget/icon_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../page/messages_page.dart';


class MyHomeSreen extends StatefulWidget {
  const MyHomeSreen({super.key});
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<MyHomeSreen>{
  final pages = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];
  final title = const [
    "MessagesPage",
    "NotificationsPage",
    "CallsPage",
    "ContactsPage",
  ];
  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> titleIndex = ValueNotifier("Messager");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: titleIndex,
          builder: (BuildContext context, String value, _) => Text(value),
        ),
          leading: Align(
            alignment: Alignment.centerRight,
            child: IconBackground(
                icon: Icons.search,
                onTap: (){
                })
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Hero(
                  tag: 'hero-profile-picture',
                  child: Avatar.small(
                      url: context.currentUserImage,
                      onTap: () {
                        Navigator.of(context).push(ProfileScreen.route);
                      }),
                )
                
            )
          ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, int value, _){
          return pages[value];
        },

      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemSelected: (newIndex){
          setState(() {
            pageIndex.value = newIndex;
            titleIndex.value = title[newIndex];
          });
        },
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({super.key, required this.onItemSelected});
  final ValueChanged<int> onItemSelected;

  @override
  State<StatefulWidget> createState() => __BottomNavigationBar();

}

class __BottomNavigationBar extends State<_BottomNavigationBar>{

  var selectedIndex = 0;
  void handleSelected(int index){
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SafeArea(
            top: false,
            bottom: true,
            child: SizedBox(
                width: 90,
                height: 50,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavigationBarItem(index: 0, label: "Messages",icon: CupertinoIcons.bubble_left_bubble_right_fill, isSelected: (selectedIndex == 0), onTap: handleSelected),
                      _NavigationBarItem(index: 1, label: "Notifications",icon: CupertinoIcons.bell_solid, isSelected: (selectedIndex == 1), onTap: handleSelected),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GlowingActionButton(
                          color: AppColors.secondary,
                          icon: CupertinoIcons.add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => const Dialog(
                                child: AspectRatio(
                                  aspectRatio: 8 / 7,
                                  child: ContactsPage(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _NavigationBarItem(index: 2, label: "Calls",icon: CupertinoIcons.phone_fill, isSelected: (selectedIndex == 2), onTap: handleSelected),
                      _NavigationBarItem(index: 3, label: "Contacts",icon: CupertinoIcons.person_2_fill, isSelected: (selectedIndex == 3), onTap: handleSelected),
                    ]
                )
            )
        )
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({super.key,required this.index,required this.label, required this.icon, this.isSelected = false, required this.onTap});

  final ValueChanged<int> onTap;
  final bool isSelected;
  final int index;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:(){onTap(index);},
        child: SizedBox(
            height:70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Padding(padding: const EdgeInsets.only(top: 5.0),
                      child:Icon(icon, size: 20, color: isSelected ? AppColors.secondary: null,),
                  ),
                  const SizedBox(height: 6,),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11),
                  ),
              ],
            )
        )
    );
  }
}