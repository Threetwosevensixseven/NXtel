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
            DBOps.ConnectionString = new Settings(HttpContext.Current.Server.MapPath("~/App_Data")).Load().ConnectionString;
            SQL.UpdateStructure();
            SQL.PopulateDummyTable();
            ServerStatus.StartIfStopped();
            ConfigureAuth(app);
        }
    }
}
