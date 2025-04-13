/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraEvent.m                                                   *
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


#import "cameraEvent.h"


@implementation CameraEvent

-(id)init:(NSString *)event withArg:(id)arg
{
	[super init];
	_event = [event retain];
	_arg = [arg retain];

	return self;
}

-(void)dealloc
{
	[_event release];
	[_arg release];
	[super dealloc];
}

-(NSString *)getEvent
{
	return _event;
}

-(id)getArg;
{
	return _arg;
}

@end
