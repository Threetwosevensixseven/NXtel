using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using NXtelData;

namespace NXtelGeo
{
    class Program
    {
        static void Main(string[] args)
        {
            var settings = new Settings(AppDomain.CurrentDomain.BaseDirectory).Load();
            foreach (var con in settings.GetAllConnectionStrings())
            {
                DBOps.ConnectionString = con;
                foreach (var geo in Geo.Load())
                {
                    Thread.Sleep(Options.GeoRequestDelayMillisecs);
                    geo.Lookup();
                    geo.Save();
                }
            }
        }
    }
}
