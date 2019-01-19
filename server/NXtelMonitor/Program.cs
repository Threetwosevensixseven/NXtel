using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.Text;

namespace NXtelMonitor
{
    class Program
    {
        private static int Main(string[] args)
        {
            bool kill = args.Any(a => a.ToLower() == "-k");
            bool start = args.Any(a => a.ToLower() == "-s");
            var rest = args.Where(a => a.ToLower() != "-k" && a.ToLower() != "-s").ToList();
            if (kill && rest.Count != 1)
            {
                Console.WriteLine("Usage: NXtelMonitor -k PathAndFileName");
                return 1;
            }
            else if (start && rest.Count != 0)
            {
                Console.WriteLine("Usage: NXtelMonitor -s");
                return 1;
            }
            else if (!kill && !start)
            {
                Console.WriteLine("Usage: NXtelMonitor -k PathAndFileName");
                Console.WriteLine("Or:    NXtelMonitor -s");
                return 1;
            }

            string pathAndFile = "NXtelServer.exe";
            if (rest.Count == 1)
                pathAndFile = rest[0];

            if (kill)
                return Kill(pathAndFile);

            if (start)
                return Start();

            return 1;
        }

        [DllImport("kernel32.dll")]
        private static extern bool QueryFullProcessImageName(IntPtr hprocess, int dwFlags,
                       StringBuilder lpExeName, out int size);
        [DllImport("kernel32.dll")]
        private static extern IntPtr OpenProcess(ProcessAccess dwDesiredAccess,
                       bool bInheritHandle, int dwProcessId);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hHandle);

        [Flags]
        public enum ProcessAccess
        {
            /// <summary>
            /// Required to create a thread.
            /// </summary>
            CreateThread = 0x0002,

            /// <summary>
            /// 
            /// </summary>
            SetSessionId = 0x0004,

            /// <summary>
            /// Required to perform an operation on the address space of a process 
            /// </summary>
            VmOperation = 0x0008,

            /// <summary>
            /// Required to read memory in a process using ReadProcessMemory.
            /// </summary>
            VmRead = 0x0010,

            /// <summary>
            /// Required to write to memory in a process using WriteProcessMemory.
            /// </summary>
            VmWrite = 0x0020,

            /// <summary>
            /// Required to duplicate a handle using DuplicateHandle.
            /// </summary>
            DupHandle = 0x0040,

            /// <summary>
            /// Required to create a process.
            /// </summary>
            CreateProcess = 0x0080,

            /// <summary>
            /// Required to set memory limits using SetProcessWorkingSetSize.
            /// </summary>
            SetQuota = 0x0100,

            /// <summary>
            /// Required to set certain information about a process, such as its priority class (see SetPriorityClass).
            /// </summary>
            SetInformation = 0x0200,

            /// <summary>
            /// Required to retrieve certain information about a process, such as its token, exit code, and priority class (see OpenProcessToken).
            /// </summary>
            QueryInformation = 0x0400,

            /// <summary>
            /// Required to suspend or resume a process.
            /// </summary>
            SuspendResume = 0x0800,

            /// <summary>
            /// Required to retrieve certain information about a process (see GetExitCodeProcess, GetPriorityClass, IsProcessInJob, QueryFullProcessImageName). 
            /// A handle that has the PROCESS_QUERY_INFORMATION access right is automatically granted PROCESS_QUERY_LIMITED_INFORMATION.
            /// </summary>
            QueryLimitedInformation = 0x1000,

            /// <summary>
            /// Required to wait for the process to terminate using the wait functions.
            /// </summary>
            Synchronize = 0x100000,

            /// <summary>
            /// Required to delete the object.
            /// </summary>
            Delete = 0x00010000,

            /// <summary>
            /// Required to read information in the security descriptor for the object, not including the information in the SACL. 
            /// To read or write the SACL, you must request the ACCESS_SYSTEM_SECURITY access right. For more information, see SACL Access Right.
            /// </summary>
            ReadControl = 0x00020000,

            /// <summary>
            /// Required to modify the DACL in the security descriptor for the object.
            /// </summary>
            WriteDac = 0x00040000,

            /// <summary>
            /// Required to change the owner in the security descriptor for the object.
            /// </summary>
            WriteOwner = 0x00080000,

            StandardRightsRequired = 0x000F0000,

            /// <summary>
            /// All possible access rights for a process object.
            /// </summary>
            AllAccess = StandardRightsRequired | Synchronize | 0xFFFF
        }

