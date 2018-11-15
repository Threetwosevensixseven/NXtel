using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace NXtelData
{
    public static class Options
    {
        public static int TCPListeningPort
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["TCPListeningPort"] ?? "").Trim();
                int val;
                int.TryParse(cfg, out val);
                if (val <= 0)
                    val = 10;
                return val;
            }
        }

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

        public static string StartPage
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["StartPage"] ?? "").Trim().ToLower();
                return cfg;
            }
        }

        public static int  StartPageNo
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["StartPage"] ?? "").Trim();
                cfg = Regex.Replace(cfg, @"^(\d+).*$", "$1");
                int val;
                int.TryParse(cfg, out val);
                if (val < 0) val = 0;
                return val;
            }
        }

        public static int StartFrameNo
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["StartPage"] ?? "").Trim();
                byte frame = Convert.ToByte((Regex.Replace(cfg, @"^\d+([a-z]).*$", "$1") + "0")[0]);
                return frame - 97;
            }
        }

        public static string ServerLocation
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["ServerLocation"] ?? "").Trim();
                return cfg;
            }
        }

        public static string LogFile
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["LogFile"] ?? "").Trim();
                return cfg;
            }
        }

        public static bool UpdateSQL
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["UpdateSQL"] ?? "").Trim().ToLower();
                return cfg == "true";
            }
        }

        public static string TelesoftFile
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["TelesoftFile"] ?? "").Trim();
                return cfg;
            }
        }

    }
}
