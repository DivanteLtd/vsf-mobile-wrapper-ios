//
//  ViewController.swift
//  ios-pwa-wrapper
//
//

import UIKit
import WebKit
import Lottie

class ViewController: UIViewController {
    
    // MARK: JS Bridge
    let scanCodeHandlerName = "scanCode"
    let scanCodeResultHandlerName = "mobileOnCodeResult"

    // MARK: Outlets
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineIcon: UIImageView!
    @IBOutlet weak var offlineButton: UIButton!
    @IBOutlet weak var activityAnimationContainerView: UIView!
    @IBOutlet weak var activityAnimationView: AnimationView!
    
    private var firstTimeAppear = true
    private var pageLoaded = false
    private var activityAnimationCompleted = false
    
    // MARK: Globals
    var webView: WKWebView!
    var tempView: WKWebView!
    var progressBar : UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        rightButton.tintColor = .clear
        // Do any additional setup after loading the view, typically from a nib.
        self.title = appTitle
        setupApp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTimeAppear {
            firstTimeAppear = false
            activityAnimationView.play { [weak self] _ in
                self?.activityAnimationCompleted = true
                self?.hideProcessAnimation()
            }
        }
    }
    
    private func hideProcessAnimation() {
        if pageLoaded, activityAnimationCompleted {
            UIView.animate(withDuration: 0.25, delay: 0, options: [], animations: {
                self.activityAnimationContainerView.alpha = 0
            }) { _ in
                self.activityAnimationContainerView.isHidden = true
                self.webView.alpha = 0
                self.webView.isHidden = false
                UIView.animate(withDuration: 0.4, delay: 0.1, options: [], animations: {
                    self.webView.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    // UI Actions
    // handle back press
    @IBAction func onLeftButtonClick(_ sender: Any) {
        if (webView.canGoBack) {
            webView.goBack()
            // fix a glitch, as the above seems to trigger observeValue -> WKWebView.isLoading
            activityAnimationContainerView.isHidden = true
            activityAnimationView.stop()
        } else {
            // exit app
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
    // open menu in page, or fire alternate function on large screens
    @IBAction func onRightButtonClick(_ sender: Any) {
        if (changeMenuButtonOnWideScreens && isWideScreen()) {
            webView.evaluateJavaScript(alternateRightButtonJavascript, completionHandler: nil)
        } else {
            webView.evaluateJavaScript(menuButtonJavascript, completionHandler: nil)
        }
    }
    // reload page from offline screen
    @IBAction func onOfflineButtonClick(_ sender: Any) {
        offlineView.isHidden = true
        webViewContainer.isHidden = false
        loadAppUrl()
    }
    
    // Observers for updating UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(WKWebView.isLoading)) {
            // show activity indicator

            /*
            // this causes troubles when swiping back and forward.
            // having this disabled means that the activity view is only shown on the startup of the app.
            // ...which is fair enough.
            if (webView.isLoading) {
                activityIndicatorView.isHidden = false
                activityIndicator.startAnimating()
            }
            */
        }
        if (keyPath == #keyPath(WKWebView.estimatedProgress)) {
            progressBar.progress = Float(webView.estimatedProgress)
            rightButton.isEnabled = (webView.estimatedProgress == 1)
        }
    }
    
    
    // Initialize WKWebView
    func setupWebView() {
        //deleteCache()
        // set up webview
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height))
        webView.configuration.userContentController.add(self, name: scanCodeHandlerName)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isHidden = true
        webViewContainer.addSubview(webView)
        
        // Scroll Insets
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 56, left: 0, bottom: 8, right: 0)
        
        // settings
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptEnabled = true
        if #available(iOS 10.0, *) {
            webView.configuration.ignoresViewportScaleLimits = false
        }
        // user agent
        if #available(iOS 9.0, *) {
            if (useCustomUserAgent) {
                webView.customUserAgent = customUserAgent
            }
            if (useUserAgentPostfix) {
                if (useCustomUserAgent) {
                    webView.customUserAgent = customUserAgent + " " + userAgentPostfix
                } else {
                    tempView = WKWebView(frame: .zero)
                    tempView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                        if let resultObject = result {
                            self.webView.customUserAgent = (String(describing: resultObject) + " " + userAgentPostfix)
                            self.tempView = nil
                        }
                    })
                }
            }
            webView.configuration.applicationNameForUserAgent = ""
        }
        
        // bounces
        webView.scrollView.bounces = enableBounceWhenScrolling

        // init observers
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
        
      
    }
    
    // Initialize UI elements
    // call after WebView has been initialized
    func setupUI() {
        // leftButton.isEnabled = false
   
        // progress bar
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: 40))
        progressBar.autoresizingMask = [.flexibleWidth]
        progressBar.progress = 0.0
        progressBar.tintColor = progressBarColor
        webView.addSubview(progressBar)

        // offline container
        offlineIcon.tintColor = offlineIconColor
        offlineButton.tintColor = buttonColor
        offlineView.isHidden = true
        
        // setup navigation bar
        if (forceLargeTitle) {
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
            }
        }
        if (useLightStatusBarStyle) {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        }
        
        // handle menu button changes
        /// set default
        rightButton.title = menuButtonTitle
        /// update if necessary
        updateRightButtonTitle(invert: false)
        /// create callback for device rotation
        let deviceRotationCallback : (Notification) -> Void = { _ in
            // this fires BEFORE the UI is updated, so we check for the opposite orientation,
            // if it's not the initial setup
            self.updateRightButtonTitle(invert: true)
        }
        /// listen for device rotation
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main, using: deviceRotationCallback)

        /*
        // @DEBUG: test offline view
        offlineView.isHidden = false
        webViewContainer.isHidden = true
        */
    }

    // load startpage
    func loadAppUrl() {
        let urlRequest = URLRequest(url: webAppUrl!)
        webView.load(urlRequest)
    }
    
    // Initialize App and start loading
    func setupApp() {
        setupWebView()
        setupUI()
        loadAppUrl()
    }
    
    // Cleanup
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // Helper method to determine wide screen width
    func isWideScreen() -> Bool {
        // this considers device orientation too.
        if (UIScreen.main.bounds.width >= wideScreenMinWidth) {
            return true
        } else {
            return false
        }
    }
    
    // UI Helper method to update right button text according to available screen width
    func updateRightButtonTitle(invert: Bool) {
        if (changeMenuButtonOnWideScreens) {
            // first, check if device is wide enough to
            if (UIScreen.main.fixedCoordinateSpace.bounds.height < wideScreenMinWidth) {
                // long side of the screen is not long enough, don't need to update
                return
            }
            // second, check if both portrait and landscape would fit
            if (UIScreen.main.fixedCoordinateSpace.bounds.height >= wideScreenMinWidth
                && UIScreen.main.fixedCoordinateSpace.bounds.width >= wideScreenMinWidth) {
                // both orientations are considered "wide"
                rightButton.title = alternateRightButtonTitle
                return
            }
            
            // if we land here, check the current screen width.
            // we need to flip it around in some cases though, as our callback is triggered before the UI is updated
            let changeToAlternateTitle = invert
                ? !isWideScreen()
                : isWideScreen()
            if (changeToAlternateTitle) {
                rightButton.title = alternateRightButtonTitle
            } else {
                rightButton.title = menuButtonTitle
            }
        }
    }
    
    private func deleteCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
    }
}

