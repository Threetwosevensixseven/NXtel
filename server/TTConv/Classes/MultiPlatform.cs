using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public class MultiPlatform
    {
        private Platforms _os;
        public Platforms OS { get { return _os; } }

        public MultiPlatform()
        {
            _os = Platforms.Unknown;
            try
            {
                OperatingSystem os = Environment.OSVersion;
                PlatformID pid = os.Platform;
                switch (pid)
                {
                    case PlatformID.Win32NT:
                    case PlatformID.Win32S:
                    case PlatformID.Win32Windows:
                    case PlatformID.WinCE:
                        _os = Platforms.Windows;
                        break;
                    case PlatformID.Unix:
                        _os = Platforms.Linux;
                        break;
                    default:
                        _os = Platforms.MacOS;
                        break;
                }
                if (_os == Platforms.Linux)
                {
                    string uname = Uname();
                    if ((uname ?? "").Trim().ToLower().Contains("darwin"))
                        _os = Platforms.MacOS;
                }
            }
            catch
            {
                _os = Platforms.Unknown;
            }
        }

        public bool OpenURL(string URL)
        {
            try
            {
                if (OS == Platforms.Windows)
                {
                    ShellExecute(IntPtr.Zero, "open", URL ?? "", "", "", ShowCommands.SW_SHOWDEFAULT);
                    return true;
                }

                else if (OS == Platforms.Linux)
                {
                    Process.Start("xdg-open " + (URL ?? ""));
                    return true;
                }

                else if (OS == Platforms.MacOS)
                {
                    Process.Start("open " + (URL ?? ""));
                    return true;
                }
            }
            catch
            {
                return false;
            }

            return false;
        }

        public enum Platforms
        {
            Unknown,
            Windows,
            Linux,
            MacOS
        }

        private enum ShowCommands : int
        {
            SW_HIDE = 0,
            SW_SHOWNORMAL = 1,
            SW_NORMAL = 1,
            SW_SHOWMINIMIZED = 2,
            SW_SHOWMAXIMIZED = 3,
            SW_MAXIMIZE = 3,
            SW_SHOWNOACTIVATE = 4,
            SW_SHOW = 5,
            SW_MINIMIZE = 6,
            SW_SHOWMINNOACTIVE = 7,
            SW_SHOWNA = 8,
            SW_RESTORE = 9,
            SW_SHOWDEFAULT = 10,
            SW_FORCEMINIMIZE = 11,
            SW_MAX = 11
        }

        [DllImport("shell32.dll")]
        private static extern IntPtr ShellExecute(
            IntPtr hwnd,
            string lpOperation,
            string lpFile,
            string lpParameters,
            string lpDirectory,
            ShowCommands nShowCmd);

        private static string Uname()
        {
            try
            {
                var sb = new StringBuilder();
                var psi = new ProcessStartInfo();
                psi.CreateNoWindow = true;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardInput = true;
                psi.UseShellExecute = false;
                psi.Arguments = "";
                psi.FileName = "uname";
                var p = new Process();
                p.StartInfo = psi;
                p.EnableRaisingEvents = true;
                p.OutputDataReceived += new DataReceivedEventHandler
                (
                    delegate (object sender, DataReceivedEventArgs e)
                    {
                        sb.Append(e.Data);
                    }
                );
                p.Start();
                p.BeginOutputReadLine();
                p.WaitForExit();
                p.CancelOutputRead();
                return sb.ToString();
            }
            catch
            {
                return "Unknown";
            }
        }
    }
}
