/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraEventListener.h                                           *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2007-2008 All Rights Reserved                             *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/


#import <Cocoa/Cocoa.h>
#import "EDSDK.h"

@interface CameraEventListener : NSObject {

}

@end

EdsError EDSCALLBACK handleObjectEvent( EdsUInt32 inEvent, EdsBaseRef inRef, EdsVoid * inContext);
EdsError EDSCALLBACK handlePropertyEvent( EdsUInt32 inEvent, EdsUInt32 inPropertyID ,EdsUInt32 inParam, EdsVoid * inContext);
EdsError EDSCALLBACK handleStateEvent( EdsUInt32 inEvent, EdsUInt32 inParam, EdsVoid * inContext);
