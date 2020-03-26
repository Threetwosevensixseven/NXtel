using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData.Classes
{
    public class MessageUser
    {
        public int MessageUserID { get; set; }
        public int MessageID { get; set; }
        public int FromUserID { get; set; }
        public int ToUserID { get; set; }
        public bool ToAllAdmins { get; set; }
        public bool ToAllEditors { get; set; }
        public bool ToAllUsers { get; set; }
    }
}
