/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : Thread.m                                                        *
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


#import "Thread.h"

@implementation Thread

-(id)init
{
	[super init];

	_isStop = NO;
	_isActive = NO;	
	_thread_lock = [[NSLock alloc] init];
		
	return self;
}

-(void)dealloc
{
	[_thread_lock release];
	[super dealloc];
}

-(BOOL)start
{
	[_thread_lock lock];
	
	_isStop = NO;

	[_thread_lock unlock];
	return YES;
}

-(void)stop
{
	[_thread_lock lock];

	_isStop = YES;
	
	[_thread_lock unlock];
}

-(void)run:(id)obj
{
	// process code
}

-(void)setActive:(BOOL)flag
{
	_isActive = flag;
}

-(void)threadProc:(id)param
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_isActive = YES;
	[self run:param];
	_isActive = NO;
	
	[pool release];
    [param release];

	[NSThread exit];
}

@end
