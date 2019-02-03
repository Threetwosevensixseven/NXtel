using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Hosting;

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

        public static int StartPageNo
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

        public static string MainIndexPage
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["MainIndexPage"] ?? "").Trim().ToLower();
                return cfg;
            }
        }

        public static int MainIndexPageNo
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["MainIndexPage"] ?? "").Trim();
                cfg = Regex.Replace(cfg, @"^(\d+).*$", "$1");
                int val;
                int.TryParse(cfg, out val);
                if (val < 0) val = 0;
                return val;
            }
        }

        public static int MainIndexFrameNo
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["MainIndexPage"] ?? "").Trim();
                byte frame = Convert.ToByte((Regex.Replace(cfg, @"^\d+([a-z]).*$", "$1") + "0")[0]);
                return frame - 97;
            }
        }

        private static int? _mainIndexPageID = null;
        public static int MainIndexPageID
        {
            get
            {
                if (_mainIndexPageID == null)
                    _mainIndexPageID = Page.GetPageID(MainIndexPageNo, MainIndexFrameNo);
                return (int)_mainIndexPageID;
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

        public static int PageCacheDurationMins
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["PageCacheDurationMins"] ?? "").Trim();
                int val;
                int.TryParse(cfg, out val);
                if (val <= 0)
                    val = 5;
                return val;
            }
        }
        public static string ContentHelpDirectory
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["ContentHelpDirectory"] ?? "").Trim();
                return cfg;
            }
        }

        public static string ExternalWikiDirectory
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["ExternalWikiDirectory"] ?? "").Trim();
                return cfg;
            }
        }

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

        private static bool? _usePrestelCharSet;
        public static bool UsePrestelCharSet
        {
            get
            {
                if (_usePrestelCharSet == null)
                {
                    string cfg = (ConfigurationManager.AppSettings["UsePrestelCharSet"] ?? "").Trim().ToLower();
                    _usePrestelCharSet = (cfg == "true");
                }
                return (bool)_usePrestelCharSet;
            }
        }

        public static byte? _prestelCharSetModifier;
        public static byte PrestelCharSetModifier
        {
            get
            {
                if (_prestelCharSetModifier == null)
                {
                    _prestelCharSetModifier = Convert.ToByte(UsePrestelCharSet ? 0xC0 : 0x80);
                }
                return (byte)_prestelCharSetModifier;
            }
        }

        private static bool? _trimSpaces;
        public static bool TrimSpaces
        {
            get
            {
                if (_trimSpaces == null)
                {
                    string cfg = (ConfigurationManager.AppSettings["TrimSpaces"] ?? "").Trim().ToLower();
                    _trimSpaces = (cfg == "true");
                }
                return (bool)_trimSpaces;
            }
        }

        public static string KeepAliveGUID
        {
            get
            {
                string cfg = (ConfigurationManager.AppSettings["KeepAliveGUID"] ?? "").ToLower().Replace("-", "").Trim();
                return cfg;
            }
        }

        private static bool? _testTheme;
        public static bool TestTheme
        {
            get
            {
                if (_testTheme == null)
                {
                    string cfg = (ConfigurationManager.AppSettings["TestTheme"] ?? "").Trim().ToLower();
                    _testTheme = (cfg == "true");
                }
                return (bool)_testTheme;
            }
        }

        public static string CharSetName
        {
            get
            {
                return UsePrestelCharSet ? "Prestel" : "Teletext";
            }
        }
    }
}
