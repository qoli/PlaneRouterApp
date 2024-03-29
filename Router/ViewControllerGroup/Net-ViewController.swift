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
import Localize_Swift

class Net_ViewController: UIViewController {

    @IBOutlet weak var pageTitleLabel: UILabel!

    @IBOutlet weak var WANIPTitle: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.Chart_Setup()
        self.getWANIP()

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
        print("NotificationCenter: netViewonShowNotification Bool: \(notification.object ?? 0)")
        delay {
            self.dataAppear(Appear: notification.object! as! Bool)
        }
    }

    // MARK: - view

    override func viewWillDisappear(_ animated: Bool) {
        self.isViewAppear = false
         NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.isViewAppear = true
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    var isViewAppear = false
    var lastViewAppearBool = false

    func dataAppear(Appear: Bool) {
        if lastViewAppearBool != Appear {
            if Appear {
                DownloadNumbers = []
                UploadNumbers = []
                netSpeedTime = 0
                self.isViewAppear = true
                self.NetSpeed_Update()
            } else {
                print("Net_ViewController: Pause")
                self.isViewAppear = false
            }
        }

        lastViewAppearBool = Appear
    }

    // MARK: - Tap Chart

    @IBAction func tapChart(_ sender: UITapGestureRecognizer) {
        print("tapChart \(isViewAppear) netSpeedTime \(netSpeedTime)")
    }

    // MARK: - Restart WAN

    @IBOutlet weak var RestartWANButton: UIButton!

    @IBAction func RestartWAN(_ sender: UIButton) {
        self.WANIPLabel.text = "Restarting..."
        self.RestartWANButton.isEnabled = false

        delay {
            _ = SSHRun(command: "service restart_dnsmasq")
            _ = SSHRun(command: "service restart_wan")

            delay(3) {
                self.getWANIP()
            }
        }

    }



    // MARK: - Loop Net Speed

    func Chart_Setup() {

        chtChart.noDataText = "Waiting Data".localized()

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
        chtChart.rightAxis.gridColor = UIColor(named: "Gray92") ?? UIColor.gray92
        chtChart.rightAxis.gridLineDashLengths = [5, 5]
        chtChart.rightAxis.labelTextColor = UIColor(named: "gray80") ?? UIColor.gray80
        chtChart.rightAxis.labelFont = UIFont.chartRightFont

        chtChart.autoScaleMinMaxEnabled = true
        chtChart.xAxis.spaceMax = 0.1

        chtChart.minOffset = 0
    }

    func Chart_Update() {
        // print("updateGraph() \(DownloadNumbers.count)")
        var lineDownloadChartEntry = [ChartDataEntry]()
        var lineUploadChartEntry = [ChartDataEntry]()
        let data = LineChartData()

        // here is the for loop
        for i in 0..<DownloadNumbers.count {
            let valueDownload = ChartDataEntry(x: Double(i), y: DownloadNumbers[i])
            let valueUpload = ChartDataEntry(x: Double(i), y: UploadNumbers[i])
            lineDownloadChartEntry.append(valueDownload)
            lineUploadChartEntry.append(valueUpload)
        }

        let lineDownload = LineChartDataSet(entries: lineDownloadChartEntry, label: "Download Speed") //Here we convert lineChartEntry to a LineChartDataSet
        lineDownload.axisDependency = .left
        lineDownload.colors = [UIColor(named: "appleGreen")] as! [NSUIColor]
        lineDownload.mode = .cubicBezier
        lineDownload.lineWidth = 2.0
        lineDownload.circleColors = [UIColor(named: "appleGreen")] as! [NSUIColor]
        lineDownload.drawCirclesEnabled = true
        lineDownload.drawFilledEnabled = true
        lineDownload.fillColor = UIColor(named: "appleGreen50") ?? UIColor.appleGreen50
        lineDownload.fillAlpha = 0.5
        lineDownload.drawValuesEnabled = false
        lineDownload.drawCircleHoleEnabled = true

        let lineUpload = LineChartDataSet(entries: lineUploadChartEntry, label: "Upload Speed") //Here we convert lineChartEntry to a LineChartDataSet
        lineUpload.axisDependency = .left
        lineUpload.colors = [UIColor(named: "mainBlue")] as! [NSUIColor]
        lineUpload.mode = .cubicBezier
        lineUpload.lineWidth = 2.0
        lineUpload.circleColors = [UIColor(named: "mainBlue")] as! [NSUIColor]
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

    var netSpeedTime: Int = 0

    func NetSpeed_Update() {

        netSpeedTime = netSpeedTime + 1

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

                                if self.netSpeedTime % 2 == 0 {
                                    self.updateTextLabel.text = "⊷"
                                } else {
                                    self.updateTextLabel.text = "⊶"
                                }

                                self.DownloadNumbers.append(downSpeed)
                                self.UploadNumbers.append(upSpeed)
                                self.Chart_Update()
                            }

                            delay(1) {
                                if self.isViewAppear {
                                    self.NetSpeed_Update()
                                } else {
                                    self.updateTextLabel.text = "Pause".localized()
                                }
                            }
                        } else {
                            // rxtx 無效數據
                            self.isViewAppear = false
                            self.chrysan.show(.plain, message: "Data invalid", hideDelay: 1)
                        }
                    }

                    //404
                    if value.hasPrefix("<HTML><HEAD><TITLE>404 Not Found</TITLE></HEAD>") {
                        self.chrysan.show(.plain, message: "Update 404", hideDelay: 1)
                        self.isViewAppear = false
                    }

                    // not login
                    if value.hasPrefix("<HTML><HEAD><script>top.location.href='/Main_Login.asp'") {
                        self.updateTextLabel.text = "Waiting for login".localized()
                        //try login
                        routerModel.GetRouterCookie(completionHandler: {
                            delay(1) {
                                if self.isViewAppear {
                                    self.NetSpeed_Update()
                                }
                            }
                        })

                    }



                case .failure(let error):
                    print("[NetSpeed_Update] failure")
                    App.sendMessage(type: "Error", title: "NetSpeed_Update failure", text: error.localizedDescription)
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

    func getWANIP() {

        self.WANIPLabel.text = "Connecting..."

        fetchRequest(api: "http://ip.360.cn/IPShare/info", isRefresh: true, completionHandler: { value, error in
            if value != nil {
                let rJSON = JSON(value as Any)
                let remoteIP = rJSON["ip"].stringValue
                self.WANIPLabel.text = remoteIP
                self.RestartWANButton.isEnabled = true

                delay {
                    let sshIP = SSHRun(command: "nvram get wan0_ipaddr", isRefresh: true)
                    if sshIP.removingWhitespacesAndNewlines == remoteIP.removingWhitespacesAndNewlines {
                        self.WANIPTitle.text = "WAN IP · Public IP".localized()
                    } else {
                        self.WANIPTitle.text = "WAN IP · Private IP: \(sshIP)".localized()
                    }
                }
            } else {
                fetchRequest(api: "https://ifconfig.co/json", isRefresh: true, completionHandler: { value, error in
                    if value != nil {
                        self.RestartWANButton.isEnabled = true

                        let rJSON = JSON(value as Any)
                        self.WANIPLabel.text = rJSON["ip"].stringValue
                        self.WANIPTitle.text = "WAN IP (by ifconfig.co)".localized()
                    } else {
                        self.WANIPLabel.text = error?.localizedDescription
                        delay(2) {
                            self.getWANIP()
                        }
                    }
                })
            }
        })

    }




}
