/*
 * Copyright (c) 2005-2016, BearWare.dk
 * 
 * Contact Information:
 *
 * Bjoern D. Rasmussen
 * Kirketoften 5
 * DK-8260 Viby J
 * Denmark
 * Email: contact@bearware.dk
 * Phone: +45 20 20 54 59
 * Web: http://www.bearware.dk
 *
 * This source code is part of the TeamTalk 5 SDK owned by
 * BearWare.dk. All copyright statements may not be removed 
 * or altered from any source distribution. If you use this
 * software in a product, an acknowledgment in the product 
 * documentation is required.
 *
 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using BearWare;

namespace TeamTalkApp.NET
{
    public partial class UserInfoDlg : Form
    {
        TeamTalk ttclient;
        int userid;
        public UserInfoDlg(TeamTalk tt, int userid)
        {
            ttclient = tt;
            InitializeComponent();
            this.userid = userid;
            UpdateUser();
        }

        void UpdateUser()
        {
            User user = new User();
            if (ttclient.GetUser(userid, ref user))
            {
                useridTextBox.Text = user.nUserID.ToString();
                nicknameTextBox.Text = user.szNickname;
                usernameTextBox.Text = user.szUsername;
                statusmodeTextBox.Text = user.nStatusMode.ToString();
                statusmsgTextBox.Text = user.szStatusMsg;
                usertypeTextBox.Text = (user.uUserType & UserType.USERTYPE_ADMIN) == UserType.USERTYPE_ADMIN ? "Admin" : "Default";
                versionTextBox.Text = user.uVersion.ToString();
            }
            UserStatistics stats = new UserStatistics();
            if (ttclient.GetUserStatistics(userid, ref stats))
            {
                audiolossTextBox.Text = String.Format("{0}/{1}", stats.nVoicePacketsLost, stats.nVoicePacketsRecv + stats.nVoicePacketsLost);
                videolossTextBox.Text = String.Format("{0}/{1}", stats.nVideoCaptureFramesLost, stats.nVideoCaptureFramesRecv + stats.nVideoCaptureFramesLost);
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            UpdateUser();
        }
    }
}
