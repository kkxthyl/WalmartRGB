/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : OpenSessionCommand.m                                            *
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

#import "OpenSessionCommand.h"
#import "EDSDK.h"
#import "cameraEvent.h"
#include "GetPropertyCommand.h"
#include "GetPropertyDescCommand.h"

@implementation OpenSessionCommand

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	NSNumber * number;
	EdsUInt32 saveTo;
//	GetPropertyCommand * getPropertyCommand;
//	GetPropertyDescCommand * getPropertyDescCommand;

	//The communication with the camera begins
	error = EdsOpenSession([_model camera]);
	
    //Preservation ahead is set to PC
    if(error == EDS_ERR_OK)
    {
        saveTo = kEdsSaveTo_Host;
        error = EdsSetPropertyData([_model camera], kEdsPropID_SaveTo, 0, sizeof(saveTo) , &saveTo);
    }
		
			
    if(error == EDS_ERR_OK)
    {
        EdsCapacity capacity = {0x7FFFFFFF, 0x1000, 1};
        error = EdsSetCapacity([_model camera], capacity);
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
