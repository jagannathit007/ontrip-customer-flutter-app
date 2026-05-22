import 'package:ontrip_customer_flutter_app/src/screens/auth/sign_in/sign_in_ctrl.dart';
import '../../../../app_export.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Local colors to match the design perfectly
  // static const Color kPrimaryOrange = Color(0xFFE8693A);
  static const Color kPrimaryOrange = Color(0xFFE8693A);
  static const Color kDarkNavy = Color(0xFF1B213F);
  static const Color kBgColor = Color(0xFFFFF5ED);
  static const Color kWhite = Colors.white;
  static const Color kGreyText = Color(0xFF8E95A2);
  static const Color kSubwhite = Color(0xB3FFFFFF);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInCtrl>(
      builder: (ctrl) {
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
                      _buildSignInForm(ctrl),
                      const SizedBox(height: 20),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: kPrimaryOrange, shape: BoxShape.circle),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("JOURNEYS MADE EASY", style: AppTextStyle.bold.copyWith(fontSize: 10, color: kPrimaryOrange, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: kPrimaryOrange, borderRadius: BorderRadius.circular(20)),
                child: Text("v2", style: AppTextStyle.bold.copyWith(fontSize: 10, color: kWhite)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Welcome\nBack.", style: AppTextStyle.bold.copyWith(fontSize: 48, color: kWhite, height: 1.1, letterSpacing: -1)),
          const SizedBox(height: 16),
          Text(
            "Sign in to see your curated trip, talk to your agents and relive the journey.",
            style: AppTextStyle.regular.copyWith(fontSize: 14, color: kSubwhite, height: 1.5),
          ),
          const SizedBox(height: 20),
          // _buildTripInfoCard(),
        ],
      ),
    );
  }

  Widget _buildRoleChip(SignInCtrl ctrl, UserRole role, String label) {
    return Obx(() {
      final isSelected = ctrl.selectedRole.value == role;

      return Expanded(
        child: GestureDetector(
          onTap: () => ctrl.selectRole(role),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                // margin: const EdgeInsets.all(2),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), color: isSelected ? kPrimaryOrange : kWhite),
                child: Text(label, style: AppTextStyle.bold.copyWith(fontSize: 13, color: isSelected ? kPrimaryOrange : kGreyText)),
              ),
              Container(
                // width: 1,
                height: 5,
                color: isSelected ? kPrimaryOrange : kWhite,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSignInForm(SignInCtrl ctrl) {
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
          // ── Role selector ──────────────────────────────────────
          Text("SIGN IN AS", style: AppTextStyle.bold.copyWith(fontSize: 11, color: kGreyText, letterSpacing: 1)),
          const SizedBox(height: 10),
          Container(
            clipBehavior: Clip.hardEdge,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: kWhite,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(2, 4))],
              // border: Border.all(color: kGreyText.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                _buildRoleChip(ctrl, UserRole.customer, "Customer"),
                Container(width: 1, height: 45, color: kGreyText.withValues(alpha: 0.2)),
                _buildRoleChip(ctrl, UserRole.vendor, "Vendor"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── Phone number ───────────────────────────────────────
          Text("PHONE NUMBER", style: AppTextStyle.bold.copyWith(fontSize: 11, color: kGreyText, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryOrange.withValues(alpha: 0.5), width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: CachedNetworkImage(
                    imageUrl: "https://flagcdn.com/w40/in.png",
                    width: 24,
                    height: 18,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(Icons.flag, color: kGreyText, size: 24),
                    errorWidget: (context, url, error) => const Icon(Icons.flag, color: kGreyText, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                Text("+91", style: AppTextStyle.bold.copyWith(fontSize: 16, color: Constant.instance.black)),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: kGreyText.withValues(alpha: 0.3)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: ctrl.txtPhoneNumber,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTextStyle.bold.copyWith(fontSize: 16, color: Constant.instance.black, letterSpacing: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Your Phone Number",
                      hintStyle: TextStyle(color: kGreyText),
                      counterText: "",
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12),
          // Text(
          //   "Network error. Please try again.",
          //   style: AppTextStyle.medium.copyWith(
          //     fontSize: 12,
          //     color: kPrimaryOrange.withValues(alpha: 0.8),
          //   ),
          // ),
          const SizedBox(height: 24),
          _buildContinueButton(ctrl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_buildFeatureTag("Secure"), _buildFeatureTag("Private"), _buildFeatureTag("Instant")],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(String label) {
    return Text(label, style: AppTextStyle.medium.copyWith(fontSize: 12, color: kGreyText));
  }

  Widget _buildContinueButton(SignInCtrl ctrl) {
    return Obx(
      () => Material(
        color: kPrimaryOrange,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: ctrl.isLoadingForSignIn.value ? null : () => ctrl.signIn(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (ctrl.isLoadingForSignIn.value)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
                else ...[
                  // const Spacer(),
                  Text("Continue", style: AppTextStyle.bold.copyWith(fontSize: 18, color: kWhite)),
                  // const Spacer(),
                  SizedBox(width: 10),
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

  Widget _buildFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyle.medium.copyWith(fontSize: 12, color: kGreyText, height: 1.5),
            children: [
              const TextSpan(text: "By signing in, you agree to our "),
              TextSpan(
                text: "Terms",
                style: const TextStyle(color: kPrimaryOrange, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AppUrl.urlLaunch(url: StringConstants.termsCondition);
                  },
              ),
              const TextSpan(text: " and "),
              TextSpan(
                text: "Privacy Policy",
                style: const TextStyle(color: kPrimaryOrange, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    AppUrl.urlLaunch(url: StringConstants.privacyPolicy);
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
