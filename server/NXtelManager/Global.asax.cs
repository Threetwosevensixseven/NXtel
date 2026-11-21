using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace NXtelManager
{
    public class MvcApplication
    {
        private static string _applicationVersion = null;
        public static string ApplicationVersion
        {
            get
            {
                if (_applicationVersion == null)
                {
                    var assy = typeof(MvcApplication).Assembly;
                    if (assy == null)
                        _applicationVersion = "1.0.2.0";
                    else
                        _applicationVersion = assy.GetName().Version.ToString().Replace("1.0.1.", "1.0.2.");
                }
                return _applicationVersion;
            }
        }
    }
}
