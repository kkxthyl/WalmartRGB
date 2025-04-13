/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : ImageQualityPopUp.m                                                   *
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

#import "ImageQualityPopUp.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

@interface ImageQualityPopUp (Local)
-(void)initializeData;
@end

@implementation ImageQualityPopUp
- (id)initWithCoder:(NSCoder *)decoder
{
	[super initWithCoder:decoder];
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
	[self initializeData];
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)update:(NSNotification *)notification
{
	CameraEvent * event;
	CameraModel * model = [notification object];
	NSDictionary* dict = [notification userInfo];
	NSString * command;
	NSNumber * number;
	
	event = [dict objectForKey:@"event"];
	if(event == nil)
	{
		return ;
	}

	command = [event getEvent];
	number = [event getArg];
	//Update property
	if([command isEqualToString:@"PropertyChanged"])
	{
		if([number intValue] == kEdsPropID_ImageQuality)
		{
			[self updateProperty:[model getPropertyUInt32:[number intValue]]];
		}
	}

	//Update of list that can set property
	if([command isEqualToString:@"PropertyDescChanged"])
	{
		if([number intValue] == kEdsPropID_ImageQuality)
		{
            dispatch_async(dispatch_get_main_queue(), ^{
                EdsPropertyDesc desc;
                desc = [model getPropertyDesc:[number intValue]];
                [self updatePropertyDesc:&desc];
            });
		}
	}
}

@end

@implementation ImageQualityPopUp (Local)

