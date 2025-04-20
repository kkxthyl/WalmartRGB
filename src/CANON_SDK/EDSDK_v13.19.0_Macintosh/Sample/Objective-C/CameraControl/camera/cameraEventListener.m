/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraEventListener.h                                           *
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


#import "cameraEventListener.h"
#import "cameraController.h"
#import "ActionEvent.h"
#import "ActionEdsRef.h"

@implementation CameraEventListener
+(void)fireEvent:(CameraController *)listener command:(NSString *)command withArgument:(id)object
{
	ActionEvent *event = [[[ActionEvent alloc] init:command withArgument:object] autorelease];
	[listener actionPerformed:event];
}

@end

EdsError EDSCALLBACK handleObjectEvent( EdsUInt32 inEvent, EdsBaseRef inRef, EdsVoid * inContext)
{
	EdsError error = EDS_ERR_OK;
	CameraController *controller = (CameraController *)inContext;
	ActionEdsRef * refObject;
	
	switch(inEvent)
	{
	case kEdsObjectEvent_DirItemRequestTransfer:
		refObject = [[[ActionEdsRef alloc] initWithRef:inRef] autorelease];
		[CameraEventListener fireEvent: controller command: @"download" withArgument: refObject];
		break;
	default:
		//Object without the necessity is released
		if(inRef != NULL)
		{
			EdsRelease(inRef);
		}
		break;
	}
	return error;
}

EdsError EDSCALLBACK handlePropertyEvent( EdsUInt32 inEvent, EdsUInt32 inPropertyID ,EdsUInt32 inParam, EdsVoid * inContext)
{
	EdsError error = EDS_ERR_OK;
	CameraController *controller = (CameraController *)inContext;
	NSNumber * number;
	
	switch(inEvent)
	{
	case kEdsPropertyEvent_PropertyChanged:
		number = [[NSNumber alloc] initWithInt:inPropertyID];
		[CameraEventListener fireEvent: controller command: @"get_Property" withArgument:number];
		[number release];
		break;
	case kEdsPropertyEvent_PropertyDescChanged:
		number = [[NSNumber alloc] initWithInt:inPropertyID];
		[CameraEventListener fireEvent: controller command: @"get_PropertyDesc" withArgument:number];
		[number release];
		break;
	default:
		break;
	}
	return error;
}

EdsError EDSCALLBACK handleStateEvent( EdsUInt32 inEvent, EdsUInt32 inParam, EdsVoid * inContext)
{
	EdsError error = EDS_ERR_OK;
	CameraController *controller = (CameraController *)inContext;
	
	switch(inEvent)
	{
	case kEdsStateEvent_Shutdown:
		[CameraEventListener fireEvent: controller command: @"closing" withArgument: 0];
		break;
	default:
		break;
	}
	return error;
}
