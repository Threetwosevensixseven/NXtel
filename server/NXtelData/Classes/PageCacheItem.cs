using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class PageCacheItem
    {
        public decimal FromPageFrameNo { get; set; }
        public decimal ToPageFrameNo { get; set; }
        public Page Page { get; set; }
        public DateTime Timestamp { get; set; }

        public PageCacheItem(Page Page)
        {
            this.FromPageFrameNo = Page.NormalisedFromPageFrameNo;
            this.ToPageFrameNo = Page.NormalisedToPageFrameNo;
            this.Page = Page;
            this.Timestamp = DateTime.Now;
        }
    }
}
