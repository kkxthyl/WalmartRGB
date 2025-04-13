/******************************************************************************
 *                                                                             *
 *   PROJECT : Eos Digital camera Software Development Kit EDSDK               *
 *                                                                             *
 *   Description: This is the Sample code to show the usage of EDSDK.          *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *                                                                             *
 *   Written and developed by Canon Inc.                                       *
 *   Copyright Canon Inc. 2018 All Rights Reserved                             *
 *                                                                             *
 *******************************************************************************/

import Cocoa

class Progress : NSWindowController, NSWindowDelegate{
    
    var _controller : CameraController!
    @IBOutlet weak var _progressBar : NSProgressIndicator?
    @IBOutlet weak var _canncelButton : NSButton!
    @IBOutlet weak var _progressLabel: NSTextField!
    @IBOutlet weak var _statusLabel: NSTextField!
    var _storageFileNum :Int = 0
    var _currentFileIndex :Int = 0
    
    init(controller: CameraController){
        super.init(window: nil)
        
        Bundle.main.loadNibNamed("Progress", owner: self, topLevelObjects: nil)
        self._controller = controller
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "MY_VIEW_UPDATE"), object: nil)
        
        _canncelButton.action = #selector(Progress.cancelTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        
    }
    
    
    private func windowShouldClose(_ sender: Any) -> Bool {
        return true
    }
  
    func windowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        NSApp.stopModal()
        NSApp.abortModal()
    }
    
    func terminateProgress(){
        
        _controller.getCameraModel().setFileTransferring(false)
        _controller.getCameraModel().setFileDeleting(false)
        NotificationCenter.default.removeObserver(self)
        NSApp.modalWindow?.close()
        NSApp.stopModal()
        
    }
    
    @objc func cancelTapped(){
        
        var event = CameraEvent(type: .file_DELETE_CANCEL, arg: 0 as AnyObject)
        let viewNotification = ViewNotification()
        viewNotification.viewNotificationObservers(&event)
        
    }
    
    func startDownload(){
        _statusLabel.stringValue = "File Downloading ..."
        _controller.getCameraModel().setFileTransferring(true)
        _controller.actionPerformed(ActionEvent(command: .download_ALLFILES, object: 0 as AnyObject))
    }
    
    func startDelete(){
        _statusLabel.stringValue = "File Deleting ..."
        _controller.getCameraModel().setFileDeleting(true)
        _controller.actionPerformed(ActionEvent(command: .delete_ALLFILES, object: 0 as AnyObject))
    }
    
    func updateProgressBar(){
        _currentFileIndex += 1
        _progressLabel.stringValue = String(_currentFileIndex) + " / " + String(_storageFileNum)
        let incremntValue :Double = 100.0 / Double(_storageFileNum)
        if ((_progressBar?.doubleValue)! + incremntValue < 100.0) {
            _progressBar?.increment(by: incremntValue)
        }else{
            _progressBar?.doubleValue = 100.0
        }
    }
    
    @objc func update(_ notification: Notification?) {
    
        let event = notification?.object as! CameraEvent
        
        let arg = event.getArg()
        
        switch(event.getEvent()){
        case .file_COUNT_COMPLETED:
            _storageFileNum  = NSInteger.init(arg as! NSInteger)
            _currentFileIndex = 0
            _progressLabel.stringValue = String(_currentFileIndex) + " / " + String(_storageFileNum)
            break
            
        case .file_DOWNLOAD_COMPLETED:
            updateProgressBar()
            break
            
        case .file_DELETE_COMPLETED:
            updateProgressBar()
            break
            
        case .file_DELETE_CANCEL:
            _statusLabel.stringValue = "Canceling ..."
            _controller.getCameraModel().setFileTransferring(false)
            _controller.getCameraModel().setFileDeleting(false)
            break
            
        case .close_PROGRESS:
            self.terminateProgress()
            break
            
        case .error:
            break
            
        default:
            break
        }
    }
}
