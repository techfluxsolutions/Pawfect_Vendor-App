// import '../../libs.dart';

// class OnboardingWaitingScreen extends StatelessWidget {
//   OnboardingWaitingScreen({super.key});

//   final WaitingController controller = Get.put(WaitingController());

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.colorScheme.primary;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Center(
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(maxWidth: 400),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(height: MediaQuery.of(context).size.height * 0.1),

//                   // Icon
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: primaryColor.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.schedule, size: 50, color: primaryColor),
//                   ),

//                   SizedBox(height: 24),

//                   Text(
//                     'Almost There!',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),

//                   SizedBox(height: 12),

//                   Text(
//                     'Your vendor application is being reviewed.\nWe\'ll notify you within 24-48 hours.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),

//                   SizedBox(height: 40),

//                   // Progress indicator
//                   SizedBox(
//                     width: 200,
//                     child: LinearProgressIndicator(
//                       backgroundColor: primaryColor.withOpacity(0.1),
//                       valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//                     ),
//                   ),

//                   SizedBox(height: 40),

//                   // Contact support
//                   TextButton.icon(
//                     onPressed: () {},
//                     icon: Icon(Icons.help_outline, size: 20),
//                     label: Text('Contact Support'),
//                     style: TextButton.styleFrom(foregroundColor: primaryColor),
//                   ),

//                   SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import '../../libs.dart';

class OnboardingWaitingScreen extends StatelessWidget {
  OnboardingWaitingScreen({super.key});

  final WaitingController controller = Get.put(WaitingController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.schedule, size: 50, color: primaryColor),
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Almost There!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Your vendor application is being reviewed.\nWe\'ll notify you within 24-48 hours.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20),

                  // ✅ Status indicator
                  Obx(
                    () => Text(
                      'Status: ${controller.kycStatus.value}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Progress indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),

                  SizedBox(height: 40),

                  // ✅ Manual refresh button
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed:
                          controller.isChecking.value
                              ? null
                              : () => controller.checkStatus(),
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Contact support
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.help_outline, size: 20),
                    label: Text('Contact Support'),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
