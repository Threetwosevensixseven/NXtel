using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;

namespace NXtelManager
{
    public class RouteConfig
    {
        public static void RegisterRoutes(IEndpointRouteBuilder routes)
        {
            routes.MapControllerRoute(
                name: "Default",
                pattern: "{controller=Home}/{action=Index}/{id?}/{id2?}"
            );
        }
    }
}
