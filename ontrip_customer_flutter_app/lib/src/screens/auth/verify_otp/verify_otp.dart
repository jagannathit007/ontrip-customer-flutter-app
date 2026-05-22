import '../../../../app_export.dart';

class VerifyOTPScreen extends GetView<VerifyOTPCtrl> {
  const VerifyOTPScreen({super.key});

  // Local colors to match the SignIn design
  static const Color kPrimaryOrange = Color(0xFFE8693A);
  static const Color kDarkNavy = Color(0xFF1B213F);
  static const Color kBgColor = Color(0xFFFFF5ED);
  static const Color kWhite = Colors.white;
  static const Color kGreyText = Color(0xFF8E95A2);
  static const Color kSubwhite = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kBgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildWelcomeCard(),
                  const SizedBox(height: 30),
                  _buildOTPCard(),
                  const SizedBox(height: 20),
                  // _buildFooter(),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CustomBackBtn(iconColor: Colors.black),
        const SizedBox(width: 8),
        // Container(
        //   width: 8,
        //   height: 8,
        //   decoration: const BoxDecoration(
        //     color: kPrimaryOrange,
        //     shape: BoxShape.circle,
        //   ),
        // ),
        const SizedBox(width: 8),
        Text("OnTrip", style: AppTextStyle.bold.copyWith(fontSize: 20, color: Constant.instance.black, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kDarkNavy, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("VERIFICATION", style: AppTextStyle.bold.copyWith(fontSize: 10, color: kPrimaryOrange, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Text("Verify OTP.", style: AppTextStyle.bold.copyWith(fontSize: 38, color: kWhite, height: 1.1, letterSpacing: -1)),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: AppTextStyle.regular.copyWith(fontSize: 14, color: kSubwhite, height: 1.5),
              children: [
                const TextSpan(text: "We've sent a 4-digit code to "),
                TextSpan(
                  text: "+91 ${controller.phone}",
                  style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ". Enter it below to continue."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: kDarkNavy.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ENTER OTP", style: AppTextStyle.bold.copyWith(fontSize: 11, color: kGreyText, letterSpacing: 1)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (index) => _buildOTPBox(index))),
          const SizedBox(height: 32),
          _buildVerifyButton(),
          const SizedBox(height: 24),
          // _buildResendOption(),
        ],
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: kBgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryOrange.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Center(
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1 && index < 3) {
              Get.focusScope?.nextFocus();
            } else if (value.isEmpty && index > 0) {
              Get.focusScope?.previousFocus();
            }
            controller.updateOTPValue();
          },
          controller: controller.localOTPControllers[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyle.bold.copyWith(fontSize: 24, color: kDarkNavy),
          decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Obx(
      () => Material(
        color: kPrimaryOrange,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: controller.isLoading.value ? null : () => controller.verifyOTP(),
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isLoading.value)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
                else ...[
                  Text("Verify & Proceed", style: AppTextStyle.bold.copyWith(fontSize: 18, color: kWhite)),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: kWhite, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_rounded, color: kPrimaryOrange, size: 20),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendOption() {
    return Obx(
      () => Center(
        child: Column(
          children: [
            Text(
              controller.canResend.value ? "Didn't receive the code?" : "Resend code in ${controller.resendTimer.value}s",
              style: AppTextStyle.medium.copyWith(fontSize: 14, color: kGreyText),
            ),
            if (controller.canResend.value)
              TextButton(
                onPressed: () => controller.resendOTP(),
                child: Text("Resend Code", style: AppTextStyle.bold.copyWith(fontSize: 14, color: kPrimaryOrange)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String label) {
    return Text(label, style: AppTextStyle.medium.copyWith(fontSize: 12, color: kGreyText));
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildFeatureTag("Secure"), _buildFeatureTag("Private"), _buildFeatureTag("Instant")]),
      ],
    );
  }
}
