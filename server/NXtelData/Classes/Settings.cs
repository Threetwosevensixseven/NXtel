using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Serialization;

namespace NXtelData
{
    public class Settings
    {
        private string appDir;

        public string ConnectionString { get; set; }

        public Settings()
        {
        }

        public Settings(string AppDir)
        {
            appDir = AppDir;
        }

        public Settings Load()
        {
            Settings settings;
            try
            {
                string xml = File.ReadAllText(FileName);
                var reader = new StringReader(xml);
                using (reader)
                {
                    var serializer = new XmlSerializer(typeof(Settings));
                    settings = (Settings)serializer.Deserialize(reader);
                    reader.Close();
                }
                settings.appDir = appDir;
            }
            catch
            {
                settings = new Settings(appDir);
            }
            return settings;
        }

        public string ToXML()
        {
            var serializer = new XmlSerializer(GetType());
            var writer = new StreamWriter(FileName);
            using (writer)
            {
                serializer.Serialize(writer, this);
                writer.Close();
            }
            return writer.ToString();
        }

        private string FileName
        {
            get
            {
                return Path.Combine(appDir, "Settings.xml");
            }
        }

        public string DatabaseName
        {
            get
            {
                var r = new Regex(@"database\s*=\s*(?<DB>.*?)\s*(?:;|$)", RegexOptions.IgnoreCase);
                var m = r.Match(ConnectionString);
                if (!m.Success)
                    return "";
                return (m.Groups["DB"].Value ?? "").Trim();
            }
        }
    }
}
