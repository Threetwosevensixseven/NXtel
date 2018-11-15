using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NXtelData;

namespace TelesoftEncoder
{
    class Program
    {
        const int PAGE_LEN = (22 * 40) - 5; // Available length minus the terminator and checksum
        public static List<Page> Pages;
        public static int CurrentPageNo;
        public static int CurrentFrameNo;
        public static int CurrentChecksum;
        public static TelesoftEscapes CurrentEscape;
        public static Page CurrentPage;

        static void Main(string[] args)
        {
            Pages = new List<Page>();
            CurrentPageNo = Options.StartPageNo;
            CurrentFrameNo = Options.StartFrameNo;
            CurrentEscape = TelesoftEscapes.E0;
            CurrentPage = new Page();
            Pages.Add(CurrentPage);
            CurrentPage.PageNo = CurrentPageNo;
            CurrentPage.FrameNo = CurrentFrameNo;
            var file = File.ReadAllBytes(Options.TelesoftFile);
            string fn = Path.GetFileName(Options.TelesoftFile).Trim();
            fn = fn.Replace("|", "|E"); // Escape escape sequence if present in filename
            string contents = "";
            CreateNewPage();
            contents = "|A"; // Start of telesoftware block
            CurrentChecksum = 0;
            contents += Checksum("|G" + CurrentPage.Frame + "|I"); // Frame letter of telesoftware block, terminated
            contents += Checksum("|L"); // EOL, completing header
            foreach (byte b in file)
            {
                string newChar = EscapeChar(b);
                if (contents.Length + newChar.Length > PAGE_LEN)
                {
                    contents += "|Z" + CurrentChecksum.ToString("D3");
                    CurrentPage.ConvertContentsFromString(contents);
                    CreateNewPage();
                    contents = "|A"; // Start of telesoftware block
                    CurrentChecksum = 0;
                    contents += Checksum("|G" + CurrentPage.Frame + "|I"); // Frame letter of telesoftware block, terminated
                    contents += Checksum("|L"); // EOL, completing header
                    contents += Checksum(newChar);
                }
                else
                {
                    contents += Checksum(newChar);
                }

            }
            contents += "|Z" + CurrentChecksum.ToString("D3");
            CurrentPage.ConvertContentsFromString(contents);
            // Calculate header contents
            contents = "|A"; // Start of telesoftware block
            CurrentChecksum = 0;
            contents += Checksum("|G" + Pages[0].Frame); // Frame letter of telesoftware block
            contents += Checksum("|I" + fn + "|L"); // Telesoftware filename
            contents += Checksum((Pages.Count - 1).ToString("D3")); // header frame count
            contents += "|Z"; // end of telesoftware block
            contents += CurrentChecksum.ToString("D3"); // header checksum
            Pages[0].ConvertContentsFromString(contents);        
        }

        public static void CreateNewPage()
        {
            var page = new Page();
            page.PageNo = CurrentPage.NextPageNo;
            page.FrameNo = CurrentPage.NextFrameNo;
            CurrentPage = page;
            Pages.Add(CurrentPage);
            CurrentEscape = TelesoftEscapes.E0;
        }

        public static string EscapeChar(byte Byte, bool NoEscaping = false)
        {
            string rv = "";
            if (NoEscaping)
            {
                if (Byte == Convert.ToByte('|')) // Escape | as |E in the body
                    return EscapeChar(Convert.ToByte('|'), true) + EscapeChar(Convert.ToByte('E'), true);
                if (Byte == Convert.ToByte(' ')) // Escape space as } in the body, allowing lines with trailing spaces to be truncated
                    return EscapeChar(Convert.ToByte('}'), true);
                if (Byte == Convert.ToByte('}')) // Escape } as |} in the body
                    return EscapeChar(Convert.ToByte('|'), true) + EscapeChar(Convert.ToByte('}'), true);
            }

            if (Byte >= 0 && Byte <= 31)
            {
                if (CurrentEscape != TelesoftEscapes.E1)
                {
                    CurrentEscape = TelesoftEscapes.E1;
                    rv += "|1";
                }
                rv += Convert.ToChar(Convert.ToByte(Convert.ToInt32(Byte) + 64));
            }
            else if (Byte >= 32 && Byte <= 127)
            {
                if (CurrentEscape != TelesoftEscapes.E0)
                {
                    CurrentEscape = TelesoftEscapes.E0;
                    rv += "|0";
                }
                rv += Convert.ToChar(Byte);
            }
            else if (Byte >= 128 && Byte <= 159)
            {
                if (CurrentEscape != TelesoftEscapes.E2)
                {
                    CurrentEscape = TelesoftEscapes.E2;
                    rv += "|2";
                }
                rv += Convert.ToChar(Convert.ToByte(Convert.ToInt32(Byte) - 64));
            }
            else if (Byte >= 160 && Byte <= 191)
            {
                if (CurrentEscape != TelesoftEscapes.E3)
                {
                    CurrentEscape = TelesoftEscapes.E3;
                    rv += "|3";
                }
                rv += Convert.ToChar(Convert.ToByte(Convert.ToInt32(Byte) - 96));
            }
            else if (Byte >= 192 && Byte <= 223)
            {
                if (CurrentEscape != TelesoftEscapes.E4)
                {
                    CurrentEscape = TelesoftEscapes.E4;
                    rv += "|4";
                }
                rv += Convert.ToChar(Convert.ToByte(Convert.ToInt32(Byte) - 128));
            }
            else if (Byte >= 224 && Byte <= 255)
            {
                if (CurrentEscape != TelesoftEscapes.E5)
                {
                    CurrentEscape = TelesoftEscapes.E5;
                    rv += "|5";
                }
                rv += Convert.ToChar(Convert.ToByte(Convert.ToInt32(Byte) - 160));
            }
            else
                throw new InvalidOperationException("Byte is outside 0-255 range.");
            return rv;
        }

        public static string Checksum(string Text)
        {
            foreach (byte b in ASCIIEncoding.ASCII.GetBytes(Text ?? ""))
                CurrentChecksum ^= (b & 0x7f);
            return Text;
        }
    }
}
