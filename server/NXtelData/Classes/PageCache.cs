using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public static class PageCache
    {
        private static List<PageCacheItem> cache = new List<PageCacheItem>();

        public static Page Add(Page Page)
        {
            if (Page == null)
                return Page;
            var item = cache.FirstOrDefault(c => c.FromPageFrameNo < Page.NormalisedToPageFrameNo 
                && Page.NormalisedFromPageFrameNo < c.ToPageFrameNo);
            if (item != null)
            {
                item.Page = Page;
                item.Timestamp = DateTime.Now;
                //var exp = item.Timestamp.AddMinutes(Options.PageCacheDurationMins);
            }
            else
            {
                cache.Add(new PageCacheItem(Page));
            }
            return Page;
        }

        public static Page GetPage(int PageNo, int FrameNo)
        {
            decimal normalisedFromPageFrameNo = PageNo + (Convert.ToDecimal(FrameNo) / 100m);
            var item = cache.FirstOrDefault(c => c.FromPageFrameNo < normalisedFromPageFrameNo
                && normalisedFromPageFrameNo < c.ToPageFrameNo);
            if (item != null)
            {
                var exp = item.Timestamp.AddMinutes(Options.PageCacheDurationMins);
                if (DateTime.Now <= exp)
                    return item.Page;
                else
                    cache.Remove(item);
            }
            return null;
        }
    }
}
