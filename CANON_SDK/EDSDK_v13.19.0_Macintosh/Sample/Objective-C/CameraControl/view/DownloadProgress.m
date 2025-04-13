/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : DownloadProgress.m                                              *
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

#import "DownloadProgress.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface DownloadProgress (Local)
@end


@implementation DownloadProgress

- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	[self setMinValue:0];
	[self setMaxValue:100];
	[self setUsesThreadedAnimation:NO];
	[self setIndeterminate:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)update:(NSNotification *)notification
{
	CameraEvent * event;
	NSDictionary* dict = [notification userInfo];
	NSString * command;
	EdsUInt32 value;
	
	event = [dict objectForKey:@"event"];
	if(event == nil)
	{
		return ;
	}

	command = [event getEvent];
	if([command isEqualToString:@"DownloadStart"])
	{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDoubleValue:[self minValue]];
            [self startAnimation:self];
        });
	}
	
	if([command isEqualToString:@"DownloadCompleted"])
	{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDoubleValue:[self maxValue]];
            [self stopAnimation:self];
            [self setDoubleValue:[self minValue]];
        });
	}
	
	if([command isEqualToString:@"ProgressReport"])
	{
		value = [[event getArg] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDoubleValue:value];
        });
	}
	
}

@end

@implementation DownloadProgress (Local)

@end
