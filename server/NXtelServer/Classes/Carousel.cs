using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NXtelData;

namespace NXtelServer.Classes
{
    public class Carousel : List<Page>, ICarousel
    {
        public int NextIndex = 0;
        private Client _client;

        public Carousel(Client Client)
        {
            _client = Client;
        }

        public void Create(Page Page)
        {
            lock (_client.CarouselLock)
            {
                Clear();
                NextIndex = 0;
                if (Page == null || !Page.IsCarousel || Page.Routing == null)
                    return;
                var unique = new HashSet<string>();
                unique.Add(Page.PageAndFrame);
                var curPage = Page;
                while (true)
                {
                    var route = curPage.Routing.FirstOrDefault(r => r.KeyCode == Convert.ToByte(RouteKeys.Carousel));
                    if (route == null || route.GoesToPageID <= 0) break;
                    var next = Page.Load(route.GoesToPageNo, route.GoesToFrameNo);
                    if (next == null || next.PageID <= 0 || unique.Contains(next.PageAndFrame)) break;
                    Add(next);
                    unique.Add(next.PageAndFrame);
                    curPage = next;
                }
                if (Count > 0)
                    Add(Page);
                if (Count > 0)
                    _client.EnableCarousel(curPage.CarouselWait);
                else
                    _client.DisableCarousel();
            }
        }
    }
}
