using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace Version
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                int version = 0;
                string file = (ConfigurationManager.AppSettings["OutputFile"] ?? "").Trim();
                string ns = (ConfigurationManager.AppSettings["Namespace"] ?? "").Trim();
                if (string.IsNullOrEmpty(file)) file = "Version.cs";
                if (string.IsNullOrEmpty(file)) ns = "GitVersion";
                var dir = Path.GetDirectoryName(file);
                if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
                    Directory.CreateDirectory(dir);

                // Get git version
                try
                {
                    var p = new Process();
                    p.StartInfo.FileName = "git.exe";
                    p.StartInfo.UseShellExecute = false;
                    p.StartInfo.RedirectStandardOutput = true;
                    p.StartInfo.Arguments = "rev-list --count HEAD";
                    p.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
                    p.Start();
                    string output = p.StandardOutput.ReadToEnd();
                    p.WaitForExit();
                    output = output.Replace("\r", "").Replace("\n", "");
                    int.TryParse(output, out version);
                }
                catch
                {
                    version = 0;
                }

                // Create file
                var sb = new StringBuilder();
                sb.Append("namespace ");
                sb.AppendLine(ns);
                sb.AppendLine("{");
                sb.AppendLine("    public static class Version");
                sb.AppendLine("    {");
                sb.Append("        public const string Number = \"1.0.1.");
                sb.Append(version);
                sb.AppendLine("\";");
                sb.AppendLine("    }");
                sb.AppendLine("}");
                sb.AppendLine();

                // Write file
                System.IO.File.WriteAllText(file, sb.ToString());
            }
            catch (Exception ex)
            {
                Console.Write(ex.Message);
                Console.Write(ex.StackTrace);
            }
        }
    }
}
