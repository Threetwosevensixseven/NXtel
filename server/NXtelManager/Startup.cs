using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(NXtelManager.Startup))]
namespace NXtelManager
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
