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
            Markdown mark = new Markdown();
            HelpItem.HTML = mark.Transform(HelpItem.Content ?? "");
            return HelpItem.HTML;
        }
    }
}