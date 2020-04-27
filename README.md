

![Vue Storefront iOS Mobile Wrapper](https://user-images.githubusercontent.com/42430550/80321981-e4ac0b00-8821-11ea-9115-dbd3183e8e1c.jpg)

# Vue Storefront iOS PWA wrapper

An iOS Wrapper application to create a native iOS App from Vue Storefront PWA.

## Prequisites
For bringing offline-capabilities to your Web App on Safari and iOS' embedded WebKit browser, you have to use [AppCache](https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache). [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) is not yet supported in WebKit, so you might want to use something like [Appcache Webpack Plugin](https://github.com/lettertwo/appcache-webpack-plugin) to make your PWA offline-accessible on iOS in a somewhat easy way.

## What it does
- Provides a native iOS navigation header.
- Sets up a WKWebView instance just the way PWAs/SPAs like it.
- Provided your Web App is Offline-capable, it only needs an Internet connection on the first startup. If this fails, it shows a native refresh widget.
- Opens all external URLs in the device's Browser / 3rd party apps instead.
- Automatically fetches updates of your Web App.

## How to build your own iOS wrapper
- Clone/fork repository and open in Xcode
- Head over to `Constants.swift` and
    - add your app's name and the main URL to fetch
    - set the host you want to restrict your app to
    - add your custom Javascript string to open your Web App's menu.
        - this is injected into the site when the "Menu" button is pressed. This wrapper assumes you're hiding your Web App's header in favor of the native App navigation and show/hide your menu via Javascript.
    - customize the colors
    - tweak the other options as you prefer
- Put your own App icons in place in `Assets.xcassets`
    - Remember, 1pt equals 1px on 1x-size. E.g., if you have to provide a 20pt icon of 3x-size, it has to be 60x60px.
    - iOS doesn't like transparency, use background colors on your icons.
    - I like using [App Icon Maker](http://appiconmaker.co), but any other similar service will do it as well.
    - Don't forget the `launcher` icon!
- In the Project Overview
    - change _Bundle Identifier_ and _Display Name_
    - add your Certificates and tweak the rest as you wish
    - a _Deployment Target_ of iOS 10.0 is set by default, as the [offline cache isn't preserved after closing the app in earlier versions](https://stackoverflow.com/questions/29892898/enable-application-cache-in-wkwebview/44333359#44333359). Therefore, the wrapper is only tested on iOS 10+ and there's no official support for earlier versions for now.
- Build App in Xcode


## License
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)

## Credits
- [codecoda](https://codecoda.com/en)
- [leasingrechnen](https://www.leasingrechnen.at/)

