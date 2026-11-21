using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Configuration;

namespace NXtelData
{
    public static partial class Options
    {
        private static IConfiguration _configuration;
        public static IConfiguration Configuration
        {
            get
            {
                if (_configuration == null)
                    _configuration = LoadConfiguration(AppContext.BaseDirectory);
                return _configuration;
            }
        }

        public static IConfiguration LoadConfiguration(string AppDir)
        {
            return new ConfigurationBuilder()
                .SetBasePath(AppDir)
                .AddJsonFile("appsettings.json", true)
                .AddEnvironmentVariables()
                .Build();
        }

        public static int TCPListeningPort
        {
            get
            {
                string cfg = (Configuration["TCPListeningPort"] ?? "").Trim();
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
                string cfg = (Configuration["UpdateFeedMins"] ?? "").Trim();
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
                string cfg = (Configuration["StartPage"] ?? "").Trim().ToLower();
                return cfg;
            }
        }

        public static int StartPageNo
        {
            get
            {
                string cfg = (Configuration["StartPage"] ?? "").Trim();
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
                string cfg = (Configuration["StartPage"] ?? "").Trim();
                byte frame = Convert.ToByte((Regex.Replace(cfg, @"^\d+([a-z]).*$", "$1") + "0")[0]);
                return frame - 97;
            }
        }

        public static string MainIndexPage
        {
            get
            {
                string cfg = (Configuration["MainIndexPage"] ?? "").Trim().ToLower();
                return cfg;
            }
        }

        public static int MainIndexPageNo
        {
            get
            {
                string cfg = (Configuration["MainIndexPage"] ?? "").Trim();
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
                string cfg = (Configuration["MainIndexPage"] ?? "").Trim();
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
                string cfg = (Configuration["ServerLocation"] ?? "").Trim();
                return cfg;
            }
        }

        public static string LogFile
        {
            get
            {
                string cfg = (Configuration["LogFile"] ?? "").Trim();
                return cfg;
            }
        }

        public static bool UpdateSQL
        {
            get
            {
                string cfg = (Configuration["UpdateSQL"] ?? "").Trim().ToLower();
                return cfg == "true";
            }
        }

        public static string TelesoftFile
        {
            get
            {
                string cfg = (Configuration["TelesoftFile"] ?? "").Trim();
                return cfg;
            }
        }

        public static int PageCacheDurationMins
        {
            get
            {
                string cfg = (Configuration["PageCacheDurationMins"] ?? "").Trim();
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
                string cfg = (Configuration["ContentHelpDirectory"] ?? "").Trim();
                return cfg;
            }
        }

        public static string ExternalWikiDirectory
        {
            get
            {
                string cfg = (Configuration["ExternalWikiDirectory"] ?? "").Trim();
                return cfg;
            }
        }

        public static string DbBackupDirectory
        {
            get
            {
                string cfg = (Configuration["DbBackupDirectory"] ?? "").Trim();
                if (cfg.StartsWith("~"))
                    cfg = Path.Combine(AppContext.BaseDirectory, cfg.TrimStart('~', '/'));
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
                    string cfg = (Configuration["UsePrestelCharSet"] ?? "").Trim().ToLower();
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
                    string cfg = (Configuration["TrimSpaces"] ?? "").Trim().ToLower();
                    _trimSpaces = (cfg == "true");
                }
                return (bool)_trimSpaces;
            }
        }

        public static string KeepAliveGUID
        {
            get
            {
                string cfg = (Configuration["KeepAliveGUID"] ?? "").ToLower().Replace("-", "").Trim();
                return cfg;
            }
        }

        private static EnvironmentNames? _environment;
        public static EnvironmentNames Environment
        {
            get
            {
                if (_environment == null)
                {
                    bool match = false;
                    string cfg = (Configuration["Environment"] ?? "").Trim().ToLower();
                    foreach (EnvironmentNames env in EnvironmentNames.Prod.GetList())
                    {
                        if (cfg == env.ToString().ToLower())
                        {
                            _environment = env;
                            match = true;
                            break;
                        }
                    }
                    if (!match)
                        _environment = EnvironmentNames.Prod;
                }
                return (EnvironmentNames)_environment;
            }
        }

        private static string _appName;
        public static string AppName
        {
            get
            {
                if (_appName == null)
                    _appName = (ProductName + " " + NXtelData.EnumExtensions.GetDescription(NXtelData.Options.Environment)).Trim();
                return _appName;
            }
        }

