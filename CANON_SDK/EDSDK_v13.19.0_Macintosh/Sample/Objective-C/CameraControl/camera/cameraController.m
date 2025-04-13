/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraController.m                                              *
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


#import "cameraController.h"
#import "cameraCommand.h"
#import "OpenSessionCommand.h"
#import "CloseSessionCommand.h"
#import "SaveSettingCommand.h"
#import "SetCapacityCommand.h"
#import "GetPropertyCommand.h"
#import "GetPropertyDescCommand.h"
#import "SetPropertyCommand.h"
#import "TakePictureCommand.h"
#import "DownloadCommand.h"
#import "StartEvfCommand.h"
#import "EndEvfCommand.h"
#import "DownloadEvfCommand.h"
#import "DriveLensCommand.h"
#import "ActionEdsRef.h"
#import "EvfAFCommand.h"
#import "PressingShutterButtomCommand.h"

@interface CameraController (Local)
-(void)storeAsync:(CameraCommand *)command;
@end

@implementation CameraController

-(id)init
{
	[super init];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionPerformedNotified:) name:ACTION_PERFORMED_MESSAGE object:nil];

	_processor = [[Processor alloc] init];
	return self;
}

-(void)dealloc
{

//Press Off 
	[self storeAsync:[[[PressShutterButtonCommand alloc] init:_model withParameter:kEdsCameraCommand_ShutterButton_OFF] autorelease]];
//End Evf
	[self storeAsync:[[[EndEvfCommand alloc] initWithCameraModel:_model] autorelease]];
					
	EdsCloseSession([_model camera]);
	[_processor release];
	[super dealloc];
}

-(void)setCameraModel:(CameraModel *)camera
{
	[_model release];
	_model = [camera retain];
}

-(void)actionPerformedNotified:(NSNotification *)notification
{
	ActionEvent * event;
	NSDictionary* dict = [notification userInfo];

	event = [dict objectForKey:@"action_event"];
	if(event == nil)
	{
		return ;
	}

	[self actionPerformed:event];
}

