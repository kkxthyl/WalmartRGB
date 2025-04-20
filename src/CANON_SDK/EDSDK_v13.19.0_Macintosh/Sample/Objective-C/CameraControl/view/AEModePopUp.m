/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : AEModePopUp.m                                                   *
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


#import "AEModePopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface AEModePopUp (Local)
-(void)initializeData;
@end

@implementation AEModePopUp

- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	
	[self removeAllItems];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
	[self initializeData];

	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)update:(NSNotification *)notification
{
	CameraEvent * event;
	CameraModel * model = [notification object];
	NSDictionary* dict = [notification userInfo];
	NSString * command;
	NSNumber * number;

	event = [dict objectForKey:@"event"];
	if(event == nil)
	{
		return ;
	}

	command = [event getEvent];
	number = [event getArg];
	//Update property
	if([command isEqualToString:@"PropertyChanged"])
	{
		if([number intValue] == kEdsPropID_AEModeSelect)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_AEModeSelect)
		{
            dispatch_async(dispatch_get_main_queue(), ^{
                EdsPropertyDesc desc;
                desc = [model getPropertyDesc:[number intValue]];
                [self updatePropertyDesc:&desc];
            });
		}
	}
}

@end

@implementation AEModePopUp (Local)
-(void)initializeData
{

	[self removeAllItems];
	
	// List of value and display name
	_propertyList = [[NSDictionary alloc] initWithObjectsAndKeys:
		@"P" , [NSNumber numberWithInt:0] ,
		@"Tv" , [NSNumber numberWithInt:1] , 
		@"Av" , [NSNumber numberWithInt:2] , 
		@"M" , [NSNumber numberWithInt:3] , 
        @"Fv" , [NSNumber numberWithInt:55] ,
		@"Bulb" , [NSNumber numberWithInt:4] ,
		@"A-DEP" , [NSNumber numberWithInt:5] , 
		@"DEP" , [NSNumber numberWithInt:6] , 
		@"C1" , [NSNumber numberWithInt:7] ,
		@"Lock" , [NSNumber numberWithInt:8] , 
		@"GreenMode" , [NSNumber numberWithInt:9] , 
		@"Night Portrait" , [NSNumber numberWithInt:10] , 
		@"Sports" , [NSNumber numberWithInt:11] , 
		@"Portrait" , [NSNumber numberWithInt:12] , 
		@"LandScape" , [NSNumber numberWithInt:13] , 
		@"Close-up" , [NSNumber numberWithInt:14] ,
		@"No Strobo" , [NSNumber numberWithInt:15] , 
		@"C2" , [NSNumber numberWithInt:16] , 
		@"C3" , [NSNumber numberWithInt:17] , 
		@"Creative Auto" , [NSNumber numberWithInt:19] ,
        @"Movies" , [NSNumber numberWithInt:20] ,
        @"Scene Intelligent Auto" , [NSNumber numberWithInt:22] ,
        @"SCN" , [NSNumber numberWithInt:25] ,
		@"unknown" , [NSNumber numberWithInt:0xffffffff] , nil];
}
@end