        private static string _productName;
        public static string ProductName
        {
            get
            {
                if (_productName == null)
                    _productName = (Configuration["ProductName"] ?? "").Trim();
                return _productName;
            }
        }

        public static string CharSetName
        {
            get
            {
                return UsePrestelCharSet ? "Prestel" : "Teletext";
            }
        }

        private static bool? _showStaticTimeAndDate;
        public static bool ShowStaticTimeAndDate
        {
            get
            {
                if (_showStaticTimeAndDate == null)
                {
                    string cfg = (Configuration["ShowStaticTimeAndDate"] ?? "").Trim().ToLower();
                    _showStaticTimeAndDate = (cfg == "true");
                }
                return (bool)_showStaticTimeAndDate;
            }
        }

        private static bool? _enableInputParserLogging;
        public static bool EnableInputParserLogging
        {
            get
            {
                if (_enableInputParserLogging == null)
                {
                    string cfg = (Configuration["EnableInputParserLogging"] ?? "").Trim().ToLower();
                    _enableInputParserLogging = (cfg == "true");
                }
                return (bool)_enableInputParserLogging;
            }
        }

        public static int IACTimeoutMillisecs
        {
            get
            {
                string cfg = (Configuration["IACTimeoutMillisecs"] ?? "").Trim();
                int val;
                int.TryParse(cfg, out val);
                if (val <= 0)
                    val = 1000;
                return val;
            }
        }

        private static bool? _iACEnabled;
        public static bool IACEnabled
        {
            get
            {
                if (_iACEnabled == null)
                {
                    string cfg = (Configuration["IACEnabled"] ?? "").Trim().ToLower();
                    _iACEnabled = (cfg == "true");
                }
                return (bool)_iACEnabled;
            }
        }

        public static string HashSalt
        {
            get
            {
                string cfg = (Configuration["HashSalt"] ?? "").Trim();
                return cfg;
            }
        }

        public static string TimeZone
        {
            get
            {
                string cfg = (Configuration["TimeZone"] ?? "").Trim();
                return cfg;
            }
        }

        public static DateTime Now
        {
            get
            {
                if (TimeZone == "")
                    return DateTime.Now;
                return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.UtcNow, TimeZone);
            }
        }

        public static DateTime ToLocal(DateTime ServerTime)
        {
            if (TimeZone == "")
                return ServerTime;
            return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(DateTime.SpecifyKind(ServerTime, DateTimeKind.Local), TimeZone);
        }

        public static string GeoEndpoint
        {
            get
            {
                string cfg = (Configuration["GeoEndpoint"] ?? "").Trim();
                return cfg;
            }
        }

        public static int GeoRequestsPerMinute
        {
            get
            {
                string cfg = (Configuration["GeoRequestsPerMinute"] ?? "").Trim();
                int val;
                int.TryParse(cfg, out val);
                if (val <= 0)
                    val = 175;
                return val;
            }
        }

        public static int GeoRequestDelayMillisecs
        {
            get
            {
                return Convert.ToInt32(Math.Round(60000m / Convert.ToDecimal(GeoRequestsPerMinute), 0));
            }
        }

        private static bool? _disablePermissions;
        public static bool DisablePermissions
        {
            get
            {
                if (_disablePermissions == null)
                {
                    string cfg = (Configuration["DisablePermissions"] ?? "").Trim().ToLower();
                    _disablePermissions = (cfg == "true");
                }
                return (bool)_disablePermissions;
            }
        }

        public static string AdminEmailAddress
        {
            get
            {
                string cfg = (Configuration["AdminEmailAddress"] ?? "").Trim();
                return cfg;
            }
        }

        public static List<string> AdminEmailBCCList
        {
            get
            {
                var rv = new List<string>();
                var cfg = (Configuration["AdminEmailBCC"] ?? "").Trim().Replace(";", ",").Split(',');
                foreach (string addr in cfg)
                    if (!string.IsNullOrWhiteSpace(addr))
                        rv.Add(addr.Trim());
                return rv;
            }
        }

        private static bool? _disableAccountRegistration;
        public static bool DisableAccountRegistration
        {
            get
            {
                if (_disableAccountRegistration == null)
                {
                    string cfg = (Configuration["DisableAccountRegistration"] ?? "").Trim().ToLower();
                    _disableAccountRegistration = (cfg == "true");
                }
                return (bool)_disableAccountRegistration;
            }
        }
    }
}
