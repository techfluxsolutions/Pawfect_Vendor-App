import '../../libs.dart';
import '../../controllers/bank_details_controller.dart';

class BankDetailsScreen extends StatelessWidget {
  BankDetailsScreen({super.key});

  final BankDetailsController controller = Get.put(BankDetailsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: Obx(
        () =>
            controller.isLoading.value
                ? _buildLoadingState()
                : _buildContent(primaryColor),
      ),
      bottomNavigationBar: _buildBottomActions(primaryColor),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Bank Details'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        Obx(
          () =>
              controller.hasExistingBankDetails.value
                  ? PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (value) {
                      if (value == 'delete') {
                        controller.deleteBankDetails();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Details',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  )
                  : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading bank details...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primaryColor) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Obx(() => _buildStatusCard(primaryColor)),

            SizedBox(height: 20),

            // Account Information Section
            _buildSectionCard('Account Information', primaryColor, [
              _buildTextField(
                controller: controller.accountHolderNameController,
                label: 'Account Holder Name',
                hint: 'Enter full name as per bank records',
                icon: Icons.person,
                validator:
                    (v) =>
                        controller.validateRequired(v, 'Account holder name'),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: controller.accountNumberController,
                label: 'Account Number',
                hint: 'Enter your bank account number',
                icon: Icons.account_balance,
                keyboardType: TextInputType.number,
                validator: controller.validateAccountNumber,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: controller.confirmAccountNumberController,
                label: 'Confirm Account Number',
                hint: 'Re-enter your account number',
                icon: Icons.verified,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != controller.accountNumberController.text) {
                    return 'Account numbers do not match';
                  }
                  return controller.validateAccountNumber(v);
                },
              ),
              SizedBox(height: 16),
              _buildAccountTypeDropdown(primaryColor),
            ]),

            SizedBox(height: 20),

            // Bank Information Section
            _buildSectionCard('Bank Information', primaryColor, [
              _buildTextField(
                controller: controller.ifscCodeController,
                label: 'IFSC Code',
                hint: 'Enter 11-character IFSC code',
                icon: Icons.code,
                textCapitalization: TextCapitalization.characters,
                validator: controller.validateIFSC,
                onChanged: (value) {
                  if (value.length == 11) {
                    controller.lookupIFSC(value);
                  }
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: controller.bankNameController,
                label: 'Bank Name',
                hint: 'Enter bank name',
                icon: Icons.account_balance,
                validator: (v) => controller.validateRequired(v, 'Bank name'),
                readOnly: true,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: controller.branchNameController,
                label: 'Branch Name',
                hint: 'Enter branch name and location',
                icon: Icons.location_on,
                validator: (v) => controller.validateRequired(v, 'Branch name'),
                readOnly: true,
              ),
            ]),

            SizedBox(height: 20),

            // UPI Section
            _buildSectionCard('UPI Details (Optional)', primaryColor, [
              Obx(
                () => SwitchListTile(
                  title: Text(
                    'Enable UPI Payments',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    'Add UPI ID for faster settlements',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  value: controller.isUpiEnabled.value,
                  onChanged: controller.toggleUPI,
                  activeColor: primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Obx(
                () =>
                    controller.isUpiEnabled.value
                        ? Column(
                          children: [
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: controller.upiIdController,
                              label: 'UPI ID',
                              hint: 'yourname@paytm',
                              icon: Icons.payment,
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateUPI,
                            ),
                          ],
                        )
                        : SizedBox.shrink(),
              ),
            ]),

            SizedBox(height: 20),

            // Important Notes
            _buildImportantNotes(primaryColor),

            SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Color primaryColor) {
    if (!controller.hasExistingBankDetails.value) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Bank Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add your bank details to receive settlements',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isVerified = controller.bankDetails['isVerified'] ?? false;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            color: isVerified ? Colors.green[700] : Colors.orange[700],
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'Bank Details Verified' : 'Verification Pending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isVerified ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isVerified
                      ? 'Your bank details are verified and active'
                      : 'Your bank details are under verification',
                  style: TextStyle(
                    fontSize: 12,
                    color: isVerified ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    Color primaryColor,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextCapitalization? textCapitalization,
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildAccountTypeDropdown(Color primaryColor) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: controller.selectedAccountType.value,
        decoration: InputDecoration(
          labelText: 'Account Type',
          prefixIcon: Icon(Icons.account_balance_wallet, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items:
            controller.accountTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
        onChanged: (value) => controller.setAccountType(value!),
        validator:
            (value) => controller.validateRequired(value, 'Account type'),
      ),
    );
  }

  Widget _buildImportantNotes(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildNoteItem('Bank details will be verified within 24-48 hours'),
          _buildNoteItem(
            'Ensure account holder name matches your registered name',
          ),
          _buildNoteItem('IFSC code will auto-fill bank and branch details'),
          _buildNoteItem(
            'UPI ID is optional but recommended for faster settlements',
          ),
          _buildNoteItem('You can update details anytime before verification'),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => ElevatedButton(
            onPressed:
                controller.isSaving.value ? null : controller.saveBankDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child:
                controller.isSaving.value
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Saving...'),
                      ],
                    )
                    : Text(
                      controller.hasExistingBankDetails.value
                          ? 'Update Bank Details'
                          : 'Save Bank Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
