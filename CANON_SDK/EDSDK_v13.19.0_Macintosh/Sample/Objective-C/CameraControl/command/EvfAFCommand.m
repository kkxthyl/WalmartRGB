/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : EvfAFCommand.m                                               *
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
*   08-07-30    F-001        create first version.                            *
*                                                                             *
******************************************************************************/

#import "EvfAFCommand.h"
#import "cameraEvent.h"

@implementation EvfAFCommand

-(id)init:(CameraModel *)model withParameter:(EdsUInt32)parameter
{
	[super initWithCameraModel:model];
	
	_parameter = parameter;
	
	return self;
}

-(BOOL)execute
{

	EdsError error = EDS_ERR_OK;
	CameraEvent *event;
	NSNumber * number;
	
	if(error == EDS_ERR_OK)
	{
		error = EdsSendCommand( [ _model camera] , kEdsCameraCommand_DoEvfAf, _parameter);
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		// It doesn't retry it at device busy
		if(error == EDS_ERR_DEVICE_BUSY)
		{
			number = [[NSNumber alloc] initWithInt:error];
			event = [[CameraEvent alloc] init:@"DeviceBusy" withArg: number];
			[_model notifyObservers:event];	
			[event release];
			[number release];
			return YES;
		}

		number = [[NSNumber alloc] initWithInt:error];
		event = [[CameraEvent alloc] init:@"error" withArg: number ];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}
	return YES;
}
@end
