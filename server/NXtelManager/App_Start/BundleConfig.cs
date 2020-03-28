using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Optimization;
using NXtelData;

namespace NXtelManager
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/datatables.min.js",
                        "~/Scripts/bootstrap-multiselect.js",
                        "~/Scripts/bootstrap-autocomplete.min.js",
                        "~/Scripts/natural.js",
                        "~/Scripts/utility.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            var files = new List<string>();
            files.Add("~/Content/bootstrap.css");
            string vir = "~/Content/bootstrap-" + Options.Environment.ToString().ToLower() + ".css";
            string abs = HttpContext.Current.Server.MapPath(vir);
            if (File.Exists(abs)) files.Add(vir);
            files.Add("~/Content/datatables.min.css");
            files.Add("~/Content/bootstrap-multiselect.css");
            files.Add("~/Content/site.css");
            bundles.Add(new StyleBundle("~/Content/css").Include(files.ToArray()));
        }
    }
}
