/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : ExposurePopUp.m                                                 *
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


#import "ExposurePopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface ExposurePopUp (Local)
-(void)initializeData;
@end

@implementation ExposurePopUp

- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];

	return self;
}

-(void)dealloc
{
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
	[self initializeData];
	
	return self;
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
		if([number intValue] == kEdsPropID_ExposureCompensation)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_ExposureCompensation)
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

@implementation  ExposurePopUp (Local)

-(void)initializeData
{
	[self removeAllItems];
	
	// List of value and display name
	_propertyList = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"+5" , [NSNumber numberWithInt:0x28] ,
            @"+4 2/3" , [NSNumber numberWithInt:0x25] ,
            @"+4 1/2" , [NSNumber numberWithInt:0x24] ,
            @"+4 1/3" , [NSNumber numberWithInt:0x23] ,
            @"+4" , [NSNumber numberWithInt:0x20] ,
            @"+3 2/3" , [NSNumber numberWithInt:0x1d] ,
            @"+3 1/2" , [NSNumber numberWithInt:0x1c] ,
            @"+3 1/3" , [NSNumber numberWithInt:0x1b] ,
			@"+3" , [NSNumber numberWithInt:0x18] ,
			@"+2 2/3" , [NSNumber numberWithInt:0x15] ,
			@"+2 1/2" , [NSNumber numberWithInt:0x14] ,
			@"+2 1/3" , [NSNumber numberWithInt:0x13] ,
			@"+2" , [NSNumber numberWithInt:0x10] ,
			@"+1 2/3" , [NSNumber numberWithInt:0x0d] ,
			@"+1 1/2" , [NSNumber numberWithInt:0x0c] ,
			@"+1 1/3" , [NSNumber numberWithInt:0x0b] ,
			@"+1" , [NSNumber numberWithInt:0x08] ,
			@"+2/3" , [NSNumber numberWithInt:0x05] ,
			@"+1/2" , [NSNumber numberWithInt:0x04] ,
			@"+1/3" , [NSNumber numberWithInt:0x03] ,
			@"0" , [NSNumber numberWithInt:0x00] ,
			@"-1/3" , [NSNumber numberWithInt:0xfd] ,
			@"-1/2" , [NSNumber numberWithInt:0xfc] ,
			@"-2/3" , [NSNumber numberWithInt:0xfb] ,
			@"-1" , [NSNumber numberWithInt:0xf8] ,
			@"-1 1/3" , [NSNumber numberWithInt:0xf5] ,
			@"-1 1/2" , [NSNumber numberWithInt:0xf4] ,
			@"-1 2/3" , [NSNumber numberWithInt:0xf3] ,
			@"-2" , [NSNumber numberWithInt:0xf0] ,
			@"-2 1/3" , [NSNumber numberWithInt:0xed] ,
			@"-2 1/2" , [NSNumber numberWithInt:0xec] ,
			@"-2 2/3" , [NSNumber numberWithInt:0xeb] ,
			@"-3" , [NSNumber numberWithInt:0xe8] ,
            @"-3 1/3" , [NSNumber numberWithInt:0xe5] ,
            @"-3 1/2" , [NSNumber numberWithInt:0xe4] ,
            @"-3 2/3" , [NSNumber numberWithInt:0xe3] ,
            @"-4" , [NSNumber numberWithInt:0xe0] ,
            @"-4 1/3" , [NSNumber numberWithInt:0xdd] ,
            @"-4 1/2" , [NSNumber numberWithInt:0xdc] ,
            @"-4 2/3" , [NSNumber numberWithInt:0xdb] ,
            @"-5" , [NSNumber numberWithInt:0xd8] ,

			@"unknown" , [NSNumber numberWithInt:0xffffffff] , nil ];
}

@end
