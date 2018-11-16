using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Data;
using System.Data.SqlTypes;

namespace NXtelData
{
    public class DebugLogger : IDebugLogger, IDisposable
    {
        private readonly StreamWriter _debugWriter = null;
        public string FileName { get; private set; }

        public DebugLogger(string Topic, int CalledFromStackLevel = 1, bool LogStackToDetermineCalledFromStackLevel = false)
        {
            try
            {
                bool DebugLogOn = ConfigurationManager.AppSettings["EnableDebugLog"] == "ON";
                _debugWriter = null;
                if (DebugLogOn)
                {
                    string LogDirectory = (ConfigurationManager.AppSettings["DebugLogDirectory"] ?? "").Trim();
                    if (!Directory.Exists(LogDirectory)) Directory.CreateDirectory(LogDirectory);
                    string guid = Guid.NewGuid().ToString();
                    if (string.IsNullOrWhiteSpace(Topic)) Topic = "DebugLog";
                    Topic = Topic.Trim() + "_";
                    FileName = Path.Combine(LogDirectory, Topic + guid + ".txt");
                    _debugWriter = new StreamWriter(File.Open(FileName, FileMode.Create));
                    DebugLoggerExtensions.Log(this, "Starting logging...");
                    if (LogStackToDetermineCalledFromStackLevel)
                    {
                        int i = 0;
                        foreach (var frame in new StackTrace().GetFrames())
                        {
                            DebugLoggerExtensions.Log(this, "Stack Frame " + i + " = " + GetStackMethod(frame));
                            i++;
                        }
                    }
                    DebugLoggerExtensions.Log(this, "Called from " + GetStackMethod(new StackTrace().GetFrame(CalledFromStackLevel)) + ".");
                }
            }
            catch
            {
            }
        }

        private string GetStackMethod(StackFrame Frame)
        {
            if (Frame == null)
                return "null";
            var method = Frame.GetMethod();
            return method == null ? "null" : ((method.ReflectedType == null ? "null"
                : (method.ReflectedType.Name ?? "null")) + "." + (method.Name ?? "null"));
        }

        void IDebugLogger.Log(string Message)
        {
            Log(Message, null, false, true);
        }

        void IDebugLogger.Log(string Message, object Object)
        {
            Log(Message, Object, true, true);
        }

        void IDebugLogger.LogWithoutTimestamp(string Message)
        {
            Log(Message, null, false, false);
        }

        void IDebugLogger.LogWithoutTimestamp(string Message, object Object)
        {
            Log(Message, Object, true, false);
        }

        private void Log(string Message, object Object, bool SerializeObject, bool WithTimestamp)
        {
            try
            {
                if (_debugWriter == null) return;
                DateTime now = DateTime.Now;
                string ts = WithTimestamp ? (now.ToString("yyyy-MM-dd HH:mm:ss.fff") + ": ") : "";
                var str = ts + (Message ?? "");
                if (SerializeObject)
                {
                    str = str.Replace(" = ", "=").Replace("= ", "=").Replace(" =", "=");
                    if (str.EndsWith("=")) str = str.TrimEnd('=');
                    string obj;
                    if (Object == null) obj = "null";
                    else if (Object.GetType() == typeof(string)) obj = Object.ToString();
                    else if (Object.GetType().IsPrimitive) obj = Object.ToString();
                    else obj = JsonConvert.SerializeObject(Object, new IsoDateTimeConverter());
                    str += " = " + obj;
                }
                _debugWriter.WriteLine(str);
            }
            catch
            {
            }
        }

        #region IDisposable

