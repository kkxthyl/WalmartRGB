/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : AVPopUp.m                                                       *
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


#import "AvPopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"


@interface AvPopUp (Local)
-(void)initializeData;
@end

@implementation AvPopUp

- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	
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
		if([number intValue] == kEdsPropID_Av)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_Av)
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

@implementation AvPopUp (Local)
-(void)initializeData
{
	[self removeAllItems];
	
	// List of value and display name
	_propertyList = [[NSDictionary alloc] initWithObjectsAndKeys:
			@"00" , [NSNumber numberWithInt:0x00] , 
			@"1" , [NSNumber numberWithInt:0x08] , 
			@"1.1" , [NSNumber numberWithInt:0x0B] , 
			@"1.2" , [NSNumber numberWithInt:0x0C] , 
			@"1.2" , [NSNumber numberWithInt:0x0D] , 
			@"1.4" , [NSNumber numberWithInt:0x10] , 
			@"1.6" , [NSNumber numberWithInt:0x13] , 
			@"1.8" , [NSNumber numberWithInt:0x14] , 	
			@"1.8" , [NSNumber numberWithInt:0x15] , 
			@"2" , [NSNumber numberWithInt:0x18] , 
			@"2.2" , [NSNumber numberWithInt:0x1B] , 
			@"2.5" , [NSNumber numberWithInt:0x1C] , 
			@"2.5" , [NSNumber numberWithInt:0x1D] , 
			@"2.8" , [NSNumber numberWithInt:0x20] , 
			@"3.2" , [NSNumber numberWithInt:0x23] , 
			@"3.5" , [NSNumber numberWithInt:0x24] , 
			@"3.5" , [NSNumber numberWithInt:0x25] , 
			@"4" , [NSNumber numberWithInt:0x28] , 
			@"4" , [NSNumber numberWithInt:0x2B] , 
			@"4.5" , [NSNumber numberWithInt:0x2C] , 
			@"5.0" , [NSNumber numberWithInt:0x2D] , 
			@"5.6" , [NSNumber numberWithInt:0x30] , 
			@"6.3" , [NSNumber numberWithInt:0x33] , 
			@"6.7" , [NSNumber numberWithInt:0x34] , 
			@"7.1" , [NSNumber numberWithInt:0x35] , 
			@"8" , [NSNumber numberWithInt:0x38] , 
			@"9" , [NSNumber numberWithInt:0x3B] , 
			@"9.5" , [NSNumber numberWithInt:0x3C] , 
			@"10" , [NSNumber numberWithInt:0x3D] , 
			@"11" , [NSNumber numberWithInt:0x40] , 
			@"13" , [NSNumber numberWithInt:0x43] , 
			@"13" , [NSNumber numberWithInt:0x44] , 
			@"14" , [NSNumber numberWithInt:0x45] , 
			@"16" , [NSNumber numberWithInt:0x48] , 
			@"18" , [NSNumber numberWithInt:0x4B] , 
			@"19" , [NSNumber numberWithInt:0x4C] , 
			@"20" , [NSNumber numberWithInt:0x4D] , 
			@"22" , [NSNumber numberWithInt:0x50] , 
			@"25" , [NSNumber numberWithInt:0x53] , 
			@"27" , [NSNumber numberWithInt:0x54] , 
			@"29" , [NSNumber numberWithInt:0x55] , 
			@"32" , [NSNumber numberWithInt:0x58] , 
			@"36" , [NSNumber numberWithInt:0x5B] , 
			@"38" , [NSNumber numberWithInt:0x5C] , 
			@"40" , [NSNumber numberWithInt:0x5D] , 
			@"45" , [NSNumber numberWithInt:0x60] , 
			@"51" , [NSNumber numberWithInt:0x63] , 
			@"54" , [NSNumber numberWithInt:0x64] , 
			@"57" , [NSNumber numberWithInt:0x65] , 
			@"64" , [NSNumber numberWithInt:0x68] , 
			@"72" , [NSNumber numberWithInt:0x6B] , 
			@"76" , [NSNumber numberWithInt:0x6C] , 
			@"80" , [NSNumber numberWithInt:0x6D] , 
			@"91" , [NSNumber numberWithInt:0x70] , 
            @"Auto" , [NSNumber numberWithInt:0xFF] ,
			@"unknown" , [NSNumber numberWithInt:0xffffffff ] , nil];
}
@end
