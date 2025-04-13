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

class MainWindow: NSWindowController, NSApplicationDelegate, NSWindowDelegate  {
    
    @IBOutlet weak var buttonRemoteCapture: NSButton!
    @IBOutlet weak var buttonCameraSetting: NSButton!
    @IBOutlet weak var buttonFileDownload: NSButton!
    @IBOutlet weak var buttonFileDelete:NSButton!
    @IBOutlet weak var buttonFileDownload2: NSButton!
    @IBOutlet weak var buttonFileDelete2:NSButton!
    
    fileprivate var _controller : CameraController!
    fileprivate var _isVolumeInfoGeted : Bool = false
    
    init(controller: CameraController){
        super.init(window: nil)
        Bundle.main.loadNibNamed("MainWindow", owner: self, topLevelObjects: nil)
        self._controller = controller

        buttonRemoteCapture.isEnabled = false
        buttonCameraSetting.isEnabled = false

        buttonRemoteCapture.action = #selector(self.remoteCaptureTapped)
        buttonFileDownload.action = #selector(self.fileDownloadTapped)
        buttonFileDownload2.action = #selector(self.fileDownloadTapped2)
        buttonCameraSetting.action = #selector(self.cameraSettingTapped)
        buttonFileDelete.action = #selector(self.fileDeleteTapped)
        buttonFileDelete2.action = #selector(self.fileDeleteTapped2)

        self.getVolumeInfo()
    }
    
    deinit {
        NSApp.stopModal()
        NSApp.abortModal()
        NSApp.terminate(NSApp.windows)
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func remoteCaptureTapped(){
        
        let remoteControl = RemoteCapture(controller: _controller)
        let anApplication = NSApplication.shared
        anApplication.runModal(for: remoteControl.window!)
        
    }
    
    @objc func cameraSettingTapped(){
        let settingCtrl = CameraSetting(controller: _controller)
        let anApplication = NSApplication.shared
        // UIlock
        EdsSendStatusCommand(_controller.getCameraModel().getCameraObject(), EdsCameraStatusCommand(kEdsCameraStatusCommand_UILock), 1)
        anApplication.runModal(for: settingCtrl.window!)
        // UIUnlock
        EdsSendStatusCommand(_controller.getCameraModel().getCameraObject(), EdsCameraStatusCommand(kEdsCameraStatusCommand_UIUnLock), 1)
    }
    
    @objc func fileDownloadTapped(){
        let downloadCtrl = Progress(controller: _controller)
        let anApplication = NSApplication.shared
        _controller.getCameraModel().setSelectedVolume(0)
        downloadCtrl.startDownload()
        anApplication.runModal(for: downloadCtrl.window!)
    }
    
    @objc func fileDownloadTapped2(){
        let downloadCtrl = Progress(controller: _controller)
        let anApplication = NSApplication.shared
        _controller.getCameraModel().setSelectedVolume(1)
        downloadCtrl.startDownload()
        anApplication.runModal(for: downloadCtrl.window!)
    }
    
    @objc func fileDeleteTapped(){
        let deleteCtrl = Progress(controller: _controller)
        let anApplication = NSApplication.shared
        _controller.getCameraModel().setSelectedVolume(0)
        deleteCtrl.startDelete()
        anApplication.runModal(for: deleteCtrl.window!)
    }
    
    @objc func fileDeleteTapped2(){
        let deleteCtrl = Progress(controller: _controller)
        let anApplication = NSApplication.shared
        _controller.getCameraModel().setSelectedVolume(1)
        deleteCtrl.startDelete()
        anApplication.runModal(for: deleteCtrl.window!)
    }
    
    func windowShouldClose(_ sender: AnyObject) -> Bool { return true }
    
    func windowWillClose(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self)
        NSApp.stopModal()
        NSApp.abortModal()
        
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    
    func getVolumeInfo(){
        var volume : EdsVolumeRef? = nil
        var volumeCount = 0 as EdsUInt32
        var volumeInfo = EdsVolumeInfo()
        let dispatchGroup = DispatchGroup()
        let error = EdsGetChildCount(self._controller.getCameraModel().getCameraObject(), &volumeCount)
        
        // If the card is not detected, try runloop processing
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 1))
        
        if(error != EDS_ERR_OK){
            //Repeat until a volumeCount can be obtained
            dispatchGroup.notify(queue: .main) {
                
                Thread.sleep(forTimeInterval: 1.0)
                self.getVolumeInfo()
            }
            return
            
        }
        
        
        if(volumeCount > 0){
            EdsGetChildAtIndex(self._controller.getCameraModel().getCameraObject(), 0, &volume)
            EdsGetVolumeInfo(volume, &volumeInfo)
            if(volumeInfo.storageType != kEdsStorageType_Non.rawValue){
                self.buttonFileDownload.isEnabled = true
                let stVolumeLabel = withUnsafePointer(to: volumeInfo.szVolumeLabel) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: volumeInfo.szVolumeLabel)) {
                        String(cString: $0)
                    }
                }
                self.buttonFileDownload.title = "Memory Card 1 (" + stVolumeLabel + ")"
                self.buttonFileDelete.isEnabled = true
                self.buttonFileDelete.title = "Memory Card 1 (" + stVolumeLabel + ")"
            }
            if(volumeCount > 1){
                EdsGetChildAtIndex(self._controller.getCameraModel().getCameraObject(), 1, &volume)
                EdsGetVolumeInfo(volume, &volumeInfo)
                if(volumeInfo.storageType != kEdsStorageType_Non.rawValue){
                    self.buttonFileDownload2.isEnabled = true
                    let stVolumeLabel = withUnsafePointer(to: volumeInfo.szVolumeLabel) {
                        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: volumeInfo.szVolumeLabel)) {
                            String(cString: $0)
                        }
                    }
                    self.buttonFileDownload2.title = "Memory Card 2 (" + stVolumeLabel + ")"
                    self.buttonFileDelete2.isEnabled = true
                    self.buttonFileDelete2.title = "Memory Card 2 (" + stVolumeLabel + ")"
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.buttonRemoteCapture.isEnabled = true
            self.buttonCameraSetting.isEnabled = true
        })
    }
}
