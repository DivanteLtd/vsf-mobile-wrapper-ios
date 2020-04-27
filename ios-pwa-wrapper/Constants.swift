//
//  Constants.swift
//  ios-pwa-wrapper
//
//

import UIKit

// Basic App-/WebView-configuration
let appTitle = "Vue Storefront Demo"
let webAppUrl = URL(string: "https://demo.vuestorefront.io/")
let allowedOrigin = "demo.vuestorefront.io"
let menuButtonTitle = NSLocalizedString("menu", comment: "")
let menuButtonJavascript = """
    $('.button-collapse').sideNav('show');
"""
let useUserAgentPostfix = true
let userAgentPostfix = "iOSApp"
let useCustomUserAgent = false
let customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0_1 like Mac OS X) AppleWebKit/604.2.10 (KHTML, like Gecko) Mobile/15A8401"

// QR & Barcode scanner
let codeScannerTitle = "Scan"

// UI Settings
let changeAppTitleToPageTitle = false
let forceLargeTitle = false
let enableBounceWhenScrolling = true

// change Menu button depending on screen width
// IMPORTANT: do not enable this yet, it's still buggy
let changeMenuButtonOnWideScreens = false
let wideScreenMinWidth = CGFloat(993) // your CSS Media Query px-breakpoint
let alternateRightButtonTitle = NSLocalizedString("share", comment: "")
let alternateRightButtonJavascript = """
    $('#share-link').click();
"""

// Colors & Styles
let useLightStatusBarStyle = true
let navigationBarColor = getColorFromHex(hex: 0x000000, alpha: 1.0)
let navigationTitleColor = getColorFromHex(hex: 0xFFFFFF, alpha: 1.0)
let navigationButtonColor = navigationTitleColor
let progressBarColor = getColorFromHex(hex: 0x4CAF50, alpha: 1.0)
let offlineIconColor = UIColor.darkGray
let buttonColor = navigationBarColor
let activityIndicatorColor = navigationBarColor

// Color Helper function
func getColorFromHex(hex: UInt, alpha: CGFloat) -> UIColor {
    return UIColor(
        red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(hex & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}
