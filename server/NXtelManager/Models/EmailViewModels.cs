using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NXtelManager.Models
{
    public class CallbackEmailModel
    {
        public HtmlString CallBackUrl { get; set; }
        public HtmlString Mailbox { get; set; }

        public CallbackEmailModel(string CallBackUrl, string Mailbox)
        {
            this.CallBackUrl = new HtmlString(CallBackUrl);
            this.Mailbox = new HtmlString(Mailbox ?? "");
        }
    }
}