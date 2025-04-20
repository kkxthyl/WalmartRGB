/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraCommand.m                                                 *
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

#import "cameraCommand.h"

@implementation CameraCommand

-(id)initWithCameraModel:(CameraModel *)model
{
	[super init];
	
	_model = [model retain];
	
	return self;
}

-(void)dealloc
{
	[_model release];
	[super dealloc];
}

-(CameraModel *)cameraModel
{
	return _model;
}

-(BOOL)execute
{
	BOOL ret = YES;
	
	return ret;
}

@end
