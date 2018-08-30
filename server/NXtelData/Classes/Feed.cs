using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Feed
    {
        public string URL { get; set; }
        public string XML { get; set; }
        public DateTime LastUpdated { get; set; }
        public FeedItems Items { get; set; }

        public Feed()
        {
            URL = XML = string.Empty;
            LastUpdated = DateTime.MinValue;
            Items = new FeedItems();
        }

        public static Feed Load(string URL, string Expression, MySqlConnection ConX = null)
        {
            var feed = new Feed();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = "SELECT * FROM feed WHERE FeedURL=@FeedURL;";
                using (var cmd = new MySqlCommand(sql, ConX))
                {
                    cmd.Parameters.AddWithValue("FeedURL", (URL ?? "").Trim().ToLower());
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            feed.Read(URL, rdr);
                            break;
                        }
                    }
                }
                if (!string.IsNullOrWhiteSpace(URL) && feed.LastUpdated < DateTime.Now.AddMinutes(-Options.UpdateFeedMins))
                {
                    var doc = new XmlDocument();
                    doc.Load(URL);
                    feed.URL = (URL ?? "").Trim().ToLower();
                    feed.XML = doc.InnerXml;
                    feed.LastUpdated = DateTime.Now;
                    feed.Save();
                    feed.Items.Load(doc, Expression);
                }
                else
                {
                    feed.Items.Load(feed.XML, Expression);
                }
            }
            catch (Exception ex)
            {

            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
            return feed;
        }

        public void Read(string URL, MySqlDataReader rdr)
        {
            this.URL = (URL ?? "").Trim().ToLower();
            this.XML = (rdr.GetStringNullable("XML") ?? "").Trim();
            this.LastUpdated = rdr.GetDateTime("LastUpdated");
        }

        public bool Save(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"INSERT INTO feed
                    (FeedURL,`XML`,LastUpdated)
                    VALUES (@FeedURL,@XML,@LastUpdated)
                    ON DUPLICATE KEY UPDATE
                    FeedURL=@FeedURL,XML=@XML,LastUpdated=@LastUpdated;";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("FeedURL", URL);
                cmd.Parameters.AddWithValue("XML", XML);
                cmd.Parameters.AddWithValue("LastUpdated", DateTime.Now);
                return cmd.ExecuteNonQuery() >= 1;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }
    }
}
