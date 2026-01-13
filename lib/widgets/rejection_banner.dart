// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/onboarding_controller.dart';

// class RejectionBanner extends StatelessWidget {
//   const RejectionBanner({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final onboardingController = Get.find<OnboardingController>();

//     return Obx(() {
//       if (!onboardingController.isResubmission.value ||
//           onboardingController.rejectionReason.value.isEmpty) {
//         return SizedBox.shrink();
//       }

//       return Container(
//         margin: EdgeInsets.all(16),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.red.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.red.shade200),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'KYC Application Rejected',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Rejection Reason:',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.red.shade800,
//               ),
//             ),
//             SizedBox(height: 6),
//             Text(
//               onboardingController.rejectionReason.value,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.red.shade700,
//                 height: 1.4,
//               ),
//             ),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: Colors.blue.shade700,
//                     size: 16,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Your previous data has been loaded. Please review and update the highlighted fields, then resubmit.',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
