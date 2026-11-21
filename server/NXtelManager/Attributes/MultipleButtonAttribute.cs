using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.ActionConstraints;
using Microsoft.AspNetCore.Routing;

namespace NXtelManager.Attributes
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public class MultipleButtonAttribute : ActionMethodSelectorAttribute
    {
        public string Name { get; set; }
        public string Argument { get; set; }

        public MultipleButtonAttribute(string Argument)
        {
            this.Argument = Argument;
            this.Name = "action";
        }

        public override bool IsValidForRequest(RouteContext routeContext, ActionDescriptor action)
        {
            var request = routeContext.HttpContext.Request;
            var keyValue = string.Format("{0}:{1}", Name, Argument);
            return request.HasFormContentType && request.Form.ContainsKey(keyValue);
        }
    }
}

namespace NXtelManager
{
    // A form posted with a submit button named "action:Name" runs the action Name of the same controller,
    // whatever action the form posted to. This rewrites the action segment of the path before routing.
    public class MultipleButtonMiddleware
    {
        private readonly RequestDelegate next;

        public MultipleButtonMiddleware(RequestDelegate next)
        {
            this.next = next;
        }

        public async Task Invoke(HttpContext context)
        {
            var request = context.Request;
            if (HttpMethods.IsPost(request.Method) && request.HasFormContentType)
            {
                var form = await request.ReadFormAsync();
                string key = form.Keys.FirstOrDefault(k => k.StartsWith("action:", StringComparison.OrdinalIgnoreCase));
                if (key != null)
                {
                    var parts = (request.Path.Value ?? "").Trim('/').Split('/').ToList();
                    if (parts.Count == 1 && parts[0] == "")
                        parts[0] = "Home";
                    string action = key.Substring("action:".Length);
                    if (parts.Count < 2)
                        parts.Add(action);
                    else
                        parts[1] = action;
                    request.Path = "/" + string.Join("/", parts);
                }
            }
            await next(context);
        }
    }
}
