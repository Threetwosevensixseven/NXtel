using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Html;
using Microsoft.Extensions.FileProviders;
using NXtelData;

namespace NXtelManager
{
    // The bundles are served as separate static files, one tag per file.
    public class BundleConfig
    {
        public static readonly Dictionary<string, List<string>> Bundles = new Dictionary<string, List<string>>();

        public static void RegisterBundles(Dictionary<string, List<string>> bundles)
        {
            bundles.Add("~/bundles/jquery", Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/datatables.min.js",
                        "~/Scripts/bootstrap-multiselect.js",
                        "~/Scripts/bootstrap-autocomplete.min.js",
                        "~/Scripts/bootstrap-datepicker.min.js",
                        "~/Scripts/moment.min.js",
                        "~/Scripts/datetime-moment.js",
                        "~/Scripts/natural.js",
                        "~/Scripts/utility.js"));

            bundles.Add("~/bundles/jqueryval", Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add("~/bundles/modernizr", Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add("~/bundles/bootstrap", Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            var files = new List<string>();
            files.Add("~/Content/bootstrap.css");
            string vir = "~/Content/bootstrap-" + Options.Environment.ToString().ToLower() + ".css";
            if (Find(vir) != null) files.Add(vir);
            files.Add("~/Content/datatables.min.css");
            files.Add("~/Content/bootstrap-multiselect.css");
            files.Add("~/Content/bootstrap-datepicker.css");
            files.Add("~/Content/site.css");
            bundles.Add("~/Content/css", Include(files.ToArray()));
        }

        public static void UseStaticFiles(IApplicationBuilder app)
        {
            foreach (string dir in new[] { "Content", "Scripts", "fonts" })
            {
                app.UseStaticFiles(new StaticFileOptions
                {
                    FileProvider = new PhysicalFileProvider(Path.Combine(AppContext.BaseDirectory, dir)),
                    RequestPath = "/" + dir
                });
            }
        }

        // Expands {version} and * like System.Web.Optimization did, and matches file names without regard to case,
        // so each entry becomes the virtual path of a file that exists, in the case it has on disk.
        private static List<string> Include(params string[] virtualPaths)
        {
            var rv = new List<string>();
            foreach (string vir in virtualPaths)
            {
                string dir = Path.GetDirectoryName(vir.TrimStart('~', '/')).Replace('\\', '/');
                string pattern = Path.GetFileName(vir).Replace("{version}", "*");
                string abs = Path.Combine(AppContext.BaseDirectory, dir);
                if (!Directory.Exists(abs))
                    continue;
                foreach (string file in Directory.GetFiles(abs).Select(f => Path.GetFileName(f)).OrderBy(f => f, StringComparer.Ordinal))
                {
                    if (Regex.IsMatch(file, "^" + Regex.Escape(pattern).Replace("\\*", ".*") + "$",
                        RegexOptions.IgnoreCase)
                        && file.EndsWith(".min.js", StringComparison.OrdinalIgnoreCase) == pattern.EndsWith(".min.js", StringComparison.OrdinalIgnoreCase)
                        && !file.EndsWith(".intellisense.js", StringComparison.OrdinalIgnoreCase)
                        && !file.EndsWith("-vsdoc.js", StringComparison.OrdinalIgnoreCase)
                        && !file.EndsWith(".map", StringComparison.OrdinalIgnoreCase))
                        rv.Add("/" + dir + "/" + file);
                }
            }
            return rv;
        }

        private static string Find(string virtualPath)
        {
            return Include(virtualPath).FirstOrDefault();
        }
    }

    public static class Scripts
    {
        public static IHtmlContent Render(params string[] paths)
        {
            var sb = new StringBuilder();
            foreach (string path in paths)
                foreach (string file in BundleConfig.Bundles[path])
                    sb.Append("<script src=\"" + file + "\"></script>\r\n");
            return new HtmlString(sb.ToString());
        }
    }

    public static class Styles
    {
        public static IHtmlContent Render(params string[] paths)
        {
            var sb = new StringBuilder();
            foreach (string path in paths)
                foreach (string file in BundleConfig.Bundles[path])
                    sb.Append("<link href=\"" + file + "\" rel=\"stylesheet\"/>\r\n");
            return new HtmlString(sb.ToString());
        }
    }
}
