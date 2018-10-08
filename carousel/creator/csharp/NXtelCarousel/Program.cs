using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelCarousel
{
    class Program
    {
        const int LEN = 2;
        const int SNAP_LEN = 131103;
        const int SNAP_PADLEN = 0x22000;
        const int BANK_PADLEN = 0x2000;
        const string MSG = " Oi, stay out of my code!";
        public static Random RNG = new Random(SNAP_LEN);

        static int Main(string[] args)
        {
            // Set up input snapshot
            string inputBinary = GetFileName("InputBinary");
            if (!File.Exists(inputBinary))
            {
                Console.Write("Input Binary not found: " + inputBinary);
                Console.Read();
                return 1;
            }

            // Set up input CSV
            string inputCSV = GetFileName("InputCSV");
            if (!File.Exists(inputCSV))
            {
                Console.Write("Input CSV not found: " + inputCSV);
                Console.Read();
                return 1;
            }

            // Set up output binary
            string outputBinary = GetFileName("OutputBinary");
            if (!Directory.Exists(Path.GetDirectoryName(outputBinary)))
                Directory.CreateDirectory(Path.GetDirectoryName(outputBinary));
            string outputBinaryName = Path.GetFileName(outputBinary);

            // Read CSVFile
            var lines = File.ReadAllLines(inputCSV);
            var files = new Dictionary<string, short>();
            foreach (var line in lines)
            {
                string fileName = line.Split(',')[0].Trim();
                if (!files.ContainsKey(fileName))
                    files.Add(fileName, 0);
            }
            short pageCount = 0;
            foreach (var key in files.Keys.ToArray())
                files[key] = pageCount++;

            // Make page table
            var pages = new List<Page>();
            short duration;
            foreach (var line in lines)
            {
                string[] cols = line.Split(',');
                string file = cols[0].Trim(); // Read filename
                string dur = cols.Length >= 2 ? cols[1].Trim() : ""; // Read duration
                short.TryParse(dur, out duration);
                if (duration <= 0) duration = 10; // Set 10s default duration
                var pageNo = files[file];
                pages.Add(new Page(pageNo, duration));
            }

            // Make bank table
            var banks = new List<Bank>();
            short fileNo = 0;
            Bank bank = null;
            foreach (var file in files.Keys)
            {
                byte bankNo = Convert.ToByte((fileNo / 8) + 30);
                if (!banks.Any(b => b.BankNo == bankNo))
                {
                    bank = new Bank(bankNo);
                    banks.Add(bank);
                }
                var bytes = ReadPage(file);
                bank.Bytes.AddRange(bytes);
            }
            foreach (var b in banks)
            {
                var bytes = b.Bytes.ToArray();
                Pad(ref bytes, 1024 * 8);
                b.Bytes = bytes.ToList();
            }

            // Read input binary
            var bin = File.ReadAllBytes(inputBinary);

            // Truncate and pad to start of banks
            Pad(ref bin, SNAP_PADLEN); 
            var binary = bin.ToList();

            // Append 8KB banks
            foreach (var b in banks)
                binary.AddRange(b.Bytes);

            // Write tables
            int p = 0x9000;
            binary[p++] = Convert.ToByte(banks.Count);              // ResourcesCount
            binary[p++] = Convert.ToByte(pages.Count);              // PagesCount
            byte[] fn = Encoding.ASCII.GetBytes(outputBinaryName);
            Pad(ref fn, 31, '\0');
            for (int i = 0; i < fn.Length; i++)
                binary[p++] = fn[i];                            // Filename, null-terminated
            foreach (var b in banks)                                // Write Resources.Table
            {
                binary[p++] = b.BankNo;                             // Resources.Bank
                binary[p++] = b.BankNo;                             // Resources.FName
            }
            foreach (var page in pages)                             // Write Pages.Table
            {
                binary[p++] = page.Bank;                            // Pages.Bank
                binary[p++] = page.Slot;                            // Pages.Slot
                binary[p++] = page.DurationLSB;                     
                binary[p++] = page.DurationMSB;                     // Pages.Duration
            }

            // Write output binary
            File.WriteAllBytes(outputBinary, binary.ToArray());

            return 0;
        }

        private static string GetFileName(string AppSetting)
        {
            var file = (ConfigurationManager.AppSettings[AppSetting] ?? "").Trim();
            if (!(file.StartsWith(Path.DirectorySeparatorChar.ToString()) || file.Contains(":")))
                file = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, file);
            return file;
        }

        private static byte[] ReadPage(string FileName)
        {
            string dir = GetFileName("PageDirectory");
            string file = Path.Combine(dir, FileName);
            var bytes = File.ReadAllBytes(file);
            Pad(ref bytes, 1024);
            return bytes;
        }

        private static void Pad(ref byte[] Bytes, int Length, Char? Character = null)
        {
            var before = Bytes.Length;
            Array.Resize<byte>(ref Bytes, Length);
            for (int i = before; i < Bytes.Length; i++)
                Bytes[i] = Convert.ToByte(Character ?? RNG.Next(256));
        }

    }
}
