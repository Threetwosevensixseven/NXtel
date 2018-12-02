using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Hosting;

namespace NXtelData
{
    public class HelpItems : List<HelpItem>
    {
        public static HelpItems Load(bool LoadContent = false)
        { 
            var list = new List<HelpItem>();

            // Site Help
            foreach (var fileName in Directory.EnumerateFiles(HostingEnvironment.MapPath(@"~/SiteHelp/"), "*.md"))
            {
                var item = new HelpItem(fileName, LoadContent);
                list.Add(item);
            }

            // Content Help
            var path = Options.ContentHelpDirectory;
            if (path.StartsWith("~"))
                path = HostingEnvironment.MapPath(path);
            foreach (var fileName in Directory.EnumerateFiles(path, "*.md"))
            {
                var item = new HelpItem(fileName, LoadContent);
                list.Add(item);
            }

            // External Wiki
            path = Options.ExternalWikiDirectory;
            if (path.StartsWith("~"))
                path = HostingEnvironment.MapPath(path);
            foreach (var fileName in Directory.EnumerateFiles(path, "*.md"))
            {
                if (Path.GetFileName(fileName).ToLower() == "home.md")
                    continue;
                var item = new HelpItem(fileName, LoadContent);
                list.Add(item);
            }

            // Sort and return merged items
            var rv = new HelpItems();
            rv.AddRange(list.OrderBy(h => h.Title));
            return rv;
        }

        public static HelpItems Load(string Controller, string Action, bool LoadContent = false)
        {
            string prefix = (Controller ?? "").Trim() + (Action ?? "").Trim();
            var list = Load(LoadContent).Where(h => h.Slug.StartsWith(prefix));
            var rv = new HelpItems();
            rv.AddRange(Load(LoadContent).Where(h => h.Slug.StartsWith(prefix)));
            return rv;
        }
    }
}