-(void)actionPerformed:(ActionEvent *)event
{
	NSString *command = [event getActionCommand];

	NSNumber *number;
	NSData *data;
	ActionEdsRef *refObject;
	EdsPropertyID propertyID;
	EdsUInt32 value;
	EdsCapacity capacity;
	EdsDirectoryItemRef dirRef;
	EdsPoint  point;
	const int stepY = 384;
	const int stepX = 128;

	number = [event getArg]; 
	if([command isEqualToString:@"get_Property"])
	{
		propertyID = [number intValue];
		[self storeAsync:[[[GetPropertyCommand alloc] init:_model withProperty: propertyID] autorelease]];
	}

	if([command isEqualToString:@"get_PropertyDesc"])
	{
		propertyID = [number intValue];
		[self storeAsync:[[[GetPropertyDescCommand alloc] init:_model withProperty: propertyID] autorelease]];
	}

	if([command isEqualToString:@"set_AEMode"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_AEModeSelect  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_Tv"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Tv  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_Av"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Av  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_Iso"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_ISOSpeed  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_Metering"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_MeteringMode  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_ImageQuality"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_ImageQuality  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"set_Exposure"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_ExposureCompensation  andUInt32:value] autorelease]];
	}
	
	if([command isEqualToString:@"closing"])
	{
		[self storeAsync:[[[CloseSessionCommand alloc] initWithCameraModel:_model] autorelease]];
	}
	
	if([command isEqualToString:@"take_picture"])
	{
		[self storeAsync:[[[TakePictureCommand alloc] initWithCameraModel:_model] autorelease]];
	}
	
	if([command isEqualToString:@"Pressing_Halfway"])
	{
		[self storeAsync:[[[PressShutterButtonCommand alloc] init:_model withParameter:kEdsCameraCommand_ShutterButton_Halfway] autorelease]];
	}
	
	if([command isEqualToString:@"Pressing_Completely"])
	{
		[self storeAsync:[[[PressShutterButtonCommand alloc] init:_model withParameter:kEdsCameraCommand_ShutterButton_Completely] autorelease]];
	}	
	
	if([command isEqualToString:@"Pressing_Off"])
	{
		[self storeAsync:[[[PressShutterButtonCommand alloc] init:_model withParameter:kEdsCameraCommand_ShutterButton_OFF] autorelease]];
	}
	
	if([command isEqualToString:@"set_capacity"])
	{
		// capacity = {0x7FFFFFFF, 0x1000, 1};
		data = [event getArg];
		[data getBytes:&capacity length:sizeof(capacity)];
		[self storeAsync:[[[SetCapacityCommand alloc] init:_model withCapacity:capacity] autorelease]];
	}

	if([command isEqualToString:@"download"])
	{
		refObject = [event getArg];
		dirRef = (EdsDirectoryItemRef)[refObject getRef];
		[self storeAsync:[[[DownloadCommand alloc] init:_model withDirectoryItem:dirRef] autorelease]];
	}
	
/////////////////////////////
//		EVF Control
/////////////////////////////
	if([command isEqualToString:@"start_evf"])
	{
		[self storeAsync:[[[StartEvfCommand alloc] initWithCameraModel:_model] autorelease]];
	}
	
	if([command isEqualToString:@"end_evf"])
	{
		[self storeAsync:[[[EndEvfCommand alloc] initWithCameraModel:_model] autorelease]];
	}
	
	if([command isEqualToString:@"download_evf"])
	{
		[self storeAsync:[[[DownloadEvfCommand alloc] initWithCameraModel:_model] autorelease]];
	}
	
	if([command isEqualToString:@"focus_far1"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Far1] autorelease]];
	}
	if([command isEqualToString:@"focus_far2"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Far2] autorelease]];
	}
	if([command isEqualToString:@"focus_far3"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Far3] autorelease]];
	}

	if([command isEqualToString:@"focus_near1"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Near1] autorelease]];
	}
	if([command isEqualToString:@"focus_near2"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Near2] autorelease]];
	}
	if([command isEqualToString:@"focus_near3"])
	{
		[self storeAsync:[[[DriveLensCommand alloc] init:_model withParameter:kEdsEvfDriveLens_Near3] autorelease]];
	}

	if([command isEqualToString:@"focus_left"])
	{
		point = [_model evfZoomPosition];
		point.x -= stepX;
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_ZoomPosition  andPoint:point] autorelease]];
	}
	if([command isEqualToString:@"focus_right"])
	{
		point = [_model evfZoomPosition];
		point.x += stepX;
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_ZoomPosition  andPoint:point] autorelease]];
	}
	if([command isEqualToString:@"focus_up"])
	{
		point = [_model evfZoomPosition];
		point.y -= stepY;
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_ZoomPosition  andPoint:point] autorelease]];
	}
	if([command isEqualToString:@"focus_down"])
	{
		point = [_model evfZoomPosition];
		point.y += stepY;
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_ZoomPosition  andPoint:point] autorelease]];
	}
	
	if([command isEqualToString:@"zoom_fit"])
	{
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_Zoom  andUInt32:kEdsEvfZoom_Fit] autorelease]];
	}
	
	if([command isEqualToString:@"zoom_x5"])
	{
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_Zoom  andUInt32:kEdsEvfZoom_x5] autorelease]];
	}	

	if([command isEqualToString:@"set_EvfAFMode"])
	{
		value = [number intValue];
		[self storeAsync:[[[SetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Evf_AFMode  andUInt32:value] autorelease]];
	}

	if([command isEqualToString:@"evf_AFOn"])
	{
		[self storeAsync:[[[EvfAFCommand alloc] init:_model withParameter:kEdsCameraCommand_EvfAf_ON] autorelease]];
	}
	
	if([command isEqualToString:@"evf_AFOff"])
	{
		[self storeAsync:[[[EvfAFCommand alloc] init:_model withParameter:kEdsCameraCommand_EvfAf_OFF] autorelease]];
	}
}

-(void)run
{
	// EdsCapacity capacity = {0x7fffffff, 0x1000, 1};
	
	[_processor start];
	
	//The communication with the camera begins
	[self storeAsync:[[[OpenSessionCommand alloc] initWithCameraModel:_model] autorelease]];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];

	//It is necessary to acquire the property information that cannot acquire in sending OpenSessionCommand automatically by manual operation.
	[self storeAsync:[[[GetPropertyCommand alloc] init:_model withProperty:kEdsPropID_ProductName] autorelease]];
			
	//Preservation ahead is set to PC
	// [self storeAsync:[[[SaveSettingCommand alloc] init:_model saveTo:kEdsSaveTo_Host] autorelease]];

	//Setting of PC capacity
	// [self storeAsync:[[[SetCapacityCommand alloc] init:_model withCapacity:capacity] autorelease]];

	// [self storeAsync:[[[GetPropertyCommand alloc] init:_model withProperty:kEdsPropID_Unknown] autorelease]];
	// [self storeAsync:[[[GetPropertyDescCommand alloc] init:_model withProperty:kEdsPropID_Unknown] autorelease]];

}

@end

@implementation CameraController (Local)

//The command is received
-(void)storeAsync:(CameraCommand *)command
{
	if(command != nil)
	{
		[_processor postCommand:command];
	}
}
@end
