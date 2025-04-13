/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : SaveSettingCommand.m                                            *
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


#import "SaveSettingCommand.h"


@implementation SaveSettingCommand

-(id)init:(CameraModel *)model saveTo:(EdsSaveTo)saveTo
{
	[super initWithCameraModel:model];
	
	_saveTo = saveTo;
	return self;
}

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;


	//It sets preserving ahead
	if(error == EDS_ERR_OK)
	{
		error = EdsSetPropertyData([_model camera], kEdsPropID_SaveTo, 0, sizeof(_saveTo), &_saveTo);
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		// It retries it at device busy
		if(error == EDS_ERR_DEVICE_BUSY)
		{
			number = [[NSNumber alloc] initWithInt: error];
			event = [[CameraEvent alloc] init:@"DeviceBusy" withArg:number];
			[_model notifyObservers:event];	
			[event release];
			[number release];
			return NO;
		}
		
		number = [[NSNumber alloc] initWithInt: error];
		event = [[CameraEvent alloc] init:@"error" withArg:number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}
	
	return YES;
}

@end
