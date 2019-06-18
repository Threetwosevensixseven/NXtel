using System.Web;
using Microsoft.Owin;
using NXtelData;
using Owin;

[assembly: OwinStartupAttribute(typeof(NXtelManager.Startup))]
namespace NXtelManager
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            //new Settings(HttpContext.Current.Server.MapPath("~/App_Data")).Save();
            var settings = new Settings(HttpContext.Current.Server.MapPath("~/App_Data")).Load();
            DBOps.ConnectionString = settings.ConnectionString;
            DBOps.Settings = settings;
            SQL.UpdateStructure();
            SQL.SetupData();
            ServerStatus.StartIfStopped();
            ConfigureAuth(app);
        }
    }
}
