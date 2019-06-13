using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NXtelManager.Models
{
    public class CallbackEmailModel
    {
        public HtmlString CallBackUrl { get; set; }

        public CallbackEmailModel(string CallBackUrl)
        {
            this.CallBackUrl = new HtmlString(CallBackUrl);
        }
    }
}