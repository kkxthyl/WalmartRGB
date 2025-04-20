/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : ActionButton.m                                                  *
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


#import "ActionButton.h"
#import "ActionEvent.h"

@implementation ActionButton

-(void)setActionCommand:(NSString *)actionCommand
{
	_actionCommand = [[NSString alloc] initWithString:actionCommand];
}

-(void)fireEvent
{
	ActionEvent *event;
	NSDictionary * dict;

	event = [[ActionEvent alloc] init:_actionCommand withArgument: nil];
	dict = [[NSDictionary alloc] initWithObjectsAndKeys: event, @"action_event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_PERFORMED_MESSAGE object:self userInfo:dict];
	[event release];
	[dict release];
}

-(void)dealloc
{
	[_actionCommand release];
	[super dealloc];
}

@end
