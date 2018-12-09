using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelData
{
    public static partial class DBOps
    {
        public static string ConnectionString { get; set; }

        public static string ConnectionStringBackup
        {
            get
            {
                var cs = (ConnectionString ?? "").Trim();
                if (cs.EndsWith(";"))
                    cs = cs.TrimEnd(';');
                if (!cs.Contains("charset="))
                    cs += ";charset=utf8;";
                if (cs.EndsWith(";"))
                    cs = cs.TrimEnd(';');
                if (!cs.Contains("convertzerodatetime="))
                    cs += ";convertzerodatetime=true;";
                if (!cs.EndsWith(";"))
                    cs = cs + ";";
                return cs;
            }
        }
    }
}
