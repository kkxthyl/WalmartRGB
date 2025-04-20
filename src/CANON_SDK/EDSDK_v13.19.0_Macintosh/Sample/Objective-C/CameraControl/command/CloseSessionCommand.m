/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CloseSessionCommand.h                                           *
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


#import "CloseSessionCommand.h"


@implementation CloseSessionCommand
//Execute command
-(BOOL)execute
{

	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;

	if([_model camera] != NULL)
	{
		//The communication with the camera is ended
		error = EdsCloseSession([_model camera]);
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt: error];
		event = [[CameraEvent alloc] init:@"error" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];
	}
	
	return YES;
}

@end
