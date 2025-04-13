/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : GetPropertyDescCommand.m                                        *
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


#import "GetPropertyDescCommand.h"


@interface GetPropertyDescCommand (Local)
-(EdsError)getPropertyDesc:(EdsPropertyID)propertyID;
@end

@implementation GetPropertyDescCommand

-(id)init:(CameraModel *)camera withProperty:(EdsPropertyID)property
 {
	[super initWithCameraModel:camera];

	_propertyID = property;
	
	return self;
}

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;

	//Get property Desc
	if(error == EDS_ERR_OK)
	{
		error = [self getPropertyDesc:_propertyID];
	}

	//Notification of error
	if(error != EDS_ERR_OK)
	{
		// It retries it at device busy
		if((error & EDS_ERRORID_MASK) == EDS_ERR_DEVICE_BUSY)
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

@implementation GetPropertyDescCommand (Local)
-(EdsError)getPropertyDesc:(EdsPropertyID)propertyID
{
	CameraEvent *event;
	EdsError error = EDS_ERR_OK;
	EdsPropertyDesc desc = {0};
	NSNumber * number;
	
	if(propertyID == kEdsPropID_Unknown)
	{
		//If unknown is returned for the property ID , the required property must be retrieved again
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_AEMode];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_Tv];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_Av];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_ISOSpeed];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_MeteringMode];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_ExposureCompensation];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_ImageQuality];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getPropertyDesc:kEdsPropID_Evf_AFMode];
		}
		return error;
	}


	//Acquisition of value list that can be set
	if(error == EDS_ERR_OK)
	{
		error = EdsGetPropertyDesc([_model camera], propertyID, &desc);
	}

	//The value list that can be the acquired setting it is set	
	if(error == EDS_ERR_OK)
	{
		[_model setProperty:propertyID withDesc:desc];
	}
	
	//Update notification
	if(error == EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt:propertyID];
		event = [[CameraEvent alloc] init:@"PropertyDescChanged" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}
	
	return error;
}

@end

