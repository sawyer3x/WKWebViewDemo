//
//  ViewController.swift
//  WKWebViewDemo
//
//  Created by hsx on 2018/9/11.
//  Copyright © 2018年 sawyer3x. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - 懒加载
    private lazy var scrollerView: UIScrollView = {
        let scrollerView = UIScrollView()
        scrollerView.frame = view.frame
        
        return scrollerView
    }()
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        //初始化偏好设置属性：preferences
        webConfiguration.preferences = WKPreferences()
        //是否支持JavaScript
        webConfiguration.preferences.javaScriptEnabled = true
        //不通过用户交互，是否可以打开窗口
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        let webFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0)
        let webView = WKWebView(frame: webFrame, configuration: webConfiguration)
        webView.backgroundColor = UIColor.blue
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        return webView
    }()
  
    //按钮
    private lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "click"), for: .normal)
        btn.setImage(UIImage.init(named: "unclick"), for: .highlighted)
        
        return btn
    }()
    
    //进度条
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(frame: CGRect(x: 0, y: 0 , width: UIScreen.main.bounds.width, height: 2))
        progressView.progressTintColor = .green
        progressView.trackTintColor = .white
        
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setWebViews()
    }
    
    //MARK: - Setup View

    private func setWebViews() {
        view.addSubview(scrollerView)
        view.addSubview(progressView)

        scrollerView.addSubview(webView)
        scrollerView.addSubview(btn)
        
        progressView.isHidden = false
        
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = 0.05
        }
        
        btn.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(60.0)
            make.top.equalTo(webView.snp.bottom)
        }
        
        scrollerView.sizeToFit()
        
        let myUrl = URL(string: "https://baidu.com")
        let myRequest = URLRequest(url: myUrl!)
        self.webView.load(myRequest)
    }
    
}

extension ViewController: WKNavigationDelegate{
    // 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        self.navigationItem.title = "加载中..."
        /// 获取网页的progress
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        UIView.animate(withDuration: 1.0) {
            self.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        /// 获取网页title
        self.title = self.webView.title
        
        //TODO: - 点赞view 待改
//        self.view.addSubview(fabulousView)
        
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 1.0
            self.progressView.isHidden = true
        }
        
        var webheight = 0.0
        
        // 获取内容实际高度
        self.webView.evaluateJavaScript("document.body.scrollHeight") { [unowned self] (result, error) in
            
            if let tempHeight: Double = result as? Double {
                webheight = tempHeight
                print("webheight: \(webheight)")
            }
            
            DispatchQueue.main.async { [unowned self] in
                var tempFrame: CGRect = self.webView.frame
                tempFrame.size.height = CGFloat(webheight)
                self.webView.frame = tempFrame
                self.scrollerView.contentSize = CGSize(width: self.scrollerView.frame.size.width, height: self.webView.frame.size.height + self.btn.frame.size.height)
            }
        }
    }
    
    // 页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error){
        UIView.animate(withDuration: 0.5) {
            self.progressView.progress = 0.05
            self.progressView.isHidden = true
        }
        /// 弹出提示框点击确定返回
        let alertView = UIAlertController.init(title: "提示", message: "加载失败", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }

    
}
