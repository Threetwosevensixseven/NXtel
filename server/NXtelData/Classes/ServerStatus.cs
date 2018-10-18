using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class ServerStatus
    {
        public bool StartVisible { get; set; }

        public string Location
        {
            get
            {
                return Options.ServerLocation;
            }
        }
        public Process[] Instances
        {
            get
            {
                string exe = Path.GetFileNameWithoutExtension(Options.ServerLocation).ToLower();
                return Process.GetProcessesByName(exe);
            }
        }

        public string Status
        {
            get
            {
                var ps = Instances;
                if (Instances.Length == 0)
                    return "DOWN";
                else if (Instances.Length == 1)
                    return "UP";
                else
                   return "UP (" + ps.Length + ")";
            }
        }

        public string StatusColor
        {
            get
            {
                var ps = Instances;
                if (Instances.Length == 0)
                    return "red";
                else
                    return "green";
            }
        }

        public static ServerStatus KillAll()
        {
            foreach (var p in new ServerStatus().Instances)
            {
                try
                {
                    p.Kill();
                }
                catch { }
            }
            while (true)
            {
                var status = new ServerStatus();
                if (status.Instances.Length == 0)
                    return status;
            }
        }

        public static ServerStatus Start(bool StartVisible = false)
        {
            var status = new ServerStatus();
            var pids = status.Instances.Select(p => p.Id);
            var server = new ProcessStartInfo();
            server.FileName = status.Location;
            server.WindowStyle = StartVisible ? ProcessWindowStyle.Minimized : ProcessWindowStyle.Hidden;
            Process.Start(server);
            while (true)
            {
                status = new ServerStatus();
                foreach (var instance in status.Instances)
                    if (pids.FirstOrDefault(p => p == instance.Id) <= 0)
                        return status;
            }
        }

        public string StartClass
        {
            get
            {
                return Instances.Length == 0 ? "active" : "hidden";
            }
        }

        public string StopClass
        {
            get
            {
                return Instances.Length > 0 ? "active" : "hidden";
            }
        }
    }
}
