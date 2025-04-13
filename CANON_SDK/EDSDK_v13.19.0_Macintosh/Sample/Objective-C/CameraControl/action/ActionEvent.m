/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : ActionEvent.m                                                   *
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


#import "ActionEvent.h"


@implementation ActionEvent

-(id)init:(NSString *)command withArgument:(id)object
{
	[super init];
	
	_command = [command retain];
	_object = [object retain];
	return self;
}

-(void)dealloc
{
	[_object release];
	[_command release];
	[super dealloc];
}

-(NSString *)getActionCommand
{
	return _command;
}

-(id)getArg
{
	return _object;
}

@end
