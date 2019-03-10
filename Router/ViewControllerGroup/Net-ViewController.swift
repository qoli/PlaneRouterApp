//
//  Base-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/18.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import Charts
import SafariServices

class Net_ViewController: UIViewController {

    @IBOutlet weak var pageTitleLabel: UILabel!

    @IBOutlet weak var WANIPLabel: UILabel!
    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var downloadUnitLabel: UILabel!
    @IBOutlet weak var uploadLable: UILabel!
    @IBOutlet weak var uploadUnitLabel: UILabel!

    @IBOutlet weak var updateTextLabel: UILabel!

    var upOld = 0.0
    var upNow = 0.0
    var downOld = 0.0
    var downNow = 0.0

    var DownloadNumbers: [Double] = []
    var UploadNumbers: [Double] = []

    var isViewAppear = false
    var lastViewAppearBool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        chartSetup()
        self.sendChineseipRequest()

        //添加通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(netViewonShowNotification(_:)),
            name: NSNotification.Name(rawValue: "NetViewonShow"),
            object: nil
        )
        
    }
    // MARK: - 通知
    
    @objc func netViewonShowNotification(_ notification: Notification) {
        dataAppear(Appear: notification.object! as! Bool)
    }

    // MARK: - view
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isViewAppear = false
    }

    override func viewWillAppear(_ animated: Bool) {
        self.isViewAppear = true
    }

    func dataAppear(Appear: Bool) {
        if lastViewAppearBool != Appear {
            if Appear {
                DownloadNumbers = []
                UploadNumbers = []
                self.isViewAppear = true
                self.runLoop()
            } else {
                print("Net_ViewController: Pause")
                self.isViewAppear = false
            }
        }

        lastViewAppearBool = Appear
    }

    func runLoop() {
        delay(1) {
            if self.isViewAppear {
                self.UpdateNetSpeed()
                self.runLoop()
            } else {
                self.updateTextLabel.text = "Pause"
            }
        }
    }

    func chartSetup() {

        chtChart.noDataText = "Waiting Data"

        // Interaction
        chtChart.doubleTapToZoomEnabled = false
        chtChart.scaleXEnabled = false
        chtChart.scaleYEnabled = false
        chtChart.dragEnabled = false
        chtChart.pinchZoomEnabled = false


        //legend
        chtChart.legend.enabled = false

        // Format x axis
        chtChart.xAxis.drawGridLinesEnabled = false
        chtChart.xAxis.drawAxisLineEnabled = false
        chtChart.xAxis.drawLabelsEnabled = false
        chtChart.xAxis.drawGridLinesEnabled = false
        chtChart.xAxis.labelFont = UIFont.boldSystemFont(ofSize: 9)

        // Y axis
        chtChart.leftAxis.enabled = false
        chtChart.leftAxis.drawAxisLineEnabled = false
        chtChart.leftAxis.gridLineDashLengths = [5, 5]

        chtChart.rightAxis.enabled = true
        chtChart.rightAxis.drawAxisLineEnabled = false
        chtChart.rightAxis.drawLabelsEnabled = false
        chtChart.rightAxis.gridColor = UIColor.gray92
        chtChart.rightAxis.gridLineDashLengths = [5, 5]
        chtChart.rightAxis.labelTextColor = UIColor.gray80
        chtChart.rightAxis.labelFont = UIFont.chartRightFont

        chtChart.autoScaleMinMaxEnabled = true
        chtChart.xAxis.spaceMax = 0.1

        chtChart.minOffset = 0
    }

    func updateGraph() {
//        print("updateGraph() \(DownloadNumbers.count)")
        var lineDownloadChartEntry = [ChartDataEntry]()
        var lineUploadChartEntry = [ChartDataEntry]()
        let data = LineChartData()

        //here is the for loop
        for i in 0..<DownloadNumbers.count {
            let valueDownload = ChartDataEntry(x: Double(i), y: DownloadNumbers[i])
            let valueUpload = ChartDataEntry(x: Double(i), y: UploadNumbers[i])
            lineDownloadChartEntry.append(valueDownload)
            lineUploadChartEntry.append(valueUpload)
        }

        let lineDownload = LineChartDataSet(values: lineDownloadChartEntry, label: "Download Speed") //Here we convert lineChartEntry to a LineChartDataSet
        lineDownload.axisDependency = .left
        lineDownload.colors = [UIColor.appleGreen]
        lineDownload.mode = .cubicBezier
        lineDownload.lineWidth = 2.0
        lineDownload.circleColors = [UIColor.appleGreen]
        lineDownload.drawCirclesEnabled = true
        lineDownload.drawFilledEnabled = true
        lineDownload.fillColor = UIColor.greenApple50
        lineDownload.fillAlpha = 0.5
        lineDownload.drawValuesEnabled = false
        lineDownload.drawCircleHoleEnabled = true

        let lineUpload = LineChartDataSet(values: lineUploadChartEntry, label: "Upload Speed") //Here we convert lineChartEntry to a LineChartDataSet
        lineUpload.axisDependency = .left
        lineUpload.colors = [UIColor.mainBlue]
        lineUpload.mode = .cubicBezier
        lineUpload.lineWidth = 2.0
        lineUpload.circleColors = [UIColor.mainBlue]
        lineUpload.drawFilledEnabled = false
        lineUpload.drawValuesEnabled = false
        lineUpload.drawCirclesEnabled = false
        lineUpload.lineDashLengths = [5, 5]

        data.addDataSet(lineDownload)
        data.addDataSet(lineUpload) //Adds the line to the dataSet
        chtChart.data = data //finally - it adds the chart data to the chart and causes an update

        let moveToX = Double(DownloadNumbers.count - 1)
        chtChart.setVisibleXRangeMaximum(3)
        chtChart.setVisibleXRangeMinimum(3)
        chtChart.moveViewToAnimated(xValue: moveToX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.55)

    }

    func UpdateNetSpeed() {
        /**
         GetSpeed
         post http://router.asus.com/update.cgi
         */
        
        // Add Headers
        let headers = [
            "Referer": "\(buildUserURL())/update.cgi",
            "Content-Type": "text/plain; charset=utf-8",
        ]

        // Custom Body Encoding
        struct RawDataEncoding: ParameterEncoding {
            public static var `default`: RawDataEncoding { return RawDataEncoding() }
            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var request = try urlRequest.asURLRequest()
                request.httpBody = "output=netdev&_http_id=TIDe855a6487043d70a".data(using: String.Encoding.utf8, allowLossyConversion: false)
                return request
            }
        }

        // Fetch Request
        Alamofire.request("\(buildUserURL())/update.cgi", method: .post, encoding: RawDataEncoding.default, headers: headers)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    
                    // 網速
                    if value.hasPrefix("\nnetdev = {") {
                        let rxtx = value.groups(for: "'INTERNET':\\{rx:(.*?),tx:(.*?)\\}")
                        if rxtx != [] {
                            self.upNow = hexTodec(number: rxtx[0][2])
                            self.downNow = hexTodec(number: rxtx[0][1])
                            let upSpeed = (self.upNow - self.upOld) / 1024
                            let downSpeed = (self.downNow - self.downOld) / 1024
                            
                            if self.upOld == 0 {
                                self.upOld = self.upNow
                                self.downOld = self.downNow
                            } else {
                                self.upOld = self.upNow
                                self.downOld = self.downNow
                                
                                self.downloadLabel.text = String(format: "%.1f", self.unit(num: downSpeed).0)
                                self.uploadLable.text = String(format: "%.1f", self.unit(num: upSpeed).0)
                                self.downloadUnitLabel.text = self.unit(num: downSpeed).1
                                self.uploadUnitLabel.text = self.unit(num: upSpeed).1
                                self.updateTextLabel.text = "Updating"
                                
                                self.DownloadNumbers.append(downSpeed)
                                self.UploadNumbers.append(upSpeed)
                                self.updateGraph()
                            }
                        } else {
                            // rxtx 無有效數據
                            self.isViewAppear = false
                            messageNotification(message: "Data invalid", title: "Net Speed")
                        }
                    }
                    
                    //404
                    if value.hasPrefix("<HTML><HEAD><TITLE>404 Not Found</TITLE></HEAD>") {
                        messageNotification(message: "Update 404", title: "Net Speed")
                        self.isViewAppear = false
                    }
                    
                    // not login
                    if value.hasPrefix("<HTML><HEAD><script>top.location.href='/Main_Login.asp'") {
                        print("net speed: need login")
                        self.updateTextLabel.text = "Waiting for login"
                        //try login
                        GetRouterCookie()
                    }



                case .failure(let error):
                    self.updateTextLabel.text = error.localizedDescription
                }
        }
    }

    func unit(num: Double) -> (Double, String) {

        if num < 1024 {
            let number: Double = num
            let unit: String = "kb/s"
            return (number, unit)
        } else {
            if (num / 1024) > 1024 {
                let number: Double = num / 1024 / 1024
                let unit: String = "gb/s"
                return (number, unit)
            } else {
                let number: Double = num / 1024
                let unit: String = "mb/s"
                return (number, unit)
            }
        }


    }

    func sendChineseipRequest() {

        // Fetch Request
        Alamofire.request("http://ip.360.cn/IPShare/info", method: .get, encoding: URLEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    delay(0.1) {
                        let rJSON = JSON(value)
                        self.WANIPLabel.text = rJSON["ip"].stringValue
                    }
                case .failure(let error):
                    self.WANIPLabel.text = error.localizedDescription
                }
        }
    }




}
