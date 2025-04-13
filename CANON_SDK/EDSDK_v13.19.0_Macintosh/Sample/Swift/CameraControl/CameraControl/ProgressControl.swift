//
//  ProgressView.swift
//  CameraControl
//
//  Created by ICP221 on 2016/11/02.
//
//

import Foundation
import Cocoa

class ProgressControl : NSWindowController, NSWindowDelegate{
    
    var _controller : CameraController!
    @IBOutlet weak var _progressBar : NSProgressIndicator?
    @IBOutlet weak var _canncelButton : NSButton!
    @IBOutlet weak var _progressLabel: NSTextField!
    var _storageFileNum :Int = 0
    var _currentFileIndex :Int = 0
    
    init(controller: CameraController){
        super.init(window: nil)
        
        NSBundle.mainBundle().loadNibNamed("DownloadProgress", owner: self, topLevelObjects: nil)
        self._controller = controller
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.update(_:)), name: "MY_VIEW_UPDATE", object: nil)
        
        _canncelButton.action = #selector(ProgressControl.cancelTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func awakeFromNib() {
                
    }

    
    func windowShouldClose(sender: AnyObject) -> Bool {
        return true
    }
    
    func windowWillClose(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSApp.stopModal()
        NSApp.abortModal()
    }
    
    func cancelTapped(){
        _controller.getCameraModel().setFileTransferring(false)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSApp.modalWindow?.close()
        NSApp.stopModal()
    }
    
    func startDownload(){
        _controller.getCameraModel().setFileTransferring(true)
        _controller.postCommand(DownloadAllFilesCommand(model: _controller.getCameraModel()))
    }

    func update(notification: NSNotification?) {
        
        let event = notification?.object as! CameraEvent
        
        let arg = event.getArg()
        
        switch(event.getEvent()){
        case .FILE_COUNT_COMPLETED:
            _storageFileNum  = NSInteger.init(arg as! NSInteger)
            _progressLabel.stringValue = String(_currentFileIndex) + " / " + String(_storageFileNum)
            break
        case .FILE_DOWNLOAD_COMPLETED:
            _currentFileIndex += 1
            _progressLabel.stringValue = String(_currentFileIndex) + " / " + String(_storageFileNum)
            let incremntValue :Double = 100.0 / Double(_storageFileNum)
            if ((_progressBar?.doubleValue)! + incremntValue < 100.0) {
                _progressBar?.incrementBy(incremntValue)
            }else{
                _progressBar?.doubleValue = 100.0
            }
            if(_currentFileIndex >= _storageFileNum){
                cancelTapped()
            }
            break;
        case .ERROR:
            break;
        default:
            break;
        }
    }
}