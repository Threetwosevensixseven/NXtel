using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using NXtelData;

namespace NXtelLogImport
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                var now = DateTime.Now;
                Console.WriteLine("NXtelLogImport");
                Console.WriteLine(now.ToLongDateString() + " " + now.ToLongTimeString());
                bool noUpdate = args.Any(a => a.Equals("-NoUpdate", StringComparison.CurrentCultureIgnoreCase));
                var settings = new Settings(AppDomain.CurrentDomain.BaseDirectory).Load();
                DBOps.ConnectionString = settings.ConnectionString;
                Console.WriteLine("Database: " + settings.DatabaseName);
                if (noUpdate) Console.WriteLine("Database will not be updated");
                string cfg = (ConfigurationManager.AppSettings["TimestampCutoff"] ?? "").Trim();
                DateTime timestampCutoff = DateTime.MaxValue;
                if (!string.IsNullOrWhiteSpace(cfg))
                    DateTime.TryParse(cfg, out timestampCutoff);
                Console.WriteLine("Ignoring any timestamps newer than " + timestampCutoff.ToString("u"));
                Console.WriteLine("Reading log file...");
                string logFile = (ConfigurationManager.AppSettings["ImportLogFile"] ?? "").Trim();
                Console.WriteLine(logFile);
                var lines = File.ReadAllLines(logFile);
                Console.WriteLine("Processing " + lines.Length + " lines...");
                int i = 0;
                var stats = new List<Stats>();
                var rDate = new Regex(@"^\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d$");
                var rQueue = new Regex(@"^Queuing page (?<PageNo>\d+)(?<FrameNo>[a-zA-Z]) for sending \(To: (?<IPAddress>\d+.\d+.\d+.\d+):\d+\)$");
                var rSend = new Regex(@"Sending page (?<PageNo>\d+)(?<FrameNo>[a-zA-Z]) \(To: (?<IPAddress>\d+.\d+.\d+.\d+):\d+\)$");
                DateTime ts = DateTime.MinValue;
                foreach (string line in lines)
                {
                    i++;
                    int percent = Convert.ToInt32(Math.Round((i * 100m) / (lines.Length + 0m), 0));
                    string prefix = percent + "%: ";
                    if (rDate.IsMatch(line))
                    {
                        ts = DateTime.ParseExact(line, "dd/MM/yyyy HH:mm:ss", CultureInfo.InvariantCulture);
                        if (ts > timestampCutoff)
                        {
                            Console.WriteLine(prefix + "Ignoring timestamp " + ts.ToString("u"));
                            continue;
                        }
                        Console.WriteLine(prefix + "Timestamp " + ts.ToString("u"));
                    }
                    if (ts == DateTime.MinValue || ts > timestampCutoff)
                        continue;
                    Stats stat = null;
                    var match = rQueue.Match(line);
                    if (match.Success)
                    {
                        string page = match.Groups["PageNo"].Value;
                        string frame = match.Groups["FrameNo"].Value.ToLower();
                        string ip = match.Groups["IPAddress"].Value;
                        stat = new Stats(ts, ip, page, frame);
                        stats.Add(stat);
                        Console.WriteLine(prefix + "Page " + page + frame + " " + ip + stat.ClientHash);
                    }
                    else
                    {
                        match = rSend.Match(line);
                        if (match.Success)
                        {
                            string page = match.Groups["PageNo"].Value;
                            string frame = match.Groups["FrameNo"].Value.ToLower();
                            string ip = match.Groups["IPAddress"].Value;
                            stat = new Stats(ts, ip, page, frame);
                            stats.Add(stat);
                            Console.WriteLine(prefix + "Page " + page + frame + " " + ip + " " + stat.ClientHash);
                        }
                        else
                            continue;
                    }
                }

                if (!noUpdate)
                {
                    Console.WriteLine();
                    Console.WriteLine("Updating " + stats.Count + " stats...");
                    i = 0;
                    foreach (var stat in stats)
                    {
                        i++;
                        int percent = Convert.ToInt32(Math.Round((i * 100m) / (stats.Count + 0m), 0));
                        string prefix = percent + "%: ";
                        Console.WriteLine(prefix + "Updating " + stat.ClientHash + "/" + stat.PageNo + "/" + stat.FrameNo);
                        stat.Update();
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
                Console.WriteLine();
                Console.WriteLine("Press ENTER to continue...");
                Console.ReadLine();
            }
        }
    }
}
