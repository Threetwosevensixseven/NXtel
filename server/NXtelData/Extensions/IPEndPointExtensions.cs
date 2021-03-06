﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using NXtelData;

namespace System.Net
{
    public static class IPEndPointExtensions
    {
        private static MD5 _md5;
        private static Dictionary<string, string> _dic = new Dictionary<string, string>();

        public static string CalculateHash(this IPEndPoint EndPoint)
        {
            if (EndPoint == null || EndPoint.Address == null)
                return "";
            return CalculateHash(EndPoint.Address.ToString());
        }

        public static string CalculateHash(string IPAddress)
        {
            if (string.IsNullOrWhiteSpace(IPAddress))
                return "";
            if (_dic.ContainsKey(IPAddress))
                return _dic[IPAddress];
            if (_md5 == null)
                _md5 = MD5.Create();
            var bs = _md5.ComputeHash(Encoding.UTF8.GetBytes(Options.HashSalt + IPAddress));
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < bs.Length; i++)
                sb.Append(bs[i].ToString("x2"));
            string val = sb.ToString();
            try // Thread-safety. Faster than locking on an object
            {
                _dic.Add(IPAddress, val);
            }
            catch { }
            return val;
        }

        public static uint ToUint32(this IPEndPoint EndPoint)
        {
            if (EndPoint == null || EndPoint.Address == null)
                return 0;
            var ipAddress = IPAddress.Parse(EndPoint.Address.ToString());
            var ipBytes = ipAddress.GetAddressBytes();
            uint ip = (uint)ipBytes[0] << 24;
            ip += (uint)ipBytes[1] << 16;
            ip += (uint)ipBytes[2] << 8;
            ip += (uint)ipBytes[3];
            return ip;
        }

        public static uint ToUint32(string Address)
        {
            if (string.IsNullOrWhiteSpace(Address))
                return 0;
            var ipAddress = IPAddress.Parse(Address.ToString());
            var ipBytes = ipAddress.GetAddressBytes();
            uint ip = (uint)ipBytes[0] << 24;
            ip += (uint)ipBytes[1] << 16;
            ip += (uint)ipBytes[2] << 8;
            ip += (uint)ipBytes[3];
            return ip;
        }
    }
}