        private bool disposedValue = false;

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    try
                    {
                        if (_debugWriter != null)
                        {
                            DebugLoggerExtensions.Log(this, "Stopping logging.");
                            _debugWriter.Close();
                        }
                    }
                    catch
                    {
                    }
                }
                disposedValue = true;
            }
        }


        public void Dispose()
        {
            Dispose(true);
        }

        #endregion
    }

    public interface IDebugLogger
    {
        void Log(string Message);
        void Log(string Message, object Object);
        void LogWithoutTimestamp(string Message);
        void LogWithoutTimestamp(string Message, object Object);
    }

    public static class DebugLoggerExtensions
    {
        public static void Log(this DebugLogger Logger, string Message)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).Log(Message);
            }
            catch
            {
            }
        }

        public static void Log(this DebugLogger Logger, string Message, object Object)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).Log(Message, Object);
            }
            catch
            {
            }
        }

        public static void LogWithoutTimestamp(this DebugLogger Logger, string Message)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).LogWithoutTimestamp(Message);
            }
            catch
            {
            }
        }

        public static void LogWithoutTimestamp(this DebugLogger Logger, string Message, object Object)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).LogWithoutTimestamp(Message, Object);
            }
            catch
            {
            }
        }

        public static void Logsql(this DebugLogger Logger, string SectionName, params string[] Messages)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).LogWithoutTimestamp((SectionName ?? "").Trim() + ".SQL START ======================================================================");
                foreach (string message in (Messages ?? new string[0]))
                    ((IDebugLogger)Logger).LogWithoutTimestamp(message ?? "");
                ((IDebugLogger)Logger).LogWithoutTimestamp((SectionName ?? "").Trim() + ".SQL END ========================================================================");
            }
            catch
            {
            }
        }

        public static void Logsql(this DebugLogger Logger, string SectionName, SqlCommand Command)
        {
            try
            {
                if (Logger == null)
                    return;
                ((IDebugLogger)Logger).LogWithoutTimestamp((SectionName ?? "").Trim() + ".SQL START ======================================================================");
                if (Command != null)
                {
                    if (Command.Parameters != null)
                    {
                        foreach (SqlParameter p in Command.Parameters)
                        {
                            string msg = "DECLARE @" + p.ParameterName + " " + p.SqlDbType.ToString();
                            if (p.Size > 0)
                            {
                                msg += "(" + p.Size;
                                if (p.Precision > 0)
                                    msg += "," + p.Precision;
                                msg += ")";
                            }
                            msg += "=" + QuoteValue(p.SqlDbType, p.Value) + ";";
                            ((IDebugLogger)Logger).LogWithoutTimestamp(msg ?? "");
                        }
                    }

                    ((IDebugLogger)Logger).LogWithoutTimestamp(Command.CommandText ?? "");
                }
                ((IDebugLogger)Logger).LogWithoutTimestamp((SectionName ?? "").Trim() + ".SQL END ========================================================================");
            }
            catch
            {
            }
        }

        private static string QuoteValue(SqlDbType Type, object Value)
        {
            if (Value == null || Value == DBNull.Value)
                return "NULL";
            if (Type == SqlDbType.Char || Type == SqlDbType.NChar || Type == SqlDbType.NText || Type == SqlDbType.NVarChar || Type == SqlDbType.Text || Type == SqlDbType.VarChar || Type == SqlDbType.Xml)
                return "'" + Value.ToString() + "'";
            if (Type == SqlDbType.Date || Type == SqlDbType.DateTime || Type == SqlDbType.DateTime2 || Type == SqlDbType.DateTimeOffset || Type == SqlDbType.SmallDateTime || Type == SqlDbType.Time || Type == SqlDbType.Timestamp)
                return "'" + new SqlDateTime((DateTime)Value).ToString() + "'";
            return Value.ToString();
        }

        public static string Declare(this DebugLogger Logger, string Name, DateTime? Value)
        {
            try
            {
                if (Logger == null)
                    return "";
                if (Value == null)
                    return "DECLARE @" + (Name ?? "p") + " datetime=NULL;";
                else
                    return "DECLARE @" + (Name ?? "p") + " datetime='" + Value.Value.ToString("yyyy-MM-dd HH:mm:ss.fff") + "';";
            }
            catch
            {
                return "";
            }
        }
    }
}