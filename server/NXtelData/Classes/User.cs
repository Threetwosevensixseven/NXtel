using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class User
    {
        public string ID { get; set; }
        public List<string> Roles { get; set; }
        public string Email { get; set; }
        public bool EmailConfirmed { get; set; }
        public string Mailbox { get; set; }

        public User()
        {
            ID = Email = Mailbox = "";
            Roles = new List<string>();
        }

        public bool IsAdmin
        {
            get
            {
                return Roles.Any(r => r == "Admin");
            }
        }

        public bool IsPageEditor
        {
            get
            {
                return Roles.Any(r => r == "PageEditor");
            }
        }
    }
}
