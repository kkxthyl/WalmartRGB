/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : EVFAFModePopUp.m                                                 *
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
*   08-07-30    F-001        create first version.                            *
*                                                                             *
******************************************************************************/

#import "EVFAFModePopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface EVFAFModePopUp (Local)
-(void)initializeData;
@end

@implementation EVFAFModePopUp

- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	
	[self removeAllItems];
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
		if([number intValue] == kEdsPropID_Evf_AFMode)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_Evf_AFMode)
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

@implementation EVFAFModePopUp (Local)
-(void)initializeData
{
	// List of value and display name
	_propertyList = [[NSDictionary alloc] initWithObjectsAndKeys:
		@"Quick mode" , [NSNumber numberWithInt:0x00] ,
		@"1-point AF" , [NSNumber numberWithInt:0x01] ,
		@"Face+Tracking" , [NSNumber numberWithInt:0x02] ,
        @"FlexiZone - Multi" , [NSNumber numberWithInt:0x03] ,
        @"Zone AF" , [NSNumber numberWithInt:0x04] ,
        @"Expand AF area" , [NSNumber numberWithInt:0x05] ,
        @"Expand AF area: Around" , [NSNumber numberWithInt:0x06] ,
        @"Large Zone AF: Horizontal" , [NSNumber numberWithInt:0x07] ,
        @"Large Zone AF: Vertical" , [NSNumber numberWithInt:0x08] ,
        @"Spot AF" , [NSNumber numberWithInt:0x0a] ,
        @"Flexible Zone AF 1" , [NSNumber numberWithInt:0x0b] ,
        @"Flexible Zone AF 2" , [NSNumber numberWithInt:0x0c] ,
        @"Flexible Zone AF 3" , [NSNumber numberWithInt:0x0d] ,
        @"Whole area AF" , [NSNumber numberWithInt:0x0e] ,
		@"unknown" , [NSNumber numberWithInt:0xffffffff] , nil];
}
@end
