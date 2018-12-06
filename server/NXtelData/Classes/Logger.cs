using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace NXtelData
{
    public static class Logger
    {
        public static void Log(string Message, object Object = null)
        {
            string fileName = Options.LogFile;
            try
            {
                string ts = (DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff") + ": ");
                string str = ts + (Message ?? "");
                string obj = "";
                if (Object != null)
                {
                    str = str.Replace(" = ", "=").Replace("= ", "=").Replace(" =", "=");
                    if (str.EndsWith("=")) str = str.TrimEnd('=');
                    else if (Object.GetType() == typeof(string)) obj = Object.ToString();
                    else if (Object.GetType().IsPrimitive) obj = Object.ToString();
                    else obj = JsonConvert.SerializeObject(Object, new IsoDateTimeConverter());
                    str += " = " + obj;
                }
                File.AppendAllText(fileName, str + "\r\n");
            }
            catch (Exception /*ex*/)
            {
            }
        }
    }
}
