// import 'package:flutter/material.dart';
// import 'package:poolinspection/src/pages/done.dart';
// import 'package:poolinspection/src/pages/photo.dart';
// import 'package:poolinspection/src/pages/review.dart';
// import 'package:scaffold_tab_bar/scaffold_tab_bar.dart';
// import '../../config/app_config.dart' as config;

// class TabsView extends StatelessWidget {
//   const TabsView({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldTabBar(
//       children: [
//         ScreenTab(
//           screen: PhotoWidget(),
//           tab: BottomNavigationBarItem(
//             activeIcon: Icon(Icons.access_alarm,color: Colors.red,),
//             icon: Icon(Icons.timer,color: config.Colors().mainColor(1)),
//             backgroundColor: Colors.black,
//             title: Text('Processing'),
//           ),
//         ),
//         ScreenTab(
//           screen: ReviewWidget(),
//           tab: BottomNavigationBarItem(
//             activeIcon: Icon(Icons.access_alarm,color: Colors.red,),
//             icon: Icon(
//               Icons.rate_review,
//               color: config.Colors().mainColor(1),
//             ),
//             title: Text('Review'),
//           ),
//         ),
//         ScreenTab(
//           screen: DoneWidget(),
//           tab: BottomNavigationBarItem(
//             activeIcon: Icon(Icons.access_alarm,color: Colors.red,),
//             icon: Icon(Icons.done,color: config.Colors().mainColor(1)),
//             title: Text('Done'),
//           ),
//         ),
//       ],
//     );
//   }
// }
