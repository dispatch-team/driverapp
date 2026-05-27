abstract class EnTranslations {
  static const Map<String, String> keys = {
    // ── Auth ──────────────────────────────────────────────────────────────────
    'login_dispatch': 'DISPATCH',
    'login_title': 'DRIVER\nLOGIN',
    'login_subtitle': 'Enter your credentials to begin\nyour delivery patrol.',
    'login_username_label': 'USERNAME OR EMAIL',
    'login_username_hint': 'Enter username or email',
    'login_password_label': 'PASSWORD',
    'login_btn': 'LOGIN',
    'login_footer': 'DISPATCH - SECURE LOGIN',
    'snack_missing_fields_title': 'Missing fields',
    'snack_missing_fields_body': 'Please enter your username and access key.',
    'snack_login_failed_title': 'Login failed',

    // ── Navigation ────────────────────────────────────────────────────────────
    'nav_orders': 'ORDERS',
    'nav_history': 'HISTORY',
    'nav_profile': 'PROFILE',

    // ── Orders ────────────────────────────────────────────────────────────────
    'orders_title': 'Active Shipments',
    'orders_subtitle': 'Currently assigned to your route',
    'orders_empty_title': 'No active shipments',
    'orders_empty_subtitle': 'You have no shipments assigned to you right now.',
    'orders_view_details': 'View Details',
    'orders_pickup_label': 'PICKUP',
    'orders_dropoff_label': 'DROP-OFF',
    'orders_unit_kg': 'KG',
    'orders_unit_item': 'item',
    'orders_unit_items': 'items',
    'orders_filter_all': 'All',
    'orders_filter_assigned': 'Assigned',
    'orders_filter_in_transit': 'In Transit',
    'orders_retry_more': 'Retry loading more',

    // ── History ───────────────────────────────────────────────────────────────
    'history_title': 'History',
    'history_subtitle': 'Your completed and failed deliveries',
    'history_empty_title': 'No history yet',
    'history_empty_subtitle': 'Completed and failed deliveries will appear here.',
    'history_view_details': 'View Details',
    'history_filter_all': 'All',
    'history_filter_delivered': 'Delivered',
    'history_filter_failed': 'Failed',
    'history_retry_more': 'Retry loading more',

    // ── Shipment detail ───────────────────────────────────────────────────────
    'detail_merchant_pickup': 'MERCHANT (PICKUP)',
    'detail_customer_dropoff': 'CUSTOMER (DROP-OFF)',
    'detail_btn_arrived': 'Arrived at Pickup',
    'detail_btn_delivered': 'Delivered',
    'detail_btn_verify': 'Verify Delivery',
    'detail_btn_confirm_failure': 'Confirm Failure',
    'detail_mark_failed': 'Mark as Failed',
    'detail_section_pkg_info': 'PACKAGE INFO',
    'detail_section_description': 'DESCRIPTION',
    'detail_section_remark': 'REMARK',
    'detail_section_timeline': 'STATUS TIMELINE',
    'detail_section_items': 'ITEMS',
    'detail_remark_hint': 'e.g. Customer was not available at the address...',
    'detail_verify_label': 'SECURITY PROTOCOL',
    'detail_verify_heading': 'Ask the customer\nfor the code',
    'detail_verify_subtitle':
        "Input the 6-character 'Secure Delivery Code' provided by the recipient to finalize the hand-off.",
    'detail_fail_label': 'REPORT FAILURE',
    'detail_fail_heading': 'Mark shipment\nas failed',
    'detail_fail_subtitle':
        'Provide a reason for the failed delivery. This will be recorded and sent to the merchant.',
    'detail_snack_verified_title': 'Delivery Verified',
    'detail_snack_verified_body': 'The delivery has been confirmed successfully.',

    // ── Shipment status labels ─────────────────────────────────────────────────
    'status_pending': 'Pending',
    'status_courier_assigned': 'Courier Assigned',
    'status_driver_assigned': 'Assigned to Driver',
    'status_in_transit': 'In Transit',
    'status_delivered': 'Delivered',
    'status_failed': 'Failed',
    'status_returned': 'Returned',
    'status_cancelled': 'Cancelled',

    // ── Timeline step labels ──────────────────────────────────────────────────
    'timeline_created': 'Created',
    'timeline_courier_assigned': 'Courier Assigned',
    'timeline_driver_assigned': 'Driver Assigned',
    'timeline_picked_up': 'Picked Up',
    'timeline_in_transit': 'In Transit',
    'timeline_delivered': 'Delivered',
    'timeline_failed': 'Failed',
    'timeline_returned': 'Returned',
    'timeline_cancelled': 'Cancelled',

    // ── Profile ───────────────────────────────────────────────────────────────
    'profile_title': 'PROFILE',
    'profile_section_contact': 'CONTACT',
    'profile_section_vehicle': 'VEHICLE',
    'profile_vehicle_type_label': 'VEHICLE TYPE',
    'profile_license_label': 'LICENSE PLATE',
    'profile_emergency_label': 'EMERGENCY CONTACT',
    'profile_section_account': 'ACCOUNT',
    'profile_driver_id_label': 'DRIVER ID',
    'profile_company_id_label': 'COMPANY ID',
    'profile_rating_label': 'RATING',
    'profile_reviews_label': 'REVIEWS',
    'profile_sign_out': 'SIGN OUT',

    // ── Map ───────────────────────────────────────────────────────────────────
    'map_open_google_maps': 'Open in Google Maps',
    'map_marker_you': 'You',
    'map_marker_destination': 'Destination',
    'map_tap_to_expand': 'Tap to expand',
    'map_enable_location': 'Enable location to see your route',
    'map_retry': 'Retry',

    // ── Common ────────────────────────────────────────────────────────────────
    'common_retry': 'RETRY',
    'common_error_unexpected': 'An unexpected error occurred.',
    'common_error_connection': 'Connection error. Please try again.',
  };
}
