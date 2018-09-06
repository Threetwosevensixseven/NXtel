using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace NXtelData
{
    public class FeedItems : List<FeedItem>
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
            var xitems = Template.GetExpression("@feed.item", Expression);
            var items = Doc.SelectNodes(xitems);
            if (items.Count == 0)
                return;
            int count = 0;
            var itemXpaths = new Dictionary<int, string>();
            while (true)
            {
                string val = Template.GetExpression("@feed.item." + count, Expression);
                if (string.IsNullOrWhiteSpace(val))
                    break;
                itemXpaths.Add(count, val);
                count++;
            }
            foreach (XmlNode item in items)
            {
                try
                {
                    var fi = new FeedItem();
                    bool filled = false;
                    for (int i = 0; i < count; i++)
                    {
                        var node = item.SelectSingleNode(itemXpaths[i]);
                        if (node != null && node.FirstChild != null)
                        {
                            fi.Values.Add(i, (node.FirstChild.Value ?? "").Trim());
                            filled = true;
                        }
                    }
                    if (filled)
                        this.Add(fi);
                }
                catch { }
            }
        }
    }
}
