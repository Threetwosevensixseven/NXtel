using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using NXtelData;

namespace NXtelManager.Models
{
    public class NoticeIndexModel
    {
        public Notices Notices { get; set; }
        public Zone Zone { get; set; }

        private Random gen = new Random();
        public DateTime RandomDay()
        {
            DateTime start = new DateTime(1995, 1, 1);
            int range = (DateTime.Today - start).Days;
            return start.AddDays(gen.Next(range));
        }
    }
}