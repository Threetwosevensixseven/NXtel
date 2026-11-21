using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace NXtelManager.Controllers
{
    public class EmailController : ControllerBase
    {
        public static IServiceProvider Services { get; set; }

        public static string RenderViewToString(string controllerName, string viewName, object viewData)
        {
            using (var scope = Services.CreateScope())
            using (var writer = new StringWriter())
            {
                var httpContext = new DefaultHttpContext { RequestServices = scope.ServiceProvider };
                var routeData = new RouteData();
                routeData.Values.Add("controller", controllerName);
                var fakeControllerContext = new ActionContext(httpContext, routeData, new ActionDescriptor());
                var razorViewEngine = scope.ServiceProvider.GetRequiredService<IRazorViewEngine>();
                var razorViewResult = razorViewEngine.FindView(fakeControllerContext, viewName, false);
                var viewContext = new ViewContext(fakeControllerContext, razorViewResult.View,
                    new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary()) { Model = viewData },
                    new TempDataDictionary(httpContext, scope.ServiceProvider.GetRequiredService<ITempDataProvider>()), writer,
                    new HtmlHelperOptions());
                razorViewResult.View.RenderAsync(viewContext).GetAwaiter().GetResult();
                return writer.ToString();
            }
        }
    }
}
