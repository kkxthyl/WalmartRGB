/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : AppController.h                                                 *
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

/*  camera control */
#import "cameraModel.h"
#import "cameraController.h"

/*  window components  */
#import "AEModePopUp.h"
#import "TVPopUp.h"
#import "AvPopUp.h"
#import "IsoPopUp.h"
#import "ExposurePopUp.h"
#import "MeteringPopUp.h"
#import "ImageQualityPopUp.h"
#import "ActionButton.h"
#import "DownloadProgress.h"
#import "EvfPictureView.h"
#import "EVFAFModePopUp.h"
#import "EvfZoomButton.h"

@interface AppController : NSObject
{
    IBOutlet AEModePopUp	* _AEMode;
    IBOutlet TVPopUp		* _Tv;
	IBOutlet AvPopUp		* _Av;
    IBOutlet ExposurePopUp	* _Exposure;
    IBOutlet IsoPopUp		* _Iso;
    IBOutlet MeteringPopUp	* _Metering;
    IBOutlet ImageQualityPopUp	* _ImageQualityPopUp;
    IBOutlet ActionButton	* _TakePicture;
		
    IBOutlet ActionButton	* _StartEVF;
    IBOutlet ActionButton	* _EndEVF;
	
    IBOutlet ActionButton	* _FocusFar1;
    IBOutlet ActionButton	* _FocusFar2;
    IBOutlet ActionButton	* _FocusFar3;
    IBOutlet ActionButton	* _FocusNear1;
    IBOutlet ActionButton	* _FocusNear2;
    IBOutlet ActionButton	* _FocusNear3;
	
    IBOutlet ActionButton	* _FocusLeft;
    IBOutlet ActionButton	* _FocusRight;
    IBOutlet ActionButton	* _FocusUp;
    IBOutlet ActionButton	* _FocusDown;
	
    IBOutlet EvfPictureView * _EVFView;
    IBOutlet DownloadProgress * _Progress;
	
    IBOutlet ActionButton	* _Zoom_Fit;
    IBOutlet EvfZoomButton	* _Zoom_x5;
	
    IBOutlet EVFAFModePopUp	* _EvfAFMode;
	
    IBOutlet ActionButton	* _EvfAFOn;
    IBOutlet ActionButton	* _EvfAFOff;

    IBOutlet ActionButton	* _PressingHalfway;
    IBOutlet ActionButton	* _PressingCompletely;
	IBOutlet ActionButton	* _PressingOff;
		
	BOOL _isSDKLoaded;
	EdsCameraRef _camera;
	CameraModel * _model;
	CameraController * _controller;
}

-(id)init;

- (IBAction)action: (id)sender;
- (IBAction)close: (id)sender;

@end
