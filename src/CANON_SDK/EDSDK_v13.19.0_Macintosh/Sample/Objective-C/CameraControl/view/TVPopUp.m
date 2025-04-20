/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : TVPopUp.h                                                       *
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

#import "TVPopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface TVPopUp (Local)
-(void)initializeData;
@end

@implementation TVPopUp
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
		if([number intValue] == kEdsPropID_Tv)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_Tv)
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

@implementation TVPopUp (Local)

-(void)initializeData
{
	[self removeAllItems];
	
	// List of value and display name
	_propertyList = [[ NSDictionary alloc] initWithObjectsAndKeys : 
            @"Auto" , [NSNumber numberWithInt:0x04] ,
			@"Bulb" , [NSNumber numberWithInt:0x0c] ,
			@"30''" , [NSNumber numberWithInt:0x10] , 
			@"25''" , [NSNumber numberWithInt:0x13] , 
			@"20''" , [NSNumber numberWithInt:0x14] , 
			@"20''" , [NSNumber numberWithInt:0x15] , 
			@"15''" , [NSNumber numberWithInt:0x18] , 
			@"13''" , [NSNumber numberWithInt:0x1B] , 
			@"10''" , [NSNumber numberWithInt:0x1C] , 
			@"10''" , [NSNumber numberWithInt:0x1D] , 
			@"8''" , [NSNumber numberWithInt:0x20] , 
			@"6''" , [NSNumber numberWithInt:0x23] , 
			@"6''" , [NSNumber numberWithInt:0x24] , 
			@"5''" , [NSNumber numberWithInt:0x25] , 
			@"4''" , [NSNumber numberWithInt:0x28] , 
			@"3''2" , [NSNumber numberWithInt:0x2B] , 
			@"3''" , [NSNumber numberWithInt:0x2C] , 
			@"2''5" , [NSNumber numberWithInt:0x2D] , 
			@"2''" , [NSNumber numberWithInt:0x30] , 
			@"1''6" , [NSNumber numberWithInt:0x33] , 
			@"1''5" , [NSNumber numberWithInt:0x34] , 
			@"1''3" , [NSNumber numberWithInt:0x35] , 
			@"1''" , [NSNumber numberWithInt:0x38] , 
			@"0''8" , [NSNumber numberWithInt:0x3B] , 
			@"0''7" , [NSNumber numberWithInt:0x3C] , 
			@"0''6" , [NSNumber numberWithInt:0x3D] , 
			@"0''5" , [NSNumber numberWithInt:0x40] , 
			@"0''4" , [NSNumber numberWithInt:0x43] , 
			@"0''3" , [NSNumber numberWithInt:0x44] , 
			@"0''3" , [NSNumber numberWithInt:0x45] , 
			@"4" , [NSNumber numberWithInt:0x48] , 
			@"5" , [NSNumber numberWithInt:0x4B] , 
			@"6" , [NSNumber numberWithInt:0x4C] ,
			@"6" , [NSNumber numberWithInt:0x4D] ,
			@"8" , [NSNumber numberWithInt:0x50] ,
			@"10" , [NSNumber numberWithInt:0x53] ,
			@"10" , [NSNumber numberWithInt:0x54] ,
			@"13" , [NSNumber numberWithInt:0x55] ,
			@"15" , [NSNumber numberWithInt:0x58] ,
			@"20" , [NSNumber numberWithInt:0x5B] ,
			@"20" , [NSNumber numberWithInt:0x5C] ,
			@"25" , [NSNumber numberWithInt:0x5D] ,
			@"30" , [NSNumber numberWithInt:0x60] ,
			@"40" , [NSNumber numberWithInt:0x63] ,
			@"45" , [NSNumber numberWithInt:0x64] ,
			@"50" , [NSNumber numberWithInt:0x65] ,
			@"60" , [NSNumber numberWithInt:0x68] ,
			@"80" , [NSNumber numberWithInt:0x6B] ,
			@"90" , [NSNumber numberWithInt:0x6C] ,
			@"100" , [NSNumber numberWithInt:0x6D] ,
			@"125" , [NSNumber numberWithInt:0x70] ,
			@"160" , [NSNumber numberWithInt:0x73] ,
			@"180" , [NSNumber numberWithInt:0x74] ,
			@"200" , [NSNumber numberWithInt:0x75] ,
			@"250" , [NSNumber numberWithInt:0x78] ,
			@"320" , [NSNumber numberWithInt:0x7B] ,
			@"350" , [NSNumber numberWithInt:0x7C] ,
			@"400" , [NSNumber numberWithInt:0x7D] ,
			@"500" , [NSNumber numberWithInt:0x80] ,
			@"640" , [NSNumber numberWithInt:0x83] ,
			@"750" , [NSNumber numberWithInt:0x84] ,
			@"800" , [NSNumber numberWithInt:0x85] ,
			@"1000" , [NSNumber numberWithInt:0x88] ,
			@"1250" , [NSNumber numberWithInt:0x8B] ,
			@"1500" , [NSNumber numberWithInt:0x8C] ,
			@"1600" , [NSNumber numberWithInt:0x8D] ,
			@"2000" , [NSNumber numberWithInt:0x90] ,
			@"2500" , [NSNumber numberWithInt:0x93] ,
			@"3000" , [NSNumber numberWithInt:0x94] ,
			@"3200" , [NSNumber numberWithInt:0x95] ,
			@"4000" , [NSNumber numberWithInt:0x98] ,
			@"5000" , [NSNumber numberWithInt:0x9B] ,
			@"6000" , [NSNumber numberWithInt:0x9C] ,
			@"6400" , [NSNumber numberWithInt:0x9D] ,
			@"8000" , [NSNumber numberWithInt:0xA0] , 
			@"unknown" , [NSNumber numberWithInt:0xffffffff] , nil];
}

@end