        private static string GetExecutablePath(Process Process)
        {
            //If running on Vista or later use the new function
            if (Environment.OSVersion.Version.Major >= 6)
            {
                return GetExecutablePathAboveVista(Process.Id);
            }

            return Process.MainModule.FileName;
        }

        private static string GetExecutablePathAboveVista(int dwProcessId)
        {
            StringBuilder buffer = new StringBuilder(1024);
            IntPtr hprocess = OpenProcess(ProcessAccess.QueryLimitedInformation, false, dwProcessId);
            if (hprocess != IntPtr.Zero)
            {
                try
                {
                    int size = buffer.Capacity;
                    if (QueryFullProcessImageName(hprocess, 0, buffer, out size))
                    {
                        return buffer.ToString();
                    }
                }
                finally
                {
                    CloseHandle(hprocess);
                }
            }
            return string.Empty;
        }

        private static int Kill(string PathAndFile)
        {
            string exe = Path.GetFileNameWithoutExtension((PathAndFile ?? "")).ToLower();
            var path = Path.GetDirectoryName(PathAndFile ?? "").Trim().ToLower();
            foreach (var p in Process.GetProcessesByName(exe))
            {
                if (string.IsNullOrWhiteSpace(path))
                    p.Kill();
                else
                {
                    var thisExe = GetExecutablePath(p).Trim().ToLower();
                    if (string.IsNullOrWhiteSpace(thisExe))
                        continue;
                    string thisPath = Path.GetDirectoryName(thisExe).Trim().ToLower();
                    if (thisPath == path)
                        p.Kill();
                }
            }

            return 0;
        }

        private static int Start()
        {
            int success = 0;
            string join = "";
            foreach (var cfg in ConfigurationManager.AppSettings)
            {
                var key = (cfg ?? "").ToString();
                if (!key.StartsWith("StartServer"))
                    continue;
                Console.WriteLine(join + "Processing " + key + "...");
                join = "\r\n";
                var val = (ConfigurationManager.AppSettings[key] ?? "").ToString().Trim();
                var vals = val.Split(new char[] { ';' }, 2);
                if (vals.Length != 2)
                {
                    Console.WriteLine("Invalid format: " + val);
                    continue;
                }
                string exeFile = vals[0].Trim();
                string url = vals[1].Trim();
                if (string.IsNullOrWhiteSpace(exeFile))
                {
                    Console.WriteLine("Invalid exe");
                    continue;
                }
                if (!File.Exists(exeFile))
                {
                    Console.WriteLine("Invalid exe: " + exeFile);
                    continue;
                }
                if (string.IsNullOrWhiteSpace(url))
                {
                    Console.WriteLine("Invalid url");
                    continue;
                }

                string exe = Path.GetFileNameWithoutExtension((exeFile ?? "")).ToLower();
                var path = Path.GetDirectoryName(exeFile ?? "").Trim().ToLower();
                if (string.IsNullOrWhiteSpace(exe))
                {
                    Console.WriteLine("Invalid filename: " + exe);
                    continue;
                }
                if (string.IsNullOrWhiteSpace(path))
                {
                    Console.WriteLine("Invalid path: " + path);
                    continue;
                }

                Console.WriteLine("Checking processes: " + exeFile);

                int runCount = 0;
                foreach (var p in Process.GetProcessesByName(exe))
                {
                    var thisExe = GetExecutablePath(p).Trim().ToLower();
                    if (string.IsNullOrWhiteSpace(thisExe))
                        continue;
                    string thisPath = Path.GetDirectoryName(thisExe).Trim().ToLower();
                    if (thisPath == path)
                        runCount++;
                }
                if (runCount > 0)
                {
                    string plural = runCount == 1 ? " instance" : " instances";
                    Console.WriteLine("Already running " + runCount + plural);
                    continue;
                }

                string dis = exeFile + ".enabled";
                bool disabled = false;
                try
                {
                    var contents = (File.ReadAllText(dis) ?? "").Trim();
                    disabled = (contents == "0");
                }
                catch { }
                Console.WriteLine("Server is " + (disabled ? "disabled" : "enabled"));

                if (!disabled)
                {
                    Console.WriteLine("Calling URL: " + url);
                    try
                    {
                        var request = WebRequest.Create(url);
                        var response = request.GetResponse();
                        Console.WriteLine("Success calling URL");
                    }
                    catch
                    {
                        Console.WriteLine("Error calling URL");
                        success = 1;
                    }
                }
            }
            return success;
        }
    }
}
