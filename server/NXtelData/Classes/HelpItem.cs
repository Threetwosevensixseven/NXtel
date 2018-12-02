using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Hosting;

namespace NXtelData
{
    public class HelpItem
    {
        public string Title { get; set; }
        public string FileName { get; set; }
        public string Slug { get; set; }
        public string Content { get; set; }
        public string HTML { get; set; }

        public HelpItem(string FileName, bool LoadContent = true)
        {
            this.FileName = (FileName ?? "").Trim();
            this.Slug = Path.GetFileNameWithoutExtension(this.FileName).Trim().Replace("-", "");
            this.Title = HelpItem.SplitCamelCase(this.Slug);
            if (LoadContent)
                Content = File.ReadAllText(FileName);
        }

        public string LoadContent()
        {
            if (Content == null)
                Content = File.ReadAllText(FileName);
            return Content;
        }

        public static string SplitCamelCase(string Text)
        {
            return Regex.Replace(
                Regex.Replace(
                    Text,
                    @"(\P{Ll})(\P{Ll}\p{Ll})",
                    "$1 $2"
                ),
                @"(\p{Ll})(\P{Ll})",
                "$1 $2"
            ).Replace("N Xtel", "NXtel");
        }

        public static byte[] LoadMedia(string FileName, string Extension)
        {
            byte[] file = null;
            if (string.IsNullOrWhiteSpace(FileName))
                return file;
            try
            {
                string path = Options.ContentHelpDirectory;
                if (path.StartsWith("~"))
                    path = HostingEnvironment.MapPath(path);
                path = Path.Combine(path, "media");
                string ext = (Extension ?? "").Trim();
                string fileName = Path.Combine(path, Path.GetFileNameWithoutExtension(FileName) + "." + ext);
                if (File.Exists(fileName))
                {
                    file = File.ReadAllBytes(fileName);
                    return file;
                }
            }
            catch { }
            try
            {
                string path = HostingEnvironment.MapPath(@"~/SiteHelp/media");
                string ext = (Extension ?? "").Trim();
                string fileName = Path.Combine(path, Path.GetFileNameWithoutExtension(FileName) + "." + ext);
                if (File.Exists(fileName))
                {
                    file = File.ReadAllBytes(fileName);
                    return file;
                }
            }
            catch { }
            return file;
        }
    }
}