// WebView Event Listeners
extension ViewController: WKNavigationDelegate {
    // didFinish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // set title
        if (changeAppTitleToPageTitle) {
            navigationItem.title = webView.title
        }
        // hide progress bar after initial load
        progressBar.isHidden = true
        // hide activity indicator
        pageLoaded = true
        hideProcessAnimation()
    }
    // didFailProvisionalNavigation
    // == we are offline / page not available
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show offline screen
        offlineView.isHidden = false
        webViewContainer.isHidden = true
    }
}

// WebView additional handlers
extension ViewController: WKUIDelegate {
    // handle links opening in new tabs
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    // restrict navigation to target host, open external links in 3rd party apps
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            if let requestHost = requestUrl.host {
                if (requestHost.range(of: allowedOrigin) != nil ) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                    if (UIApplication.shared.canOpenURL(requestUrl)) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(requestUrl)
                        } else {
                            // Fallback on earlier versions
                            UIApplication.shared.openURL(requestUrl)
                        }
                    }
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}

// JavaScript
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "scanCode": scanCode()
        default: return
        }
    }
    func jsMobileOnCodeResult(code: String) {
        webView.evaluateJavaScript("\(scanCodeResultHandlerName)(\"\(code)\");", completionHandler: nil)
    }
}


// Scan QR/Bar Code
extension ViewController {
    func scanCode() {
        let vc = ScanCodeVC(completion: scanCompletion)
        navigationController?.present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func scanCompletion(_ code: String?) {
        print(code ?? "No code")
        if let code = code {
            jsMobileOnCodeResult(code: code)
       }
    }
}
