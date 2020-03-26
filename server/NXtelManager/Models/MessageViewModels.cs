using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using NXtelData.Classes;

namespace NXtelManager.Models
{
    public class MessageComposeModel
    {
        public bool ToAllAdmins { get; set; }
        public bool ToAllEditors { get; set; }
        public bool ToAllUsers { get; set; }
        public Message Message { get; set; }
    }
}