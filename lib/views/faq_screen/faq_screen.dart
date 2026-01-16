import '../../libs.dart';
import '../../controllers/faq_controller.dart';

class FAQScreen extends StatelessWidget {
  FAQScreen({super.key});

  final FAQController controller = Get.put(FAQController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Help & FAQ'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // Show loading indicator
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        // Show empty state
        if (controller.faqs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No FAQs Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please check back later',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Show FAQ list
        return RefreshIndicator(
          onRefresh: controller.refreshFAQs,
          color: primaryColor,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.faqs.length,
            itemBuilder: (context, index) {
              final faq = controller.faqs[index];
              final isExpanded = controller.expandedIndex.value == index;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    childrenPadding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: primaryColor,
                    ),
                    onExpansionChanged: (expanded) {
                      controller.toggleExpanded(index);
                    },
                    children: [
                      Divider(height: 1, color: Colors.grey[200]),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq.answer,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
