//
//  WebViewController.swift
//  FavoriteLinks
//
//  Created by 田中裕貴 on 2020/08/16.
//  Copyright © 2020 田中裕貴. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {

  @IBOutlet weak var webView: WKWebView!
  public var url: String!

  override func loadView() {
    webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    webView.uiDelegate = self
    view = webView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    webView.load(URLRequest(url: NSURL(string: url)! as URL))
  }

  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
