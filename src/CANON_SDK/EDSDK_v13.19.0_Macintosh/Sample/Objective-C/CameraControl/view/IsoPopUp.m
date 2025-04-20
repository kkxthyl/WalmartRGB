/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : IsoPopUp.m                                                      *
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


#import "IsoPopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface IsoPopUp (Local)
-(void)initializeData;
@end

@implementation IsoPopUp
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
		if([number intValue] == kEdsPropID_ISOSpeed)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_ISOSpeed)
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

@implementation IsoPopUp (Local)

-(void)initializeData
{
	[self removeAllItems];
	
	// List of value and display name
	_propertyList = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"Auto", [NSNumber numberWithInt:0x00] ,
            @"6" , [NSNumber numberWithInt:0x28] ,
            @"12" , [NSNumber numberWithInt:0x30] ,
            @"25" , [NSNumber numberWithInt:0x38] ,
            @"50" , [NSNumber numberWithInt:0x40] ,
            @"100" , [NSNumber numberWithInt:0x48] ,
            @"125" , [NSNumber numberWithInt:0x4b] ,
            @"160" , [NSNumber numberWithInt:0x4d] ,
            @"200" , [NSNumber numberWithInt:0x50] ,
            @"250" , [NSNumber numberWithInt:0x53] ,
            @"320" , [NSNumber numberWithInt:0x55] ,
            @"400" , [NSNumber numberWithInt:0x58] ,
            @"500" , [NSNumber numberWithInt:0x5b] ,
            @"640" , [NSNumber numberWithInt:0x5d] ,
            @"800" , [NSNumber numberWithInt:0x60] ,
            @"1000" , [NSNumber numberWithInt:0x63] ,
            @"1250" , [NSNumber numberWithInt:0x65] ,
            @"1600" , [NSNumber numberWithInt:0x68] ,
            @"2000" , [NSNumber numberWithInt:0x6b] ,
            @"2500" , [NSNumber numberWithInt:0x6d] ,
            @"3200" , [NSNumber numberWithInt:0x70] ,
            @"4000" , [NSNumber numberWithInt:0x73] ,
            @"5000" , [NSNumber numberWithInt:0x75] ,
            @"6400" , [NSNumber numberWithInt:0x78] ,
            @"8000" , [NSNumber numberWithInt:0x7b] ,
            @"10000" , [NSNumber numberWithInt:0x7d] ,
            @"12800" , [NSNumber numberWithInt:0x80] ,
            @"16000" , [NSNumber numberWithInt:0x83] ,
            @"20000" , [NSNumber numberWithInt:0x85] ,
            @"25600" , [NSNumber numberWithInt:0x88] ,
            @"32000" , [NSNumber numberWithInt:0x8b] ,
            @"40000" , [NSNumber numberWithInt:0x8d] ,
            @"51200" , [NSNumber numberWithInt:0x90] ,
            @"64000" , [NSNumber numberWithInt:0x93] ,
            @"80000" , [NSNumber numberWithInt:0x95] ,
            @"102400" , [NSNumber numberWithInt:0x98] ,
            @"204800" , [NSNumber numberWithInt:0xa0] ,
            @"409600" , [NSNumber numberWithInt:0xa8] ,
            @"819200" , [NSNumber numberWithInt:0xb0] ,
            @"unknown" , [NSNumber numberWithInt:0xffffffff] , nil];

}


@end 

