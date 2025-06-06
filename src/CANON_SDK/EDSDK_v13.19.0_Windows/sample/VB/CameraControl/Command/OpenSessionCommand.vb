'/******************************************************************************
'*                                                                             *
'*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
'*      NAME : OpenSessionCommand.vb                                           *
'*                                                                             *
'*   Description: This is the Sample code to show the usage of EDSDK.          *
'*                                                                             *
'*                                                                             *
'*******************************************************************************
'*                                                                             *
'*   Written and developed by Camera Design Dept.53                            *
'*   Copyright Canon Inc. 2006 All Rights Reserved                             *
'*                                                                             *
'*******************************************************************************
'*   File Update Information:                                                  *
'*     DATE      Identify    Comment                                           *
'*   -----------------------------------------------------------------------   *
'*   06-03-22    F-001        create first version.                            *
'*                                                                             *
'******************************************************************************/

Option Explicit On
Imports System.Runtime.InteropServices

Public Class OpenSessionCommand
    Inherits Command

    Public Sub New(ByVal model As CameraModel)
        MyBase.new(model)
    End Sub

    '// Execute a command.	
    Public Overrides Function execute() As Boolean

        Dim err As Integer = EDS_ERR_OK
        Dim locked As Boolean = False

        '// Open session with remote camera.
        err = EdsOpenSession(MyBase.model.getCameraObject())


        'Preservation ahead is set to PC
        If err = EDS_ERR_OK Then

            Dim saveTo As Integer = EdsSaveTo.kEdsSaveTo_Host
            err = EdsSetPropertyData(MyBase.model.getCameraObject(), kEdsPropID_SaveTo, 0, Marshal.SizeOf(saveTo), saveTo)

        End If



        If err = EDS_ERR_OK Then

            Dim capacity As EdsCapacity
            capacity.numberOfFreeClusters = &H7FFFFFFF
            capacity.bytesPerSector = &H1000
            capacity.reset = 1

            err = EdsSetCapacity(MyBase.model.getCameraObject(), capacity)

        End If




        'Notification of error
        If err < EDS_ERR_OK Then

            'CameraEvent e("error", &err);
            MyBase.model.notifyObservers(errr, err)

        End If


        Return True
    End Function

End Class
