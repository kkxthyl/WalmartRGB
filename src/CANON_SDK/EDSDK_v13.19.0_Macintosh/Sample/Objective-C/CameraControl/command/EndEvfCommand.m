/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : EndEvfCommand.m                                                 *
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

#import "EndEvfCommand.h"
#import "cameraEvent.h"

@implementation EndEvfCommand

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	EdsUInt32 device;
	EdsUInt32 depthOfFieldPreview;
	NSNumber * number;
	
	// Get the current output device.
	device = [_model evfOutputDevice];

	// Do nothing if the remote live view has already ended.
	if((device & kEdsEvfOutputDevice_PC) == 0)
	{
		return true;
	}

	// Get depth of field status.
	depthOfFieldPreview = [_model evfDepthOfFieldPreview];

	// Release depth of field in case of depth of field status.
	if(depthOfFieldPreview != 0)
	{
		depthOfFieldPreview = 0;
		error = EdsSetPropertyData([_model camera], kEdsPropID_Evf_DepthOfFieldPreview, 0, sizeof(depthOfFieldPreview), &depthOfFieldPreview);
		
		// Standby because commands are not accepted for awhile when the depth of field has been released.
		if(error == EDS_ERR_OK)
		{
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
		}
	}
	
	// Change the output device.
	if(error == EDS_ERR_OK)
	{
		device &= ~kEdsEvfOutputDevice_PC;
		error = EdsSetPropertyData([_model camera], kEdsPropID_Evf_OutputDevice, 0, sizeof(device), &device);
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
		// Retry until successful.
		return NO;
	}
	return YES;
}

@end
