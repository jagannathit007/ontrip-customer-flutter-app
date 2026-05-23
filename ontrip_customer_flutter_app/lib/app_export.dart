//! Internal Library

export 'package:flutter/gestures.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

//! External Library

export 'package:get/get.dart';
export 'package:camera/camera.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:get_storage/get_storage.dart';
export 'package:fluttertoast/fluttertoast.dart';
// export 'package:image_cropper/image_cropper.dart';
// export 'package:path_provider/path_provider.dart';
// export 'package:carousel_slider/carousel_slider.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
// export 'package:google_generative_ai/google_generative_ai.dart';
// export 'package:smooth_page_indicator/smooth_page_indicator.dart';
// export 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// export 'package:intl_phone_field/countries.dart';
export 'package:intl_phone_field/intl_phone_field.dart';
export 'package:intl_phone_field/phone_number.dart';
export 'package:image_picker/image_picker.dart';
export 'package:flutter_image_compress/flutter_image_compress.dart';
export 'package:device_info_plus/device_info_plus.dart';
// export 'package:package_info_plus/package_info_plus.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:file_picker/file_picker.dart';
// export 'package:share_plus/share_plus.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:flutter_launcher_icons/abs/icon_generator.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:audioplayers/audioplayers.dart';
//!FIREBASE
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_messaging/firebase_messaging.dart';

//! APP BINDERS
export 'src/app_binders/splash_binder.dart';

//! CONTROLLERS
export 'src/screens/splash/splash_ctrl.dart';

export 'src/apis/environment_controller.dart';
// export 'src/controllers/add_service_controller.dart';

//* BUTTONS
export 'src/common/buttons/custom_back_btn.dart';
export 'src/common/buttons/custom_btn.dart';
export 'src/common/buttons/custom_close_btn.dart';
export 'src/common/buttons/custom_icon_btn.dart';
export 'src/common/buttons/custom_popup_menu_btn.dart';
export 'src/common/buttons/custom_tab_switch.dart';

//* Dialogs
export 'src/common/dialogs/delete_account_dialog.dart';
export 'src/common/dialogs/deletion_confirmation_dialog.dart';
export 'src/common/dialogs/dialog_structure.dart';
export 'src/common/dialogs/logout_dialog.dart';
export 'src/common/dialogs/popup_layout.dart';
export 'src/common/dialogs/custom_loading_dialog.dart';

export 'src/common/custom_country_form_field.dart';
export 'src/common/custom_form_field.dart';
export 'src/common/custom_frame_painter.dart';
export 'src/common/custom_image_picker_card.dart';
export 'src/common/custom_loading_indicator.dart';
export 'src/common/custom_network_image.dart';
export 'src/common/custom_radio_list_tile.dart';
export 'src/common/custom_rich_text.dart';
export 'src/common/no_data_widget.dart';
export 'src/common/multi_choice_chip.dart';

//! CORE
export 'src/core/app_session.dart';
export 'src/core/constants.dart';
export 'src/core/endpoints.dart';
export 'src/core/graphics.dart';
export 'src/core/string_constant.dart';

//! HELPER
export 'src/helper/app_date_format.dart';
export 'src/helper/app_extensions.dart';
export 'src/helper/app_permissions.dart';
export 'src/helper/app_share.dart';
export 'src/helper/app_text_style.dart';
export 'src/helper/app_toast.dart';
export 'src/helper/app_url.dart';
export 'src/helper/app_validator.dart';

//! MODELS
export 'src/models/booking_model.dart';
export 'src/models/bank_info_model.dart';
export 'src/models/profile_image_model.dart';
export 'src/models/sign_up_model.dart';
export 'src/models/community_model.dart';
export 'src/models/review_model.dart';

//! UTILS
export 'src/utils/util.dart';

//! API
export 'src/apis/api_manager.dart';
export 'src/apis/api_response.dart';
export 'src/apis/network_config.dart';

//! Service
export 'src/services/navigation_service.dart';
export 'src/services/pre_binder.dart';
export 'src/services/storage_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/socket_service.dart';

//! SCREENS

export 'src/screens/auth/sign_in/sign_in.dart';
export 'package:ontrip_customer_flutter_app/src/screens/auth/authentication_controller.dart';

export 'src/screens/splash/splash.dart';

export 'src/screens/dashboard/pages/home/home.dart';
export 'src/screens/dashboard/pages/home/home_controller.dart';

export 'src/screens/notifications/notification_ctrl.dart';
export 'src/screens/notifications/notifications_screen.dart';

export 'src/common/custom_bottom_nav_bar.dart';

export 'src/screens/dashboard/dashboard.dart';
export 'src/screens/dashboard/dashboard_ctrl.dart';

export 'src/screens/auth/verify_otp/verify_otp.dart';
export 'src/screens/auth/verify_otp/verify_otp_ctrl.dart';

export 'src/screens/settings/settings.dart';
export 'src/screens/settings/settings_ctrl.dart';
export 'src/screens/history/history.dart';
export 'src/screens/history/history_ctrl.dart';
export 'src/screens/community/community.dart';
export 'src/screens/community/community_ctrl.dart';
export 'src/screens/community/community_chat.dart';
export 'src/screens/community/community_chat_ctrl.dart';
export '/src/screens/community/community_media_ctrl.dart';
export 'src/screens/community/group_members.dart';
export 'src/screens/community/group_members_ctrl.dart';
export 'src/screens/community/community_media.dart';

export 'src/screens/edit_profile/edit_profile.dart';
export 'src/screens/edit_profile/edit_profile_controller.dart';

export 'src/screens/booking_details/booking_details.dart';
export 'src/screens/booking_details/booking_details_ctrl.dart';

export 'src/screens/vendor/packages/vendor_package_details.dart';
export 'src/screens/vendor/packages/vendor_package_details_ctrl.dart';

//! ROUTE
export 'src/routes/route_methods.dart';
export 'src/routes/route_names.dart';

//! SOURCE
export 'src/source/custom_read_more_text.dart';
export 'src/source/custom_debounce.dart';

//! THEME
export 'app_theme.dart';
