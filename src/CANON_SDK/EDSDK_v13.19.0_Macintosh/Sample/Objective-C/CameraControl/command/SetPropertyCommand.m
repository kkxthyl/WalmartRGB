/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : SetPropertyCommand.m                                            *
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

#import "SetPropertyCommand.h"
#import "EDSDK.h"

@implementation SetPropertyCommand

-(id)init:(CameraModel *)camera withProperty:(EdsPropertyID)property andUInt32:(EdsUInt32)data
 {
	[super initWithCameraModel:camera];

	_propertyID = property;
	_data = data;
	_type = 0;
	
	return self;
}


-(id)init:(CameraModel *)camera withProperty:(EdsPropertyID)property andPoint:(EdsPoint)point
{
	[super initWithCameraModel:camera];

	_propertyID = property;
	_point = point;
	_type = 1;
	
	return self;
}

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;

	// Set property
	if(error == EDS_ERR_OK)
	{
		if(_type == 0)
		{
			error = EdsSetPropertyData([_model camera], _propertyID, 0, sizeof(_data), (EdsVoid *)&_data);
		}
		else if(_type == 1)
		{
			error = EdsSetPropertyData([_model camera], _propertyID, 0, sizeof(_point), (EdsVoid *)&_point);
		}
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		// It retries it at device busy
		number = [[NSNumber alloc] initWithInt: error];
		if(error == EDS_ERR_DEVICE_BUSY)
		{
			event = [[CameraEvent alloc] init:@"DeviceBusy" withArg:number];
			[_model notifyObservers:event];	
			[event release];
			[number release];
			return NO;
		}
		
		event = [[CameraEvent alloc] init:@"error" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}

	return YES;
}


@end
