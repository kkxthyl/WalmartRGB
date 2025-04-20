/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : ActionEdsRef.m                                                  *
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


#import "ActionEdsRef.h"


@implementation ActionEdsRef

-(id)initWithRef:(EdsBaseRef)ref
{
	[super init ];
	
	_ref = ref;
	return self;
}

-(EdsBaseRef)getRef
{
	return _ref;
}

-(void)dealloc
{
	if(_ref != NULL)
	{
//		EdsRelease(_ref);
		_ref = NULL;
	}
	
	[super dealloc];
}

@end
