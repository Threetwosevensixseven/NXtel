using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using NXtelData;

namespace NXtelGeo
{
    public class Program
    {
        private static bool interactive;

        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("NXtelGeo processing...");
                interactive = args.Any(a => a.ToLower() == "-i");
                if (interactive)
                    Console.WriteLine("Running in interactive mode");
                var settings = new Settings(AppDomain.CurrentDomain.BaseDirectory).Load();
                foreach (var con in settings.GetAllConnectionStrings())
                {
                    DBOps.ConnectionString = con;
                    Console.WriteLine("\r\nPROCESSING DB " + settings.DatabaseName.ToUpper() + ":");
                    foreach (var geo in Geo.Load())
                    {
                        Thread.Sleep(Options.GeoRequestDelayMillisecs);
                        Console.Write((geo.IPAddress.ToString() + ": ").PadRight(17));
                        bool success = geo.Lookup();
                        if (success)
                        {
                            Console.Write(geo.lat.ToString() + "," + geo.lon.ToString());
                            if (geo.Save())
                                Console.Write(" - SAVED");
                            else
                                Console.Write(" - NOT SAVED");
                        }
                        else
                        {
                            Console.Write("FAIL");
                        }
                        Console.WriteLine();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Console.WriteLine(ex.StackTrace);
            }
            finally
            {
                if (interactive)
                {
                    Console.WriteLine("Press any key to continue...");
                    Console.ReadKey();
                }
            }
        }
    }
}
