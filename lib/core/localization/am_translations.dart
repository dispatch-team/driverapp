abstract class AmTranslations {
  static const Map<String, String> keys = {
    // ── Auth ──────────────────────────────────────────────────────────────────
    'login_dispatch': 'ዲስፓች',
    'login_title': 'ሾፌር\nመግቢያ',
    'login_subtitle': 'ጉዞዎን ለመጀመር\nማስረጃዎን ያስገቡ።',
    'login_username_label': 'የተጠቃሚ ስም ወይም ኢሜይል',
    'login_username_hint': 'የተጠቃሚ ስም ወይም ኢሜይል ያስገቡ',
    'login_password_label': 'የይለፍ ቃል',
    'login_btn': 'ግባ',
    'login_footer': 'ዲስፓች - ደህንነቱ የተጠበቀ መግቢያ',
    'snack_missing_fields_title': 'ያልተሞሉ ቦታዎች',
    'snack_missing_fields_body': 'እባክዎ የተጠቃሚ ስምዎን እና መዳረሻ ቁልፍዎን ያስገቡ።',
    'snack_login_failed_title': 'መግቢያ አልተሳካም',

    // ── Navigation ────────────────────────────────────────────────────────────
    'nav_orders': 'ትዕዛዞች',
    'nav_history': 'ታሪክ',
    'nav_profile': 'መገለጫ',

    // ── Orders ────────────────────────────────────────────────────────────────
    'orders_title': 'ንቁ ጭነቶች',
    'orders_subtitle': 'በአሁኑ ጊዜ ለጉዞዎ የተሰጡ',
    'orders_empty_title': 'ምንም ንቁ ጭነቶች የሉም',
    'orders_empty_subtitle': 'አሁን ምንም ጭነት አልተሰጥዎትም።',
    'orders_view_details': 'ዝርዝር ይመልከቱ',
    'orders_pickup_label': 'መውሰጃ',
    'orders_dropoff_label': 'ማድረሻ',
    'orders_unit_kg': 'ኪጂ',
    'orders_unit_item': 'ዕቃ',
    'orders_unit_items': 'ዕቃዎች',
    'orders_filter_all': 'ሁሉም',
    'orders_filter_assigned': 'የተሰጠ',
    'orders_filter_in_transit': 'በመጓጓዝ ላይ',
    'orders_retry_more': 'ተጨማሪ ጭነት ዳግም ሞክር',

    // ── History ───────────────────────────────────────────────────────────────
    'history_title': 'ታሪክ',
    'history_subtitle': 'የተጠናቀቁ እና ያልተሳኩ ጭነቶችዎ',
    'history_empty_title': 'ታሪክ የለም',
    'history_empty_subtitle': 'የተጠናቀቁ እና ያልተሳኩ ጭነቶች እዚህ ይታያሉ።',
    'history_view_details': 'ዝርዝር ይመልከቱ',
    'history_filter_all': 'ሁሉም',
    'history_filter_delivered': 'ደርሷል',
    'history_filter_failed': 'አልተሳካም',
    'history_retry_more': 'ተጨማሪ ጭነት ዳግም ሞክር',

    // ── Shipment detail ───────────────────────────────────────────────────────
    'detail_merchant_pickup': 'ነጋዴ (መውሰጃ)',
    'detail_customer_dropoff': 'ደንበኛ (ማድረሻ)',
    'detail_btn_arrived': 'ወደ መውሰጃ ደረሱ',
    'detail_btn_delivered': 'ደርሷል',
    'detail_btn_verify': 'ጭነት ያረጋግጡ',
    'detail_btn_confirm_failure': 'ውድቀት ያረጋግጡ',
    'detail_mark_failed': 'ውድቀት ምልክት ያድርጉ',
    'detail_section_pkg_info': 'የጥቅል መረጃ',
    'detail_section_description': 'መግለጫ',
    'detail_section_remark': 'ማሳሰቢያ',
    'detail_section_timeline': 'የሁኔታ ጊዜሰሌዳ',
    'detail_section_items': 'ዕቃዎች',
    'detail_remark_hint': 'ለምሳሌ፡ ደንበኛው በአድራሻው አልነበሩም...',
    'detail_verify_label': 'የደህንነት ፕሮቶኮል',
    'detail_verify_heading': 'ደንበኛውን\nኮዱን ይጠይቁ',
    'detail_verify_subtitle':
        "ጭነቱን ለማስረከብ ተቀባዩ የሰጠዎትን 6-ቁምፊ 'ደህንነቱ የተጠበቀ ኮድ' ያስገቡ።",
    'detail_fail_label': 'ውድቀት ሪፖርት',
    'detail_fail_heading': 'ጭነት\nውድቀት ምልክት ያድርጉ',
    'detail_fail_subtitle':
        'ለጭነቱ ውድቀት ምክንያት ያቅርቡ። ይህ ይቀዳል እናም ለነጋዴው ይላካል።',
    'detail_snack_verified_title': 'ጭነት ተረጋግጧል',
    'detail_snack_verified_body': 'ጭነቱ በተሳካ ሁኔታ ተረጋግጧል።',

    // ── Shipment status labels ─────────────────────────────────────────────────
    'status_pending': 'በጥበቃ ላይ',
    'status_courier_assigned': 'ኩሪየር ተሰጥቷል',
    'status_driver_assigned': 'ለሾፌር ተሰጥቷል',
    'status_in_transit': 'በጉዞ ላይ',
    'status_delivered': 'ደርሷል',
    'status_failed': 'አልተሳካም',
    'status_returned': 'ተመልሷል',
    'status_cancelled': 'ተሰርዟል',

    // ── Timeline step labels ──────────────────────────────────────────────────
    'timeline_created': 'ተፈጥሯል',
    'timeline_courier_assigned': 'ኩሪየር ተሰጥቷል',
    'timeline_driver_assigned': 'ሾፌር ተሰጥቷል',
    'timeline_picked_up': 'ተወስዷል',
    'timeline_in_transit': 'በጉዞ ላይ',
    'timeline_delivered': 'ደርሷል',
    'timeline_failed': 'አልተሳካም',
    'timeline_returned': 'ተመልሷል',
    'timeline_cancelled': 'ተሰርዟል',

    // ── Profile ───────────────────────────────────────────────────────────────
    'profile_title': 'መገለጫ',
    'profile_section_contact': 'ዕውቂያ',
    'profile_section_vehicle': 'ተሽከርካሪ',
    'profile_vehicle_type_label': 'የተሽከርካሪ ዓይነት',
    'profile_license_label': 'የሠሌዳ ቁጥር',
    'profile_emergency_label': 'የድንገተኛ ዕውቂያ',
    'profile_section_account': 'መለያ',
    'profile_driver_id_label': 'የሾፌር መለያ',
    'profile_company_id_label': 'የኩባንያ መለያ',
    'profile_rating_label': 'ደረጃ',
    'profile_reviews_label': 'ግምገማዎች',
    'profile_sign_out': 'ውጣ',

    // ── Map ───────────────────────────────────────────────────────────────────
    'map_open_google_maps': 'በGoogle Maps ክፈት',
    'map_marker_you': 'እርስዎ',
    'map_marker_destination': 'መድረሻ',
    'map_tap_to_expand': 'ለማስፋፋት ይንኩ',
    'map_enable_location': 'ጉዞዎን ለማየት ቦታ ያስቃጡ',
    'map_retry': 'ዳግም ሞክር',

    // ── Common ────────────────────────────────────────────────────────────────
    'common_retry': 'ዳግም ሞክር',
    'common_error_unexpected': 'ያልተጠበቀ ስህተት ተከስቷል።',
    'common_error_connection': 'የግንኙነት ስህተት። እባክዎ ዳግም ሞክሩ።',
  };
}
