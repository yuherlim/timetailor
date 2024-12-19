// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class TaskDetailsScreen extends ConsumerStatefulWidget {
//   const TaskDetailsScreen({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _TaskDetailsScreenState();
// }

// class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.appBarColor,
//         title: const AppBarText("History"),
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert),
//             onSelected: (value) {
//               // Handle menu item selection
//               if (value == 'Clear History') {
//                 // Example action: Clear history logic
//                 showClearHistoryConfirmation(context);
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 const PopupMenuItem<String>(
//                   value: 'Clear History',
//                   child: Text('Clear History'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0, top: 16.0),
//             child: TitleTextInHistory(formattedDate),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 16.0),
//             child: Divider(
//               color: Colors.white, // Line color
//               thickness: 1, // Line thickness
//               height: 0,
//             ),
//           ),
//           completedTasks.isEmpty
//               ? const Expanded(
//                   child: Center(
//                     child: TitleTextInHistory(
//                       "No completed tasks for today.",
//                     ),
//                   ),
//                 )
//               : Expanded(
//                   child: ListView.builder(
//                     itemCount: completedTasks.length,
//                     itemBuilder: (context, index) {
//                       final task = completedTasks[index];
//                       return CompletedTaskListItem(task: task);
//                     },
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }
// }