-(void)initializeData
{
	[self removeAllItems];
	
	// PTP Camera
	_propertyList = [[ NSDictionary alloc] initWithObjectsAndKeys : 
			@"RAW" ,		[NSNumber numberWithInt:EdsImageQuality_LR] , 
			@"RAW + Large Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRLJF] , 
			@"RAW + Large Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_LRLJN] , 
			@"RAW + Middle Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRMJF] , 
			@"RAW + Middle Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_LRMJN] , 
			@"RAW + Small Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRSJF] , 
			@"RAW + Small Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_LRSJN] , 
			@"RAW + Small1 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRS1JF] , 
			@"RAW + Small1 Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_LRS1JN] , 
			@"RAW + Small2 Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_LRS2JF] , 
			@"RAW + Small3 Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_LRS3JF] , 
					 
			@"RAW + Large Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRLJ] ,
            @"RAW + Middle Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_LRMJ] ,
			@"RAW + Middle1 Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRM1J] , 
			@"RAW + Middle2 Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRM2J] ,
            @"RAW + Small Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_LRSJ] ,
            @"RAW + Small1 Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_LRS1J] ,
			@"RAW + Small2 Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_LRS2J] ,
					 
			@"Middle RAW(Small RAW1)" ,	[NSNumber numberWithInt:EdsImageQuality_MR] ,
			@"Middle RAW(Small RAW1) + Large Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_MRLJF] , 
			@"Middle RAW(Small RAW1) + Middle Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_MRMJF] , 
			@"Middle RAW(Small RAW1) + Small Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_MRSJF] , 
			@"Middle RAW(Small RAW1) + Large Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_MRLJN] , 
			@"Middle RAW(Small RAW1) + Middle Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_MRMJN] , 
			@"Middle RAW(Small RAW1) + Small Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_MRSJN] , 
			@"Middle RAW + Small1 Fine Jpeg" ,					[NSNumber numberWithInt:EdsImageQuality_MRS1JF] , 
			@"Middle RAW + Small1 Normal Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_MRS1JN] , 
			@"Middle RAW + Small2 Jpeg" ,						[NSNumber numberWithInt:EdsImageQuality_MRS2JF] , 
			@"Middle RAW + Small3 Jpeg" ,						[NSNumber numberWithInt:EdsImageQuality_MRS3JF] , 
					 
			@"Middle RAW + Large Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_MRLJ] , 
			@"Middle RAW + Middle Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_MRM1J] , 
			@"Middle RAW + Middle Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_MRM2J] , 
			@"Middle RAW + Small Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_MRSJ] , 					 
					 
		    @"Small RAW(Small RAW2)" ,	[NSNumber numberWithInt:EdsImageQuality_SR] ,
			@"Small RAW(Small RAW2) + Large Fine Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRLJF] , 
			@"Small RAW(Small RAW2) + Middle Fine Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRMJF] , 
			@"Small RAW(Small RAW2) + Small Fine Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRSJF] , 
			@"Small RAW(Small RAW2) + Large Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRLJN] , 
			@"Small RAW(Small RAW2) + Middle Normal Jpeg" , [NSNumber numberWithInt:EdsImageQuality_SRMJN] , 
			@"Small RAW(Small RAW2) + Small Normal Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRSJN] , 					 
			@"Small RAW + Small1 Fine Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_SRS1JF] , 
			@"Small RAW + Small1 Normal Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_SRS1JN] , 
			@"Small RAW + Small2 Jpeg" ,					[NSNumber numberWithInt:EdsImageQuality_SRS2JF] , 
			@"Small RAW + Small3 Jpeg" ,					[NSNumber numberWithInt:EdsImageQuality_SRS3JF] , 
					 
			@"Small RAW + Large Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_SRLJ] , 
			@"Small RAW + Middle1 Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRM1J] , 
			@"Small RAW + Middle2 Jpeg" ,	[NSNumber numberWithInt:EdsImageQuality_SRM2J] , 
			@"Small RAW + Small Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_SRSJ] , 
					 
			@"Large Fine Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_LJF] , 
			@"Large Normal Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_LJN] , 
			@"Middle Fine Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_MJF] , 
			@"Middle Normal Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_MJN] , 
			@"Small Fine Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_SJF] , 
			@"Small Normal Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_SJN] , 
			@"Small1 Fine Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_S1JF] , 
			@"Small1 Normal Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_S1JN] , 
			@"Small2 Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_S2JF] , 
			@"Small3 Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_S3JF] , 
					 
			@"Large Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_LJ] , 
			@"Middle Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_MJ] ,
            @"Middle1 Jpeg" ,            [NSNumber numberWithInt:EdsImageQuality_M1J] ,
			@"Middle2 Jpeg" ,			[NSNumber numberWithInt:EdsImageQuality_M2J] , 
			@"Small Jpeg" ,				[NSNumber numberWithInt:EdsImageQuality_SJ] , 
            @"Small1 Jpeg" ,                [NSNumber numberWithInt:EdsImageQuality_S1J] ,
            @"Small2 Jpeg" ,                [NSNumber numberWithInt:EdsImageQuality_S2J] ,
            
            @"CRAW" ,		[NSNumber numberWithInt:EdsImageQuality_CR] ,
            @"CRAW + Large Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRLJF] ,
            @"CRAW + Middle Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRMJF] ,
            @"CRAW + Middle1 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM1JF] ,
            @"CRAW + Middle2 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM2JF] ,
            @"CRAW + Small Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRSJF] ,
            @"CRAW + Small1 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRS1JF] ,
            @"CRAW + Small2 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRS2JF] ,
            @"CRAW + Small3 Fine Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRS3JF] ,
            @"CRAW + Large Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRLJN] ,
            @"CRAW + Middle Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRMJN] ,
            @"CRAW + Middle1 Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM1JN] ,
            @"CRAW + Middle2 Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM2JN] ,
            @"CRAW + Small Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRSJN] ,
            @"CRAW + Small1 Normal Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRS1JN] ,
              
            @"CRAW + Large Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRLJ] ,
            @"CRAW + Middle Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_CRMJ] ,
            @"CRAW + Middle1 Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM1J] ,
            @"CRAW + Middle2 Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRM2J] ,
            @"CRAW + Small Jpeg" ,		[NSNumber numberWithInt:EdsImageQuality_CRSJ] ,
            @"CRAW + Small1 Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_CRS1J] ,
            @"CRAW + Small2 Jpeg" ,        [NSNumber numberWithInt:EdsImageQuality_CRS2J] ,
                     
            /* HEIF */
            @"HEIF Large" ,                     [NSNumber numberWithInt:EdsImageQuality_HEIFL] ,
            @"RAW  + HEIF Large" ,              [NSNumber numberWithInt:EdsImageQuality_RHEIFL] ,
            @"CRAW + HEIF Large" ,              [NSNumber numberWithInt:EdsImageQuality_CRHEIFL] ,

            @"HEIF Large Fine" ,                [NSNumber numberWithInt:EdsImageQuality_HEIFLF] ,
            @"HEIF Large Normal" ,              [NSNumber numberWithInt:EdsImageQuality_HEIFLN] ,
            @"HEIF Middle Fine" ,               [NSNumber numberWithInt:EdsImageQuality_HEIFMF] ,
            @"HEIF Middle Normal" ,             [NSNumber numberWithInt:EdsImageQuality_HEIFMN] ,
            @"HEIF Small1 Fine" ,               [NSNumber numberWithInt:EdsImageQuality_HEIFS1F] ,
            @"HEIF Small1 Normal" ,             [NSNumber numberWithInt:EdsImageQuality_HEIFS1N] ,
            @"HEIF Small2 Fine" ,               [NSNumber numberWithInt:EdsImageQuality_HEIFS2F] ,
            @"RAW + HEIF Large Fine" ,          [NSNumber numberWithInt:EdsImageQuality_RHEIFLF] ,
            @"RAW + HEIF Large Normal" ,        [NSNumber numberWithInt:EdsImageQuality_RHEIFLN] ,
            @"RAW + HEIF Middle Fine" ,         [NSNumber numberWithInt:EdsImageQuality_RHEIFMF] ,
            @"RAW + HEIF Middle Normal" ,       [NSNumber numberWithInt:EdsImageQuality_RHEIFMN] ,
            @"RAW + HEIF Small1 Fine" ,         [NSNumber numberWithInt:EdsImageQuality_RHEIFS1F] ,
            @"RAW + HEIF Small1 Normal" ,       [NSNumber numberWithInt:EdsImageQuality_RHEIFS1N] ,
            @"RAW + HEIF Small2 Fine" ,         [NSNumber numberWithInt:EdsImageQuality_RHEIFS2F] ,
            @"CRAW + HEIF Large Fine" ,         [NSNumber numberWithInt:EdsImageQuality_CRHEIFLF] ,
            @"CRAW + HEIF Large Normal" ,       [NSNumber numberWithInt:EdsImageQuality_CRHEIFLN] ,
            @"CRAW + HEIF Middle Fine" ,        [NSNumber numberWithInt:EdsImageQuality_CRHEIFMF] ,
            @"CRAW + HEIF Middle Normal" ,      [NSNumber numberWithInt:EdsImageQuality_CRHEIFMN] ,
            @"CRAW + HEIF Small1 Fine" ,        [NSNumber numberWithInt:EdsImageQuality_CRHEIFS1F] ,
            @"CRAW + HEIF Small1 Normal" ,      [NSNumber numberWithInt:EdsImageQuality_CRHEIFS1N] ,
            @"CRAW + HEIF Small2 Fine" ,        [NSNumber numberWithInt:EdsImageQuality_CRHEIFS2F] , nil];
}


@end
