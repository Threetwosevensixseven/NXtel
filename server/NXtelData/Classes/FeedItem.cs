using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class FeedItem
    {
        public Dictionary<int, string> Values { get; set; }
        public FeedItem()
        {
            Values = new Dictionary<int, string>();
        }

        public string[] SplitByWords(int ItemNo, int maxStringLength)
        {
            if (ItemNo < 0 || ItemNo >= this.Values.Count)
                return new string[0];
            string text = (this.Values[ItemNo] ?? "").Trim();
            char[] splitOnCharacters = new char[] { ' ', '-' };
            var sb = new StringBuilder();
            var index = 0;
            while (text.Length > index)
            {
                if (index != 0)
                    sb.Append('\n');
                var splitAt = index + maxStringLength <= text.Length
                    ? text.Substring(index, maxStringLength).LastIndexOfAny(splitOnCharacters)
                    : text.Length - index;
                if (splitAt != -1 && splitAt < (text.Length - 1) && text[splitAt] == '-')
                    splitAt++;
                splitAt = (splitAt == -1) ? maxStringLength : splitAt;
                sb.Append(text.Substring(index, splitAt).Trim());
                index += splitAt;
            }
            return sb.ToString().Split('\n');
        }
    }
}
