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

class GetPropertyCommand: Command {
    
    fileprivate var _propertyID: EdsPropertyID
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, propertyID: EdsPropertyID){
        
        _propertyID = propertyID
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        
        if (error == EdsUInt32(EDS_ERR_OK)){
            
            error = self.getProperty(_propertyID)
            
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
        
    }
    
    func getProperty(_ propertyID: EdsPropertyID) -> EdsError{
        
        var err = EdsUInt32(EDS_ERR_OK)
        var dataType: EdsDataType = kEdsDataType_Unknown
        var dataSize: EdsUInt32 = 0
        var uintData: EdsUInt32 = 0
        
        
        if(propertyID == EdsPropertyID(kEdsPropID_Unknown))
        {
            
            //If unknown is returned for the property ID , the required property must be retrieved again
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_AEModeSelect))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_Tv))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_Av))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_ISOSpeed))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_MeteringMode))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_ExposureCompensation))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_ImageQuality))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_Evf_AFMode))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_AvailableShots))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_WhiteBalance))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_TempStatus))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_DriveMode))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_FixedMovie))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_MovieHFRSetting))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_MirrorUpSetting))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_MirrorLockUpState))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_MovieParam))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_PictureStyle))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_Aspect))
            }
            if(err == EdsUInt32(EDS_ERR_OK))
            {
                err = self.getProperty(EdsPropertyID(kEdsPropID_Evf_ClickWBCoeffs))
            }

            return err
        }
        
        //Acquisition of the property size
        if (err == EdsUInt32(EDS_ERR_OK))
        {
            err = EdsGetPropertySize(_model.getCameraObject(), _propertyID, 0, &dataType, &dataSize)
        }
        
        if (err == EdsUInt32(EDS_ERR_OK))
        {
            if(dataType == kEdsDataType_UInt32 || propertyID == EdsPropertyID(kEdsPropID_Evf_OutputDevice))
            {
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(MemoryLayout<EdsUInt32>.size), &uintData)
                
                if (err == EdsUInt32(EDS_ERR_OK))
                {
                    _model.SetProperty(propertyID, property: uintData)
                }
                
            }
            
            if(dataType == kEdsDataType_Int32){
                
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(MemoryLayout<EdsInt32>.size), &uintData)
                
                if (err == EdsUInt32(EDS_ERR_OK))
                {
                    _model.SetProperty(propertyID, property: uintData)
                }

                
            }
            
            //Acquired property value is set
            if(dataType == kEdsDataType_String)
            {
                var stringData:[EdsChar] = Array<EdsChar>(repeating: 0, count: 256)
                
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(MemoryLayout<EdsChar>.size*256), &stringData)
                
                //Acquired property value is set
                if(err == EdsUInt32(EDS_ERR_OK))
                {
                    _model.setPropertyString(propertyID, string: &stringData)
                }
            }
            
            if(dataType == kEdsDataType_FocusInfo)
            {
                var focusInfo: EdsFocusInfo = EdsFocusInfo()
                
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(MemoryLayout<EdsFocusInfo>.size), &focusInfo)
                
                if (err == EdsUInt32(EDS_ERR_OK))
                {
                    _model.setFocusInfo(focusInfo)
                    
                }else if(err == EdsUInt32(EDS_ERR_PROPERTIES_UNAVAILABLE)){
                    
                    let defaultFocusInfo:EdsFocusInfo = EdsFocusInfo()
                    _model.setFocusInfo(defaultFocusInfo)
                    
                }
                
            }
            if(dataType == kEdsDataType_Time)
            {
                var timeData: EdsTime = EdsTime()
                
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(MemoryLayout<EdsTime>.size), &timeData)
                
            }

            if(dataType == kEdsDataType_ByteBlock)
            {
                var byteData: [UInt8] = Array<UInt8>(repeating: 0, count: Int(dataSize))
                err = EdsGetPropertyData(_model.getCameraObject(), propertyID, 0, EdsUInt32(dataSize), &byteData)
                
                if (err == EdsUInt32(EDS_ERR_OK))
                {
                    _model.setPropertyByteBlock(propertyID, byte: &byteData)
                }
            }
        }
        
        return err
        
    }
    
}
