using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Configuration;
using System.Web.Helpers;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace NXtelManager
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AntiForgeryConfig.SuppressXFrameOptionsHeader = true;
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        private static string _applicationVersion = null;
        public static string ApplicationVersion
        {
            get
            {
                if (_applicationVersion == null)
                {
                    var assy = GetWebEntryAssembly();
                    if (assy == null)
                        _applicationVersion = "1.0.2.0";
                    else
                        _applicationVersion = assy.GetName().Version.ToString().Replace("1.0.1.", "1.0.2.");
                }
                return _applicationVersion;
            }
        }

        private static Assembly GetWebEntryAssembly()
        {
            if (System.Web.HttpContext.Current == null ||
                System.Web.HttpContext.Current.ApplicationInstance == null)
            {
                return null;
            }

            var type = System.Web.HttpContext.Current.ApplicationInstance.GetType();
            while (type != null && type.Namespace == "ASP")
            {
                type = type.BaseType;
            }

            return type == null ? null : type.Assembly;
        }

        public void Application_PostRequestHandlerExecute(object sender, EventArgs e)
        {
            UpdateSessionCookieExpiration();
        }

        /// <summary>
        /// Updates session cookie's expiry date to be the expiry date of the session.
        /// </summary>
        /// <remarks>
        /// By default, the ASP.NET session cookie doesn't have an expiry date,
        /// which means that the cookie gets cleared after the browser is closed (unless the
        /// browser is set up to something like "Remember where you left off" setting).
        /// By setting the expiry date, we can keep the session cookie even after
        /// the browser is closed.
        /// </remarks>
        private void UpdateSessionCookieExpiration()
        {
            var httpContext = HttpContext.Current;
            var sessionState = httpContext?.Session;

            if (sessionState == null) return;

            var sessionStateSection = ConfigurationManager.GetSection("system.web/sessionState") as SessionStateSection;
            var sessionCookie = httpContext.Response.Cookies[sessionStateSection?.CookieName ?? "ASP.NET_SessionId"];

            if (sessionCookie == null) return;

            sessionCookie.Expires = DateTime.Now.AddMinutes(sessionState.Timeout);
            sessionCookie.HttpOnly = true;
            sessionCookie.Value = sessionState.SessionID;
        }
    }
}
