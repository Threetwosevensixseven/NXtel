using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelBbcBasic
{
    class Program
    {
        static void Main(string[] args)
        {
            int skip = 6;
            var bytes = new List<byte>();
            var lines = File.ReadAllLines(@"C:\Users\robin\Documents\Visual Studio 2015\Projects\NXtel\server\NXtelBbcBasic\input.txt");
            foreach (string line in lines)
            {
                var hex = line.Substring(0, 51).Trim().Split(' ');
                foreach (var val in hex)
                {
                    if (skip > 0)
                    {
                        skip--;
                        continue;
                    }
                    var b = byte.Parse(val, System.Globalization.NumberStyles.HexNumber);
                    bytes.Add(b);
                }
            }

            bool esc = false;
            var bs = new List<byte>();
            foreach (var b in bytes)
            {
                var t = b;
                if (t == 27)
                    esc = true;
                else
                {
                    if (esc)
                        t = Convert.ToByte(t | 128);
                    if (t >= 0xC0 && t < 0xE0)
                        t = Convert.ToByte(t - 64);
                    if (t >= 32)
                        t = Convert.ToByte(t | 128);
                    bs.Add(t);
                    esc = false;
                }
            }

            string join = "";
            var sb = new StringBuilder();
            int lineNo = 10;

            sb.Append(lineNo);
            sb.AppendLine(" MODE 7");
            lineNo += 10;

            sb.Append(lineNo);
            sb.AppendLine(" CLS");
            lineNo += 10;

            sb.Append(lineNo);
            sb.Append(" FOR I% = 1 TO ");
            sb.AppendLine(bs.Count.ToString());
            lineNo += 10;

            sb.Append(lineNo);
            sb.AppendLine(" READ B%");
            lineNo += 10;

            sb.Append(lineNo);
            sb.AppendLine(" PRINT CHR$(B%);");
            lineNo += 10;

            sb.Append(lineNo);
            sb.AppendLine(" NEXT I%");
            lineNo += 10;

            sb.Append(lineNo);
            sb.Append(" GOTO ");
            sb.AppendLine(lineNo.ToString());
            lineNo += 10;

            for (int i = 0; i < bs.Count; i++)
            {
                if (i % 16 == 0)
                {
                    sb.Append(lineNo);
                    sb.Append(" DATA ");
                }
                sb.Append(join);
                sb.Append(bs[i]);
                join = ", ";
                if (i % 16 == 15)
                {
                    sb.AppendLine();
                    lineNo += 10;
                    join = "";
                }
            }
            sb.AppendLine();

            File.WriteAllText(@"C:\Users\robin\Documents\Visual Studio 2015\Projects\NXtel\server\NXtelBbcBasic\output.bbc", sb.ToString());

            //Console.ReadKey();
        }
    }
}
