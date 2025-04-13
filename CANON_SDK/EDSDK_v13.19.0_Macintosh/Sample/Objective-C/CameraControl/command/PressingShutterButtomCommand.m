/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : PressingShutterButtomCommand.m                                            *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2010 All Rights Reserved                             *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   08-07-31    F-001        create first version.                            *
*                                                                             *
******************************************************************************/

#import "PressingShutterButtomCommand.h"
#import "cameraEvent.h"

@implementation PressShutterButtonCommand

-(id)init:(CameraModel *)model withParameter:(EdsUInt32)parameter
{
	[super initWithCameraModel:model];
	
	_parameter = parameter;
	
	return self;
}

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;
	
	//Pressing halfway
	if(error == EDS_ERR_OK)
	{
		error = EdsSendCommand( [ _model camera] , kEdsCameraCommand_PressShutterButton, _parameter);
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		// It retries it at device busy
		if(error == EDS_ERR_DEVICE_BUSY)
		{
			number = [[NSNumber alloc] initWithInt:error];
			event = [[CameraEvent alloc] init:@"DeviceBusy" withArg: number];
			[_model notifyObservers:event];	
			[event release];
			[number release];
			return NO;
		}
		
		number = [[NSNumber alloc] initWithInt:error];
		event = [[CameraEvent alloc] init:@"error" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}

	return YES;
}
@end
