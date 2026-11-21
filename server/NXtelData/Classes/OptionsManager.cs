using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Hosting;

namespace NXtelData
{
    public static partial class Options
    {
        public static string DbBackupDirectory
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["DbBackupDirectory"] ?? "").Trim();
                if (cfg.StartsWith("~"))
                    cfg = HostingEnvironment.MapPath(cfg);
                try
                {
                    if (!Directory.Exists(cfg))
                        Directory.CreateDirectory(cfg);
                }
                catch { }
                return cfg;
            }
        }
    }
}
