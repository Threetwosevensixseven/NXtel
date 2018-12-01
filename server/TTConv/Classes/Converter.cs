using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public static class Converter
    {
        public static byte[] FromTT7(byte[] Src)
        {
            var dst = new List<byte>();
            bool EscapeNextChar = false;
            foreach (byte b in Src)
            {
                if (EscapeNextChar)
                {
                    dst.Add(Convert.ToByte(b | 0x80));
                    EscapeNextChar = false;
                }
                else
                {
                    if (b == 27)
                        EscapeNextChar = true;
                    else
                        dst.Add(b);
                }
            }
            return dst.ToArray();
        }

        public static byte[] ToTT7(byte[] Src)
        {
            var dst = new List<byte>();
            foreach (byte b in Src)
            {
                if (b >= 128)
                {
                    dst.Add(27);
                    dst.Add(Convert.ToByte(b & 127));
                }
                else
                {
                    dst.Add(b);
                }
            }
            return dst.ToArray();
        }

        public static byte[] FromTTU(string Src)
        {
            var dst = new byte[0];
            var r = new Regex("^(?:(?:http|https)://)?.*?:(?<Content>.*?):.*$");
            var m = r.Match(Src ?? "");
            if (!m.Success)
                return new byte[0];
            string url = m.Groups["Content"].Value ?? "";
            var cc = new byte[url.Length == 1167 ? 1000 : 960];
            string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
            for (int i = 0; i < url.Length; i++)
            {
                int val = alphabet.IndexOf(url[i]);
                if (val == -1)
                    return new byte[0];
                for (int b = 0; b < 6; b++)
                {
                    int bit = val & (1 << (5 - b));
                    if (bit > 0)
                    {
                        int cbit = (i * 6) + b;
                        int cpos = cbit % 7;
                        int cloc = (cbit - cpos) / 7;
                        cc[cloc] |= Convert.ToByte(1 << (6 - cpos));
                    }
                }
            }
            for (int i = 0; i < cc.Length; i++)
                if (cc[i] < 32)
                    cc[i] |= 128;
            return cc;
        }

        public static string ToTTU(byte[] Src, string URL)
        {
            // Initialise
            bool blackfg = false;
            int metadata = 0; // English
            Src = Pad(Src, 1000, 32); // Extend 24-row data to 25 row

            // Construct the metadata as described above.
            string encoding = "";
            if (blackfg)
                metadata += 8;
            encoding += metadata.ToString("X1");
            encoding += ":";

            // Construct a base-64 array by iterating over each character
            // in the frame.
            var b64 = new byte[1167];
            int chr = 0;
            for (var r = 0; r < 25; r++)
            {
                for (var c = 0; c < 40; c++)
                {
                    for (var b = 0; b < 7; b++)
                    {
                        // How many bits into the frame information we
                        // are.
                        var framebit = 7 * ((r * 40) + c) + b;

                        // Work out the position of the character in the
                        // base-64 encoding and the bit in that position.
                        var b64bitoffset = framebit % 6;
                        var b64charoffset = (framebit - b64bitoffset) / 6;

                        // Read a bit and write a bit.
                        var bitval = Src[chr] & (1 << (6 - b));
                        if (bitval > 0) { bitval = 1; }
                        b64[b64charoffset] |= Convert.ToByte(bitval << (5 - b64bitoffset));
                    }
                    chr++;
                }
            }

            // Encode bit-for-bit.
            for (var i = 0; i < 1167; i++)
            {
                encoding += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".Substring(b64[i], 1);
            }

            // Substitute the encoded data into the URL
            URL = (URL ?? "").Trim();
            URL = URL.Replace("<NewID>", "-2");
            if (URL.Contains("<Data>"))
                URL = URL.Replace("<Data>", encoding);
            else
                URL = encoding;

            return URL;
        }

        private static byte[] Pad(byte[] Bytes, int Length, byte Value = 32)
        {
            var before = Bytes.Length;
            Array.Resize<byte>(ref Bytes, Length);
            for (int i = before; i < Bytes.Length; i++)
                Bytes[i] = Value;
            return Bytes;
        }
    }
}
