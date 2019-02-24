using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ToLFCR
{
    class Program
    {
        static int Main(string[] args)
        {
            try
            {
                if (args.Length != 1)
                {
                    Console.WriteLine("USAGE:");
                    Console.WriteLine("  ToLFCR FileName");
                    return 1;
                }
                string fn = (args[0] ?? "").Trim();
                if (!File.Exists(fn))
                {
                    Console.WriteLine("File does not exist:");
                    Console.WriteLine("  " + fn);
                }
                string contents = File.ReadAllText(fn);
                contents = contents
                    .Replace("\r\n", "\0")
                    .Replace("\n\r", "\0")
                    .Replace("\r", "\0")
                    .Replace("\n", "\0")
                    .Replace("\0", "\n\r");
                File.WriteAllText(fn, contents);
                return 0;
            }
            finally
            {
                //Console.WriteLine("\r\nPress any key to exit...");
                //Console.ReadKey();
            }
        }
    }
}
