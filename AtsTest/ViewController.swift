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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.urlField.delegate = self
        self.webView.navigationDelegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.loadInWebView(textField)
        return true
    }

    // load the given URL in a new SafariViewController
    @IBAction func openInSafariViewController(_ sender: Any) {
        if let url = URL(string: self.urlField.text!) {
            present(SFSafariViewController(url: url), animated: true)
        }
    }
    
    // load the given URL in the WKWebView
    @IBAction func loadInWebView(_ sender: Any) {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        
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

