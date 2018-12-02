using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using HeyRed.MarkdownSharp;

namespace NXtelData
{
    public static class HelpItemExtensions
    {
        public static string LoadMarkdown(this HelpItem HelpItem)
        {
            if (HelpItem == null)
                return null;
            HelpItem.LoadContent();
            var opts = new MarkdownOptions();
            opts.Strikethrough = true;
            var md = new Markdown(opts);
            HelpItem.HTML = md.Transform(HelpItem.Content ?? "");
            return HelpItem.HTML;
        }
    }
}