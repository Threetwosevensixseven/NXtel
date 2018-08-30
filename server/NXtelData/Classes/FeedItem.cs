using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class FeedItem
    {
        public string Title { get; set; }
        public string Text { get; set; }
        public string URL { get; set; }

        public FeedItem()
        {
            Title = Text = URL = string.Empty;
        }
    }
}
