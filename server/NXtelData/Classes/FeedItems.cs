using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace NXtelData
{
    public class FeedItems: List<FeedItem>
    {
        public void Load(string XML, string Expression)
        {
            var doc = new XmlDocument();
            doc.LoadXml(XML);
            Load(doc, Expression);
        }

        public void Load(XmlDocument Doc, string Expression)
        {
            Clear();
            var title = Template.GetExpression("@title", Expression);
            var text = Template.GetExpression("@text", Expression);
            var url = Template.GetExpression("@url", Expression);
            var titles = Doc.SelectNodes(title);
            var texts = Doc.SelectNodes(text);
            var urls = Doc.SelectNodes(url);
            for (int i = 0; i < titles.Count; i++)
            {
                var fi = new FeedItem();
                fi.Title = (titles[i].FirstChild.Value ?? "").Trim();
                if (texts.Count - 1 >= i)
                    fi.Text = (texts[i].FirstChild.Value ?? "").Trim();
                if (urls.Count - 1 >= i)
                    fi.URL = (urls[i].FirstChild.Value ?? "").Trim();
                Add(fi);
            }
        }
    }
}
