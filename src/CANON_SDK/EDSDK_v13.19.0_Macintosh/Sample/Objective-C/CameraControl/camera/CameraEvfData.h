/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraEvfData.h                                                 *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2007-2008 All Rights Reserved                        *
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

@interface CameraEvfData : NSObject {
	EdsStreamRef _stream;			// JPEG stream
	EdsUInt32 _zoom;
	EdsRect _zoomRect;
	EdsPoint _zoomPosition;
	EdsPoint _imagePosition;
	EdsUInt32 _histogram[ 256 * 4]; // YRGB (YRGBYRGBYRGBYRGB....)
	EdsSize _sizeJpeglarge;
}

-(void)setStream:(EdsStreamRef)stream;
-(void)setZoom:(EdsInt32)zoom;
-(void)setZoomRect:(EdsRect)zoomRect;
-(void)setZoomPosition:(EdsPoint)zoomPosition;
-(void)setImagePosition:(EdsPoint)imagePosition;
-(void)setHistogram:(EdsUInt32 *)histogram;
-(void)setSizeJpeglarge:(EdsSize)sizeJpeglarge;

-(EdsStreamRef)stream;
-(EdsUInt32)zoom;
-(EdsRect)zoomRect;
-(EdsPoint)zoomPosition;
-(EdsPoint)imgaePosition;
-(EdsUInt32*)histogram;
-(EdsSize)sizeJpeglarge;

@end
