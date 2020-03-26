using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData.Classes
{
    public class Message
    {
        public int MessageID { get; set; }
        public string Subject { get; set; }
        public string Text { get; set; }
        public List<MessageUser> Recipients { get; set; }
        public bool Sent { get; set; }

        public Message()
        {
            Recipients = new List<MessageUser>();
        }
    }
}
