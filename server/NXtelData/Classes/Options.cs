using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public static class Options
    {
        public static int UpdateFeedMins
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["UpdateFeedMins"] ?? "").Trim();
                int val;
                int.TryParse(cfg, out val);
                if (val <= 0)
                    val = 10;
                return val;
            }
        }
    }
}
