/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : AppController.m                                                 *
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

#import "AppController.h"
#import "EDSDK.h"

#import "cameraModel.h"
#import "cameraEventListener.h"

#import "PressingShutterButtomCommand.h"

@interface AppController (Local)
-(void)terminate:(NSNotification *)notification;
-(void)alert;
-(CameraModel *)cameraModelFactory:(EdsDeviceInfo)deviceInfo;
-(EdsError)setUpEventHandler;
-(void)setupPoupCommand;
-(void)setupButtonCommand;
@end

@implementation AppController

-(id)init
{
	[super init];
	return self;
}

-(void)awakeFromNib
{
	EdsError error = EDS_ERR_OK;
	EdsCameraListRef  cameraList = NULL;
	EdsUInt32 count = 0;
	EdsDeviceInfo deviceInfo;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminate:) name: NSApplicationWillTerminateNotification object:NSApp];
	
	// Initialization of SDK
	error = EdsInitializeSDK();
    
    // If the camera is not detected, try runloop processing
    [[NSRunLoop currentRunLoop]
    runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    
	//Acquisition of camera list
	if(error == EDS_ERR_OK)
	{
		_isSDKLoaded = YES;
		error = EdsGetCameraList(&cameraList);
	}
	
	//Acquisition of number of Cameras
	if(error == EDS_ERR_OK)
	{
		error = EdsGetChildCount(cameraList, &count);
		if(count == 0)
		{
			error = EDS_ERR_DEVICE_NOT_FOUND;
		}
	}
	

	//Acquisition of camera at the head of the list
	if(error == EDS_ERR_OK)
	{
		error = EdsGetChildAtIndex(cameraList, 0, &_camera);
	}
	
	//Acquisition of camera information
	if(error == EDS_ERR_OK)
	{
		error = EdsGetDeviceInfo(_camera, &deviceInfo);
		if(error == EDS_ERR_OK && _camera == NULL)
		{
			error = EDS_ERR_DEVICE_NOT_FOUND;
		}
	}
	
	//Release camera list
//	if(cameraList != NULL)
//	{
		EdsRelease(cameraList);
//	}
	
	//Create Camera model
	if(error == EDS_ERR_OK)
	{
		_model = [self cameraModelFactory:deviceInfo];
		if(_model == NULL)
		{
			error = EDS_ERR_DEVICE_NOT_FOUND;
		}
	}
	
	if(error != EDS_ERR_OK)
	{
		[self alert];
		EdsRelease(_camera);
		exit(0);
	}
	
	if(error == EDS_ERR_OK)
	{	
		[self setupPoupCommand];
		[self setupButtonCommand];
		
		//Create CameraController
		_controller = [[CameraController alloc] init ];
		[_controller setCameraModel: _model];

		//Set Event Handler
		[self setUpEventHandler];

		[_controller run];
	}
}

- (void) dealloc 
{
	[super dealloc];
}

- (IBAction)action: (id)sender
{
	[sender fireEvent];
}

- (IBAction)close: (id)sender
{

}

@end

@implementation AppController (Local)

-(void)terminate:(NSNotification *)notification
{
	[_controller release];
	[_model release];
	
	//Release Camera
	if(_camera != NULL)
	{
		EdsRelease(_camera);
		_camera = NULL;
	}
	
	//Termination of SDK
	if(_isSDKLoaded)
	{
		EdsTerminateSDK();
	}
}

-(void)alert
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:@"ERROR!!"];
	[alert addButtonWithTitle:@"OK"];
	[alert setInformativeText:@"Can't detect camera."];
	[alert runModal];
	[alert release];
}

-(CameraModel *)cameraModelFactory:(EdsDeviceInfo)deviceInfo
{	
	// PTP protocol
	return [[CameraModel alloc] initWithCameraRef:_camera];
}

-(EdsError)setUpEventHandler
{
	EdsError error= EDS_ERR_OK;

	//Set Object Event Handler
	error = EdsSetObjectEventHandler(_camera, kEdsObjectEvent_All, handleObjectEvent, (EdsVoid *)_controller);
	
	//Set Property Event Handler
	if(error == EDS_ERR_OK)	
	{
		error = EdsSetPropertyEventHandler(_camera, kEdsPropertyEvent_All, handlePropertyEvent, (EdsVoid *)_controller);
	}
	
	//Set State Event Handler
	if(error == EDS_ERR_OK)
	{
		error = EdsSetCameraStateEventHandler(_camera, kEdsStateEvent_All, handleStateEvent, (EdsVoid *)_controller);
	}
	
	return error;
}

-(void)setupPoupCommand
{
	[_AEMode setActionCommand:@"set_AEMode"];
	[_Tv setActionCommand:@"set_Tv"];
	[_Av setActionCommand:@"set_Av"];
	[_Iso setActionCommand:@"set_Iso"];
	[_Exposure setActionCommand:@"set_Exposure"];
	[_Metering setActionCommand:@"set_Metering"];
	[_ImageQualityPopUp setActionCommand:@"set_ImageQuality"];
	[_EvfAFMode setActionCommand:@"set_EvfAFMode"];
}

-(void)setupButtonCommand
{
	[_TakePicture setActionCommand:@"take_picture"];
	[_StartEVF setActionCommand:@"start_evf"];
	[_EndEVF setActionCommand:@"end_evf"];
	[_FocusFar1 setActionCommand:@"focus_far1"];
	[_FocusFar2 setActionCommand:@"focus_far2"];
	[_FocusFar3 setActionCommand:@"focus_far3"];
	[_FocusNear1 setActionCommand:@"focus_near1"];
	[_FocusNear2 setActionCommand:@"focus_near2"];
	[_FocusNear3 setActionCommand:@"focus_near3"];
	
	[_FocusLeft setActionCommand:@"focus_left"];
	[_FocusRight setActionCommand:@"focus_right"];
	[_FocusUp setActionCommand:@"focus_up"];
	[_FocusDown setActionCommand:@"focus_down"];
	[_Zoom_Fit setActionCommand:@"zoom_fit"];
	[_Zoom_x5 setActionCommand:@"zoom_x5"];
	
	[_EvfAFOn setActionCommand:@"evf_AFOn"];
	[_EvfAFOff setActionCommand:@"evf_AFOff"];

	[_PressingHalfway setActionCommand:@"Pressing_Halfway"];
	[_PressingCompletely setActionCommand:@"Pressing_Completely"];
	[_PressingOff setActionCommand:@"Pressing_Off"];
}

@end
