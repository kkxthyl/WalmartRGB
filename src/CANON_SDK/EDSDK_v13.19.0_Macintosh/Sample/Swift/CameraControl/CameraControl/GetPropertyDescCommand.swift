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

class GetPropertyDescCommand: Command {
    
    fileprivate var _propertyID: EdsPropertyID = 0
    fileprivate var _model: CameraModel
    
    init(model: CameraModel, propertyID: EdsPropertyID) {
        
        _propertyID = propertyID
        _model = model
        super.init(model: model)
        
    }
    
    override func execute() -> Bool {
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
       
        //Get property Desc
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            error = self.getPropertyDesc(_propertyID)
        }
        
        //Notification of error
        let viewNotification = ViewNotification()
        return viewNotification.errorNotification(error)
    }
    
    func getPropertyDesc(_ propertyID: EdsPropertyID) -> EdsError{
        
        var error: EdsError = EdsUInt32(EDS_ERR_OK)
        var desc: EdsPropertyDesc = EdsPropertyDesc()
        
        if(propertyID == EdsPropertyID(kEdsPropID_Unknown))
        {
            //If unknown is returned for the property ID , the required property must be retrieved again
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_AEModeSelect))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_Tv))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_Av))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_ISOSpeed))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_MeteringMode))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_ExposureCompensation))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_ImageQuality))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_Evf_AFMode))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_WhiteBalance))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_DriveMode))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_MovieParam))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_MovieHFRSetting))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_PictureStyle))
            }
            if(error == EdsUInt32(EDS_ERR_OK))
            {
                error = self.getPropertyDesc(EdsPropertyID(kEdsPropID_Aspect))
            }

            return error
        }
        
        
        //Acquisition of value list that can be set
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            error = EdsGetPropertyDesc(_model.getCameraObject(), propertyID, &desc)
        }
        
        //The value list that can be the acquired setting it is set
        if(error == EdsUInt32(EDS_ERR_OK))
        {
            _model.setPropertyDesc(propertyID, propertyDesc: desc)
        }
        
        if( desc.numElements == 1 ){
            if (propertyID != kEdsPropID_DC_Zoom){                
                let array = getPropDesc(desc)
                _model.SetProperty(propertyID,  property: array[Int(0)])
            }
        }

        return error
        
    }
    
}


    

    

