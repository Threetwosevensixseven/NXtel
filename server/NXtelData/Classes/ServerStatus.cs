using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
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
                var rv = new List<Process>();
                var loc = Location;
                string exe = Path.GetFileNameWithoutExtension((loc ?? "")).ToLower();
                var path = Path.GetDirectoryName(loc ?? "").Trim().ToLower();
                if (string.IsNullOrWhiteSpace(path))
                    return rv.ToArray();
                foreach (var p in Process.GetProcessesByName(exe))
                {
                    var thisExe = GetExecutablePath(p).Trim().ToLower();
                    if (string.IsNullOrWhiteSpace(thisExe))
                        continue;
                    string thisPath = Path.GetDirectoryName(thisExe).Trim().ToLower();
                    if (thisPath == path)
                        rv.Add(p);
                }
                return rv.ToArray();
            }
        }

        public string Status
        {
            get
            {
                var ps = Instances;
                if (Instances.Length == 0)
                    return "DOWN" + (IsDisabled ? " (Disabled)" : "");
                else if (Instances.Length == 1)
                    return "UP" + (IsDisabled ? " (Disabled)" : "");
                else
                    return "UP (" + ps.Length + ")" + (IsDisabled ? " (Disabled)" : "");
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

        public bool IsDisabled
        {
            get
            {
                var loc = Location;
                var cfg = Path.Combine(Path.GetDirectoryName(loc), Path.GetFileName(loc).Trim() + ".enabled");
                try
                {
                    var contents = (File.ReadAllText(cfg) ?? "").Trim();
                    return contents == "0";
                }
                catch
                {
                    return false;
                }
            }
            set
            {
                var loc = Location;
                var cfg = Path.Combine(Path.GetDirectoryName(loc), Path.GetFileName(loc).Trim() + ".enabled");
                try
                {
                    File.WriteAllText(cfg, value ? "0" : "1");
                }
                catch { }
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
            if (status.IsDisabled)
                return status;
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

        public static void StartIfStopped()
        {
            try
            {
                var status = new ServerStatus();
                if (status.IsDisabled)
                    return;
                if (status.Instances.Length == 0)
                    Start();
            }
            catch { }
        }

    public string StartClass
        {
            get
            {
                return (Instances.Length == 0 && !IsDisabled) ? "active" : "hidden";
            }
        }

        public string StopClass
        {
            get
            {
                return Instances.Length > 0 ? "active" : "hidden";
            }
        }

        public string EnabledClass
        {
            get
            {
                return !IsDisabled ? "active" : "hidden";
            }
        }

        public string DisabledClass
        {
            get
            {
                return IsDisabled ? "active" : "hidden";
            }
        }

        public long LogFileSize
        {
            get
            {
                long size = 0;
                try
                {
                    size = new FileInfo(Options.LogFile).Length;
                }
                catch { }
                return size;
            }
        }

        #region win32

        [DllImport("kernel32.dll")]
        private static extern bool QueryFullProcessImageName(IntPtr hprocess, int dwFlags, 
            StringBuilder lpExeName, out int size);

        [DllImport("kernel32.dll")]
        private static extern IntPtr OpenProcess(ProcessAccess dwDesiredAccess, bool bInheritHandle, 
            int dwProcessId);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hHandle);

        [Flags]
        private enum ProcessAccess
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

        #endregion win32
    }
}
