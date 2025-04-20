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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    fileprivate var _camera: EdsCameraRef? = nil
    fileprivate var _deviceInfo: EdsDeviceInfo = EdsDeviceInfo()
    fileprivate var _isSDKLoaded = false;
    private var _controller : CameraController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: Notification.Name(rawValue: "MY_VIEW_UPDATE"), object: nil)
        
        // Insert code here to initialize your application
        var error = EdsInitializeSDK()
        
        // If the camera is not detected, try runloop processing
        RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 1))
        
        //Acquisition of camera list
        var cameraList = nil as EdsCameraListRef?
        if(error == EdsError(EDS_ERR_OK)){
            _isSDKLoaded = true
            error = EdsGetCameraList(&cameraList)
        }
        
        if(error == EdsError(EDS_ERR_OK)){
            
            //Acquisition of number of Cameras
            var count = 0 as EdsUInt32
            error = EdsGetChildCount(cameraList, &count)
            
            if(count == 0){
                error = EdsError(EDS_ERR_DEVICE_NOT_FOUND)
            }
        }
        
        //Acquisition of camera at the head of the list
        if(error == EdsError(EDS_ERR_OK)){
            error = EdsGetChildAtIndex(cameraList, 0, &_camera)
        }
        
        //Acquisition of camera information
        if(error == EdsError(EDS_ERR_OK)){
            error = EdsGetDeviceInfo(_camera, &_deviceInfo);
            
            if(error == EdsError(EDS_ERR_OK) && _camera == nil){
                error = EdsError(EDS_ERR_DEVICE_NOT_FOUND)
            }
        }
        
        //Release camera list
        if(cameraList != nil){
            EdsRelease(cameraList)
        }
        
        //Create Camera model
        var model : CameraModel! = nil
        if(error == EdsError(EDS_ERR_OK)){
            model = CameraModel(camera: _camera!);
        }
        
        //Release Camera
        if(error != EdsError(EDS_ERR_OK)){
            
            self.alert()
            EdsRelease(_camera);
            exit(0)
            
        }
        
        if(error == EdsError(EDS_ERR_OK)){
            
            //Create CameraController
            _controller = CameraController(model: model!)
            
            //Set Event Handler
            self.setupEventHandler()
            
            _controller.run()
        }
        
        
        let wd = MainWindow(controller: _controller)
        let anApplication = NSApplication.shared
        anApplication.runModal(for: wd.window!)
        
    }
    
        
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        //Release Camera
        if(_camera != nil){
            EdsRelease(_camera);
            _camera = nil;
        }
        
        //Termination of SDK
        if(_isSDKLoaded)
        {
            EdsTerminateSDK();
        }
    }
    
    func applicationShouldClose(_ sender: AnyObject) -> Bool { return true }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func alert(){
        let alert: NSAlert = NSAlert()
        alert.messageText = "Cannot detect camera"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func update(_ notification: Notification?) {
        
        let event = notification?.object as? CameraEvent
        switch(event?.getEvent()){
        
        case .terminate_APP?:
            NotificationCenter.default.removeObserver(self)
            NSApp.terminate(NSApp.windows)
        default:
            break;
        }
    }

    @discardableResult
    func setupEventHandler() -> EdsError
    {
        let controller: UnsafeMutableRawPointer = unsafeBitCast(_controller.self, to: UnsafeMutableRawPointer.self)

        let objectEventHandler: EdsObjectEventHandler = unsafeBitCast(handleObjectEvent, to: EdsObjectEventHandler.self)
        var error = EdsSetObjectEventHandler(_camera, EdsObjectEvent(kEdsObjectEvent_All), objectEventHandler, controller);
        
        //Set Property Event Handler
        if(error == EdsError(EDS_ERR_OK)){
            let propertyEventHandler: EdsPropertyEventHandler = unsafeBitCast(handlePropertyEvent, to: EdsPropertyEventHandler.self)
            error = EdsSetPropertyEventHandler(_camera, EdsPropertyEvent(kEdsPropertyEvent_All), propertyEventHandler, controller);
        }
        
        //Set State Event Handler
        if(error == EdsError(EDS_ERR_OK)){
            let stateEventHandler: EdsStateEventHandler = unsafeBitCast(handleStateEvent, to: EdsStateEventHandler.self)
            error = EdsSetCameraStateEventHandler(_camera, EdsStateEvent(kEdsStateEvent_All), stateEventHandler, controller);
        }
        
        return error;
    }
}
