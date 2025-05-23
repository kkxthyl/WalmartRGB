﻿/******************************************************************************
*                                                                             *
*   PROJECT : Eos Digital camera Software Development Kit EDSDK               *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Canon Inc.                                       *
*   Copyright Canon Inc. 2018 All Rights Reserved                             *
*                                                                             *
*******************************************************************************/

using System;

namespace CameraControl
{
    class SetRemoteShootingCommand : Command
    {
        private uint _parameter;

        public SetRemoteShootingCommand(ref CameraModel model, uint parameter) : base(ref model)
        {
            _parameter = parameter;
        }

        // Execute command	
        public override bool Execute()
        {
            uint outPropertyData;
            uint err = EDSDKLib.EDSDK.EdsGetPropertyData(_model.Camera, EDSDKLib.EDSDK.PropID_LensBarrelStatus, 0, out outPropertyData);
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK || outPropertyData == (uint)EDSDKLib.EDSDK.DcRemoteShootingMode.DcRemoteShootingModeStart)
            //if (err != EDSDKLib.EDSDK.EDS_ERR_OK || outPropertyData == _parameter)
            {
                return true;
            }

            err = EDSDKLib.EDSDK.EdsSendCommand(_model.Camera, EDSDKLib.EDSDK.CameraCommand_SetRemoteShootingMode, (int)_parameter);

            //Notification of error
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
            {
                // It retries it at device busy
                if (err == EDSDKLib.EDSDK.EDS_ERR_DEVICE_BUSY)
                {
                    CameraEvent e = new CameraEvent(CameraEvent.Type.DEVICE_BUSY, IntPtr.Zero);
                    _model.NotifyObservers(e);
                    return true;
                }
                else
                {
                    CameraEvent e = new CameraEvent(CameraEvent.Type.ERROR, (IntPtr)err);
                    _model.NotifyObservers(e);
                    return true;
                }
            }

            return true;
        }
    }
}
