/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : StartEvfCommand.m                                               *
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

#import "StartEvfCommand.h"
#import "cameraEvent.h"

@implementation StartEvfCommand

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	EdsUInt32 evfMode;
	EdsUInt32 device;
	NSNumber * number;

	// Change settings because live view cannot be started
	// when camera settings are set to “do not perform live view.”
	evfMode = [_model evfMode];
	
	if(evfMode == 0)
	{
		evfMode = 1;
		
		// Set to the camera.
		error = EdsSetPropertyData([_model camera], kEdsPropID_Evf_Mode, 0, sizeof(evfMode), &evfMode);
	}
	
	if(error == EDS_ERR_OK)	
	{
		// Get the current output device.
		device = [_model evfOutputDevice];
		
		// Set the PC as the current output device.
		device |= kEdsEvfOutputDevice_PC;
		
		// Set to the camera.
		error = EdsSetPropertyData([_model camera], kEdsPropID_Evf_OutputDevice, 0, sizeof(device), &device);
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
