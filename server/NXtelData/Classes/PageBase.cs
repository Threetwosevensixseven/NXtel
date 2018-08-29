using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public abstract class PageBase
    {
        protected byte[] _contents;
        protected byte[] _contents7BitEncoded;
        public string URL { get; set; }

        public PageBase()
        {
            URL = "";
            this.ConvertContentsFromURL();
        }

        public byte[] Contents
        {
            get
            {
                return _contents;
            }
            set
            {
                _contents = value;
                _contents7BitEncoded = null;
            }
        }

        public byte[] Contents7BitEncoded
        {
            get
            {
                if (_contents7BitEncoded == null)
                {
                    var enc = new List<byte>();
                    //enc.Add(30); // Cursor Home
                    enc.Add(12); // CLS
                    foreach (var b in Contents)
                    {
                        if ((b & 0x80) == 0x80)
                        {
                            enc.Add(27);
                            enc.Add(Convert.ToByte(b & 0x7F));
                        }
                        else
                            enc.Add(b);
                    }
                    _contents7BitEncoded = enc.ToArray();
                }
                return _contents7BitEncoded;
            }
        }

        public void ConvertContentsFromURL()
        {
            string url = (URL ?? "").Trim().Split(':').FirstOrDefault(p => p.Length == 1167 || p.Length == 1120);
            if (url == null)
            {
                Contents = Encoding.ASCII.GetBytes(new string(' ', 1000));
                return;
            }
            var cc = new byte[1000];
            string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
            for (int i = 0; i < url.Length; i++)
            {
                int val = alphabet.IndexOf(url[i]);
                if (val == -1)
                {
                    Contents = Encoding.ASCII.GetBytes(new string(' ', 1000));
                    return;
                }
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
            if (url.Length == 1120)
                for (int i = 960; i < 1000; i++)
                    cc[i] = 32;
            for (int i = 0; i < cc.Length; i++)
                if (cc[i] < 32)
                    cc[i] |= 128;
            Contents = cc;
        }

        public static byte[] Pad(byte[] Bytes, int Length, byte Value = 32)
        {
            var before = Bytes.Length;
            Array.Resize<byte>(ref Bytes, Length);
            for (int i = before; i < Bytes.Length; i++)
                Bytes[i] = Value;
            return Bytes;
        }

        public byte GetByte(int X, int Y)
        {
            return Contents[X + (Y * 40)];
        }

        public void SetByte(int X, int Y, byte Value)
        {
            _contents[X + (Y * 40)] = Value;
            _contents7BitEncoded = null;
        }

        public virtual void Fixup()
        {
        }
    }
}
