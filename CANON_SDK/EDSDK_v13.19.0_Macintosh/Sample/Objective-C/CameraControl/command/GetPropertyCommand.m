/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : GetPropertyCommand.m                                            *
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


#import "GetPropertyCommand.h"
#import "cameraEvent.h"

@interface GetPropertyCommand (Local)
-(EdsError)getProperty:(EdsPropertyID)propertyID;
@end

@implementation GetPropertyCommand


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
	

	//Get property value
	if(error == EDS_ERR_OK)
	{
		error = [self getProperty:_propertyID];
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

@implementation GetPropertyCommand (Local)
-(EdsError)getProperty:(EdsPropertyID)propertyID
{
	CameraEvent *event;
	EdsError error = EDS_ERR_OK;
	EdsDataType dataType = kEdsDataType_Unknown;
	EdsUInt32 dataSize = 0;
	EdsUInt32 uintData;
	EdsChar stringData[EDS_MAX_NAME];
	NSNumber * number;
	
	if(propertyID == kEdsPropID_Unknown)
	{
		//If unknown is returned for the property ID , the required property must be retrieved again
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_AEMode];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_Tv];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_Av];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_ISOSpeed];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_MeteringMode];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_ExposureCompensation];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_ImageQuality];
		}
		if(error == EDS_ERR_OK)
		{
			error = [self getProperty:kEdsPropID_Evf_AFMode];
		}
		return error;
	}

	//Acquisition of the property size
	if(error == EDS_ERR_OK)
	{
		error = EdsGetPropertySize( [_model camera], propertyID, 0, &dataType, &dataSize);
	}
	
	if(error == EDS_ERR_OK)
	{
		if(dataType == kEdsDataType_UInt32 || propertyID == kEdsPropID_Evf_OutputDevice)
		{
			//Acquisition of the property
			error = EdsGetPropertyData([_model camera], propertyID, 0, dataSize, &uintData);
			
			if(error == EDS_ERR_OK)
			{
				[_model setProperty:propertyID withUInt32:uintData];
			}
		}

		//Acquired property value is set
		if(dataType == kEdsDataType_String)
		{
			//Acquisition of the property
			error = EdsGetPropertyData([_model camera], propertyID, 0, dataSize, &stringData);
			
			//Acquired property value is set
			if(error == EDS_ERR_OK)
			{
				[_model setProperty:propertyID withString:stringData];
			}
		}
		if(dataType == kEdsDataType_FocusInfo)
		{
			EdsFocusInfo focusInfo = {0};
			error = EdsGetPropertyData([_model camera], propertyID, 0, dataSize, &focusInfo);
			
			//Acquired property value is set
			if(error == EDS_ERR_OK)
			{
				[_model setFocusInfo:focusInfo];
			}
		}
	}

	//Update notification
	if(error == EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt:propertyID];
		event = [[CameraEvent alloc] init:@"PropertyChanged" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}
	
	return error;
}

@end
