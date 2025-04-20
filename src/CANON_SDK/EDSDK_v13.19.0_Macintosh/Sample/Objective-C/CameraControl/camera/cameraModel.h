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
*   Copyright Canon Inc. 2007-2008 All Rights Reserved                             *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/


#import <Cocoa/Cocoa.h>
#import "EDSDK.h"
#import "cameraEvent.h"

@interface CameraModel : NSObject 
{
	EdsCameraRef _camera;
	
	//Count of UIlock
	int _lockCount;
	
	// Model name
	EdsChar		_modelString[EDS_MAX_NAME];
	
	// Taking a picture parameter
	EdsUInt32	_AEMode;
	EdsUInt32	_Av;
	EdsUInt32	_Tv;
	EdsUInt32	_Iso;
	EdsUInt32	_MeteringMode;
	EdsUInt32	_ExposureCompensation;
	EdsUInt32	_ImageQuality;
	EdsUInt32	_availableShot;
	EdsUInt32	_evfMode;
	EdsUInt32	_evfOutputDevice;
	EdsUInt32	_evfDepthOfFieldPreview;
	EdsUInt32	_evfZoom;
	EdsPoint	_evfZoomPosition;
	EdsUInt32	_evfAFMode;
	EdsFocusInfo	_focusInfo;
			
	// List of value in which taking a picture parameter can be set
	EdsPropertyDesc	_AEModeDesc;
	EdsPropertyDesc	_AvDesc;
	EdsPropertyDesc	_TvDesc;
	EdsPropertyDesc	_IsoDesc;
	EdsPropertyDesc	_MeteringModeDesc;
	EdsPropertyDesc	_ExposureCompensationDesc;
	EdsPropertyDesc	_ImageQualityDesc;
	EdsPropertyDesc	_evfAFModeDesc;	
}

-(id)initWithCameraRef:(EdsCameraRef)camera;

-(void)setProperty:(EdsUInt32)propertyID withUInt32:(EdsUInt32)value;
-(EdsUInt32)getPropertyUInt32:(EdsUInt32)propertyID;

-(void)setProperty:(EdsUInt32)propertyID withString:(EdsChar[])value;
-(EdsChar *)getPropertyString:(EdsUInt32)propertyID;

-(void)setProperty:(EdsUInt32)propertyID withDesc:(EdsPropertyDesc)desc;
-(EdsPropertyDesc)getPropertyDesc:(EdsUInt32)propertyID;

-(EdsCameraRef)camera;
-(void)setCamera:(EdsCameraRef)camera;

-(void)notifyObservers:(CameraEvent *)event;

-(EdsUInt32)evfMode;
-(void)setEvfMode:(EdsUInt32)evfMode;
-(EdsUInt32)evfOutputDevice;
-(void)setEvfOutputDevice:(EdsUInt32)evfOutputDevice;
-(EdsUInt32)evfDepthOfFieldPreview;
-(void)setEvfDepthOfFieldPreview:(EdsUInt32)evfDepthOfFieldPreview;
-(EdsUInt32)evfZoom;
-(void)setEvfZoom:(EdsUInt32)evfZoom;
-(EdsPoint)evfZoomPosition;
-(void)setEvfZoomPosition:(EdsPoint)evfZoomPosition;
-(EdsUInt32)evfAFMode;
-(void)setEvfAFMode:(EdsUInt32)evfAFMode;
-(EdsFocusInfo)focusInfo;
-(void)setFocusInfo:(EdsFocusInfo)focusInfo;

@end
