// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/onboarding_controller.dart';

// class HighlightedTextField extends StatelessWidget {
//   final String fieldName;
//   final String labelText;
//   final String hintText;
//   final Function(String) onChanged;
//   final TextInputType? keyboardType;
//   final int? maxLines;
//   final int? maxLength;
//   final bool isRequired;
//   final String? initialValue;

//   const HighlightedTextField({
//     Key? key,
//     required this.fieldName,
//     required this.labelText,
//     required this.hintText,
//     required this.onChanged,
//     this.keyboardType,
//     this.maxLines = 1,
//     this.maxLength,
//     this.isRequired = true,
//     this.initialValue,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final onboardingController = Get.find<OnboardingController>();

//     return Obx(() {
//       final isRejected = onboardingController.isFieldRejected(fieldName);
//       final borderColor = onboardingController.getFieldBorderColor(fieldName);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Label with rejection indicator
//           Row(
//             children: [
//               Text(
//                 labelText,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: isRejected ? Colors.red : Colors.grey[800],
//                 ),
//               ),
//               if (isRequired)
//                 Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
//               if (isRejected) ...[
//                 SizedBox(width: 8),
//                 Icon(Icons.error_outline, color: Colors.red, size: 18),
//               ],
//             ],
//           ),
//           SizedBox(height: 8),

//           // Text field with conditional styling
//           TextFormField(
//             initialValue: initialValue,
//             onChanged: onChanged,
//             keyboardType: keyboardType,
//             maxLines: maxLines,
//             maxLength: maxLength,
//             decoration: InputDecoration(
//               hintText: hintText,
//               hintStyle: TextStyle(color: Colors.grey[400]),
//               filled: true,
//               fillColor:
//                   isRejected ? Colors.red.withOpacity(0.05) : Colors.grey[50],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: borderColor, width: 1.5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: borderColor, width: 1.5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: isRejected ? Colors.red : Colors.blue,
//                   width: 2,
//                 ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.red, width: 1.5),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//             ),
//           ),

//           // Rejection reason display
//           if (isRejected &&
//               onboardingController.rejectionReason.value.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(top: 8),
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.red, size: 16),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'This field was rejected. Please review and update.',
//                         style: TextStyle(
//                           color: Colors.red.shade700,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }

// class HighlightedFileUpload extends StatelessWidget {
//   final String fieldName;
//   final String labelText;
//   final String fileName;
//   final VoidCallback onTap;
//   final bool isRequired;

//   const HighlightedFileUpload({
//     Key? key,
//     required this.fieldName,
//     required this.labelText,
//     required this.fileName,
//     required this.onTap,
//     this.isRequired = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final onboardingController = Get.find<OnboardingController>();

//     return Obx(() {
//       final isRejected = onboardingController.isFieldRejected(fieldName);
//       final borderColor = onboardingController.getFieldBorderColor(fieldName);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Label with rejection indicator
//           Row(
//             children: [
//               Text(
//                 labelText,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: isRejected ? Colors.red : Colors.grey[800],
//                 ),
//               ),
//               if (isRequired)
//                 Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
//               if (isRejected) ...[
//                 SizedBox(width: 8),
//                 Icon(Icons.error_outline, color: Colors.red, size: 18),
//               ],
//             ],
//           ),
//           SizedBox(height: 8),

//           // File upload container
//           GestureDetector(
//             onTap: onTap,
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color:
//                     isRejected ? Colors.red.withOpacity(0.05) : Colors.grey[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: borderColor, width: 1.5),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     fileName.isEmpty ? Icons.upload_file : Icons.check_circle,
//                     color:
//                         fileName.isEmpty
//                             ? (isRejected ? Colors.red : Colors.grey[600])
//                             : Colors.green,
//                     size: 24,
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       fileName.isEmpty ? 'Tap to upload file' : fileName,
//                       style: TextStyle(
//                         color:
//                             fileName.isEmpty
//                                 ? (isRejected ? Colors.red : Colors.grey[600])
//                                 : Colors.grey[800],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: Colors.grey[400],
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Rejection reason display
//           if (isRejected &&
//               onboardingController.rejectionReason.value.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(top: 8),
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.red, size: 16),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'This document was rejected. Please upload a new one.',
//                         style: TextStyle(
//                           color: Colors.red.shade700,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }

// class HighlightedDropdownField extends StatelessWidget {
//   final String fieldName;
//   final String labelText;
//   final List<String> items;
//   final RxString selectedValue;
//   final Function(String) onChanged;
//   final bool isRequired;

//   const HighlightedDropdownField({
//     Key? key,
//     required this.fieldName,
//     required this.labelText,
//     required this.items,
//     required this.selectedValue,
//     required this.onChanged,
//     this.isRequired = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final onboardingController = Get.find<OnboardingController>();

//     return Obx(() {
//       final isRejected = onboardingController.isFieldRejected(fieldName);
//       final borderColor = onboardingController.getFieldBorderColor(fieldName);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Label with rejection indicator
//           Row(
//             children: [
//               Text(
//                 labelText,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: isRejected ? Colors.red : Colors.grey[800],
//                 ),
//               ),
//               if (isRequired)
//                 Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
//               if (isRejected) ...[
//                 SizedBox(width: 8),
//                 Icon(Icons.error_outline, color: Colors.red, size: 18),
//               ],
//             ],
//           ),
//           SizedBox(height: 8),

//           // Dropdown field with conditional styling
//           DropdownButtonFormField<String>(
//             value: selectedValue.value.isEmpty ? null : selectedValue.value,
//             hint: Text(labelText),
//             items:
//                 items
//                     .map(
//                       (item) =>
//                           DropdownMenuItem(value: item, child: Text(item)),
//                     )
//                     .toList(),
//             onChanged: (value) => onChanged(value ?? ''),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor:
//                   isRejected ? Colors.red.withOpacity(0.05) : Colors.grey[50],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: borderColor, width: 1.5),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: borderColor, width: 1.5),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: isRejected ? Colors.red : Colors.blue,
//                   width: 2,
//                 ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.red, width: 1.5),
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//               counterText: '',
//             ),
//           ),

//           // Rejection reason display
//           if (isRejected &&
//               onboardingController.rejectionReason.value.isNotEmpty)
//             Padding(
//               padding: EdgeInsets.only(top: 8),
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.red, size: 16),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'This field was rejected. Please review and update.',
//                         style: TextStyle(
//                           color: Colors.red.shade700,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }
