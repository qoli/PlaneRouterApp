//
//  Terminal-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/9.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import NMSSH
import SwiftyJSON
import IQKeyboardManagerSwift
import Chrysan

class Terminal_ViewController: UIViewController, NMSSHSessionDelegate, NMSSHChannelDelegate, UITextViewDelegate {

    // MARK: - var
    
    var session: NMSSHSession!
    var category = ""
    var lastCommand = ""
    var lastCopy = ""
    var passCommand = ""
    var keyboardInteractive = ""
    var password = ""
    var isKeyboard: Bool = false

    var Service: serviceListClass.serviceStruct?
    
    @IBOutlet weak var textView: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
        textView.isEditable = false
        textView.isSelectable = false
        textView.text = ""

        IQKeyboardManager.shared.enable = false

        //NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Logger
        NMSSHLogger().logLevel = NMSSHLogLevel.error
        NMSSHLogger().isEnabled = false

        //
        SSHConnect()

        // run pass command
        SSHCommand(remoteCommand: passCommand)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
    }


    @objc func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.textView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.textView.contentInset = contentInset
        self.isKeyboard = true
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        self.textView.contentInset = contentInset
        self.isKeyboard = false
    }

    // Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func closeAction(_ sender: UIButton) {
        self.SSHDisconnect()
    }

    @IBAction func closeKeyboard(_ sender: UIButton) {
        view.endEditing(true)
    }

    func SSHCommand(remoteCommand: String = "") {
        if self.passCommand != "" {
            //self.message(message: remoteCommand)
            self.lastCommand = remoteCommand
            textView.isEditable = true
        }
        print("[SSHCommand] remoteCommand: \(self.lastCommand)")
        let command = self.lastCommand
        self.lastCopy = command
        DispatchQueue.main.async(execute: {
            if self.session != nil {
                self.session.channel.write(command, error: nil, timeout: 10)
            }
        })
        self.passCommand = ""
        self.lastCommand = ""
    }

    // MARK: - SSH Connect
    
    func SSHConnect() -> Void {
        print("SSHConnect()")
        
        let connectID = self.Service?.connectID
        
        if connectID == "" {
            self.exitMessage(message: "No Config")
            return
        } else {
            message(message: "Connecting...")
        }
        
        DispatchQueue.main.async(execute: {
            
            let uConfig = ConnectConfig.getByID(identifier: self.Service?.connectID ?? "")
            let host = uConfig.address
            let username = uConfig.loginName
            let password = uConfig.loginPassword

            if host != "" {
                self.session = NMSSHSession(host: host, andUsername: username)

                self.session.delegate = self
                self.session.connect()
                if self.session.isConnected {
                    self.session.authenticate(byPassword: password)

                    if !self.session.isAuthorized {
                        self.exitMessage(message: "SSH Authentication Failed")
                    } else {
                        do {
                            self.session.channel.delegate = self
                            self.session.channel.requestPty = true
                            self.session.channel.ptyTerminalType = NMSSHChannelPtyTerminal.vanilla
                            try self.session.channel.startShell()
                            self.textView.isEditable = true
                        } catch {
                            self.exitMessage(message: error.localizedDescription)
                        }
                    }

                } else {
                    // isConnected Failed
                    self.exitMessage(message: "Connect Failed")
                }
            } else {
                // Host == ""
                self.exitMessage(message: "Missing Host")
            }


        })
    }

    func SSHDisconnect() {
        DispatchQueue.main.async(execute: {
            self.session.disconnect()
        })
    }

    // channel
    func channel(_ channel: NMSSHChannel, didReadData message: String) {
        DispatchQueue.main.async(execute: {
            self.appendToTextView(text: message)
        })
    }

    func channel(_ channel: NMSSHChannel, didReadError error: String) {
        DispatchQueue.main.async(execute: {
            self.appendToTextView(text: "[ERROR] \(error)")
            self.message(message: error)
        })
    }

    func channelShellDidClose(_ channel: NMSSHChannel) {
        DispatchQueue.main.async(execute: {
            self.appendToTextView(text: "\nShell closed\n")
            self.textView.isEditable = false
            delay {
                self.exitMessage(message: "Shell Close")
            }
        })
    }

    func session(_ session: NMSSHSession, keyboardInteractiveRequest request: String) -> String {
        DispatchQueue.main.async(execute: {
            self.appendToTextView(text: request)
            self.textView.isEditable = true
        })

        return self.password
    }


    func session(_ session: NMSSHSession, didDisconnectWithError error: Error) {
        DispatchQueue.main.async(execute: {
            self.appendToTextView(text: "\nDisconnected with error: \(error)")
            self.textView.isEditable = false
        })
    }

    func appendToTextView(text: String) {

        // remove last input text
        if isKeyboard {
            if self.passCommand == "" {
                var removeInt = 0
                if lastCopy.count != 0 {
                    removeInt = lastCopy.count - 1
                }
                self.textView.text = self.textView.text + text.dropFirst(removeInt)
            }
        } else {
            self.textView.text = self.textView.text + text

        }

        // replace ansi color code (like [1;34m)
        let pattern = "\\x1b\\[[0-9;]*m"
        self.textView.text = self.textView.text.replaceAll(of: pattern, with: "")

        self.textView.scrollRangeToVisible(NSRange(location: self.textView.text.count - 1, length: 1))

    }

    // textView
    func textViewDidChange(_ textView: UITextView) {
        textView.scrollRangeToVisible(NSRange(location: textView.text.count - 1, length: 1))
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if Int(textView.selectedRange.location) < textView.text.count - lastCommand.count - 1 {
            textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        }
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count == 0 {
            if lastCommand.count > 0 {
                if let subRange = Range<String.Index>(NSRange(location: lastCommand.count - 1, length: 1), in: lastCommand) { lastCommand.replaceSubrange(subRange, with: "") }
                return true
            } else {
                return false
            }
        }

        lastCommand += text

        if(text == "\n") {
            SSHCommand()
            return false
        }
        return true
    }

    // MARK: - NotificationBanner


    func exitMessage(message: String) {
        chrysan.show(.plain, message: message, hideDelay: 2)
        delay {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func message(message: String) {
        chrysan.show(.plain, message: message, hideDelay: 1)
    }

}
