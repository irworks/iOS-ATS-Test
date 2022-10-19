//
//  ViewController.swift
//  AtsTest
//
//  Created by Ilja Rozhko on 06.02.22.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.urlField.delegate = self
        self.webView.navigationDelegate = self
        self.webView.configuration.processPool = WKProcessPool()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loadInWebView(textField)
        return true
    }
    
    @IBAction func loadAsUrlSession(_ sender: Any) {
        guard let url = URL(string: self.urlField.text!) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.showAlert(title: "URL Session", message: error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                let resultString = String(data: data, encoding: .utf8)
                self.textView.text = resultString
            }
        }.resume()
    }
    
    // load the given URL in a new SafariViewController
    @IBAction func openInSafariViewController(_ sender: Any) {
        if let url = URL(string: self.urlField.text!) {
            present(SFSafariViewController(url: url), animated: true)
        }
    }
    
    // load the given URL in the WKWebView
    @IBAction func loadInWebView(_ sender: Any) {        
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Deleted cookie: \(record)")
            }
        }
        
        if let url = URL(string: self.urlField.text!) {
            let request = URLRequest(url: url)
            print("Loading \(url.absoluteString)")
            print("Loading request: \(request)")
            self.webView.load(request)
        }
    }
    
    // log errors while starting navigation, including ATS
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation")
        print(error)
        self.showAlert(title: "WKWebView didFailProvisionalNavigation", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
        print(error)
    }
    
    // log url changes (redirects)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print("navigationAction: \(navigationAction)")
        if let urlStr = navigationAction.request.url?.absoluteString {
            //urlStr is what you want, I guess.
            print("Currently at \(urlStr)")
            self.navigationItem.prompt = urlStr
        }
        decisionHandler(.allow)
    }

    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
}

