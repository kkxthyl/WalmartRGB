/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraModel.h                                                   *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2007-2010 All Rights Reserved                        *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/


#import "cameraModel.h"
#import "observer.h"


@implementation CameraModel 

-(id)initWithCameraRef:(EdsCameraRef)camera
{
	[super init];
	
	_camera = camera;
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(EdsCameraRef)camera
{
	return _camera;
}

-(void)setCamera:(EdsCameraRef)camera
{
	_camera = camera;
}

//Setting of taking a picture parameter(UInt32)
-(void)setProperty:(EdsUInt32)propertyID withUInt32:(EdsUInt32)value
{
	switch(propertyID)
	{
		case kEdsPropID_AEModeSelect:
			_AEMode = value;
			break;
		case kEdsPropID_Tv:
			_Tv = value;
			break;
		case kEdsPropID_Av:
			_Av = value;
			break;
		case kEdsPropID_ISOSpeed:
			_Iso = value;
			break;
		case kEdsPropID_MeteringMode:
			_MeteringMode = value;
			break;
		case kEdsPropID_ExposureCompensation:
			_ExposureCompensation = value;
			break;
		case kEdsPropID_Evf_Mode:
			_evfMode = value;
			break;
		case kEdsPropID_Evf_OutputDevice:
			_evfOutputDevice = value;
			break;
		case kEdsPropID_Evf_DepthOfFieldPreview:
			_evfDepthOfFieldPreview = value;
			break;
		case kEdsPropID_ImageQuality:
			_ImageQuality = value;
			break;
		case kEdsPropID_Evf_AFMode:
			_evfAFMode = value;
			break;
		default:
			break;
	}
}

-(EdsUInt32)getPropertyUInt32:(EdsUInt32)propertyID
{
	switch(propertyID)
	{
		case kEdsPropID_AEModeSelect:
			return _AEMode;
			break;
		case kEdsPropID_Tv:
			return _Tv;
			break;
		case kEdsPropID_Av:
			return _Av;
			break;
		case kEdsPropID_ISOSpeed:
			return _Iso;
			break;
		case kEdsPropID_MeteringMode:
			return _MeteringMode ;
			break;
		case kEdsPropID_ExposureCompensation:
			return _ExposureCompensation;
			break;
		case kEdsPropID_Evf_Mode:
			return _evfMode;
			break;
		case kEdsPropID_Evf_OutputDevice:
			return _evfOutputDevice;
			break;
		case kEdsPropID_Evf_DepthOfFieldPreview:
			return _evfDepthOfFieldPreview;
			break;
		case kEdsPropID_ImageQuality:
			return _ImageQuality;
			break;
		case kEdsPropID_Evf_AFMode:
			return _evfAFMode;
			break;
		default:
			break;
	}
	
	return 0xffffffff;
}

-(void)setProperty:(EdsUInt32)propertyID withString:(EdsChar *)value
{
	switch(propertyID)
	{
		case kEdsPropID_ProductName:
			strcpy(_modelString, value);
			break;
	}
}

//Setting of taking a picture parameter(String)
-(EdsChar *)getPropertyString:(EdsUInt32)propertyID
{
	return  _modelString;
}

//Setting of value list that can set taking a picture parameter
-(void)setProperty:(EdsUInt32)propertyID withDesc:(EdsPropertyDesc)desc
{
	switch(propertyID)
	{
		case kEdsPropID_AEModeSelect:
			_AEModeDesc = desc;
			break;
		case kEdsPropID_Tv:
			_TvDesc = desc;
			break;
		case kEdsPropID_Av:
			_AvDesc = desc;
			break;
		case kEdsPropID_ISOSpeed:
			_IsoDesc = desc;
			break;
		case kEdsPropID_MeteringMode:
			_MeteringModeDesc = desc;
			break;
		case kEdsPropID_ExposureCompensation:
			_ExposureCompensationDesc = desc;
			break;
		case kEdsPropID_ImageQuality:
			_ImageQualityDesc = desc;
			break;
		case kEdsPropID_Evf_AFMode:
			_evfAFModeDesc = desc;
			break;
		default:
			break;
	}
}

//Acquisition of value list that can set taking a picture parameter
-(EdsPropertyDesc)getPropertyDesc:(EdsUInt32)propertyID
{
	EdsPropertyDesc desc = {0};
	switch(propertyID)
	{
		case kEdsPropID_AEModeSelect:
			desc = _AEModeDesc;
			break;
		case kEdsPropID_Tv:
			desc = _TvDesc;
			break;
		case kEdsPropID_Av:
			desc = _AvDesc;
			break;
		case kEdsPropID_ISOSpeed:
			desc = _IsoDesc;
			break;
		case kEdsPropID_MeteringMode:
			desc = _MeteringModeDesc;
			break;
		case kEdsPropID_ExposureCompensation:
			desc = _ExposureCompensationDesc;
			break;
		case kEdsPropID_ImageQuality:
			desc = _ImageQualityDesc;
			break;
		case kEdsPropID_Evf_AFMode:
			desc = _evfAFModeDesc;
			break;
		default:
			break;
	}
	
	return desc;
}


//Access to camera

-(EdsUInt32)evfMode
{
	return _evfMode;
}

-(void)setEvfMode:(EdsUInt32)evfMode
{
	_evfMode = evfMode;
}

-(EdsUInt32)evfOutputDevice
{
	return _evfOutputDevice;
}

-(void)setEvfOutputDevice:(EdsUInt32)evfOutputDevice
{
	_evfOutputDevice = evfOutputDevice;
}

-(EdsUInt32)evfDepthOfFieldPreview
{
	return _evfDepthOfFieldPreview;
}

-(void)setEvfDepthOfFieldPreview:(EdsUInt32)evfDepthOfFieldPreview
{
	_evfDepthOfFieldPreview = evfDepthOfFieldPreview;
}

-(EdsUInt32)evfZoom
{
	return _evfZoom;  
}

-(void)setEvfZoom:(EdsUInt32)evfZoom
{
	_evfZoom = evfZoom;
}

-(EdsPoint)evfZoomPosition
{
	return _evfZoomPosition;
}

-(void)setEvfZoomPosition:(EdsPoint)evfZoomPosition
{
	_evfZoomPosition = evfZoomPosition;
}

-(EdsUInt32)evfAFMode
{
	return _evfAFMode;  
}

-(void)setEvfAFMode:(EdsUInt32)evfAFMode
{
	_evfAFMode = evfAFMode;
}

-(EdsFocusInfo)focusInfo
{
	return _focusInfo;
}

-(void)setFocusInfo:(EdsFocusInfo)focusInfo
{
	_focusInfo = focusInfo;	
}

-(void)notifyObservers:(CameraEvent *)event
{
	NSDictionary * dict;
	CameraEvent * myEvent = [event retain];
	dict = [[NSDictionary alloc] initWithObjectsAndKeys:myEvent, @"event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:VIEW_UPDATE_MESSAGE object:self userInfo:dict];
	[myEvent release];
	[dict release];
}

@end
