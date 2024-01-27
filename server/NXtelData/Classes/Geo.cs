using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;

namespace NXtelData
{
    public class Geo
    {
        public string ClientHash { get; set; }
        public IPAddress IPAddress { get; set; }
        public decimal? lat { get; set; }
        public decimal? lon { get; set; }
        public string status { get; set; }

        public static List<Geo> Load()
        {
            var list = new List<Geo>();
            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"SELECT ClientHash,IPAddress
                    FROM geo
                    WHERE IPAddress IS NOT NULL
                    AND Geo IS NULL;";
                using (var cmd = new MySqlCommand(sql, ConX))
                {
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var item = new Geo();
                            item.ClientHash = (rdr.GetStringNullable("ClientHash") ?? "").Trim();
                            uint ip = rdr.GetUint32Safe("IPAddress");
                            byte a = (byte)((ip >> 24) & 255);
                            byte b = (byte)((ip >> 16) & 255);
                            byte c = (byte)((ip >> 8) & 255);
                            byte d = (byte)(ip & 255);
                            string addr = a.ToString() + "." + b.ToString() + "." + c.ToString() + "." + d.ToString();
                            try
                            {
                                item.IPAddress = IPAddress.Parse(addr);
                                list.Add(item);
                            }
                            catch { }
                        }
                    }
                }
            }
            catch (Exception /*ex*/)
            {
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
            return list;
        }

        public bool Lookup()
        {
            var url = Options.GeoEndpoint.Replace("{{IP}}", (IPAddress ?? IPAddress.Parse("127.0.0.1")).ToString());
            var resp = LoadJson<Geo>(url);
            status = (resp.status ?? "").Trim().ToLower();
            lat = resp.lat;
            lon = resp.lon;
            return status == "success" && lat != null && lon != null;
        }

        public bool Save()
        {
            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string geo = "NULL";
            if (lat != null && lon != null)
                geo = "POINT(" + lat + "," + lon + ")";
            string sql = @"UPDATE geo
                SET GEO=" + geo + @",
                IPAddress=NULL
                WHERE ClientHash=@ClientHash;";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("ClientHash", ClientHash);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }

        private static T LoadJson<T>(string URL)
        {
            string EmptyJSON = "{}";
            var wr = WebRequest.Create(URL) as HttpWebRequest;
            wr.Method = "GET";
            ((HttpWebRequest)wr).Accept = "application/json";
            WebResponse httpResponse = null;
            try
            {
                string json = "";
                try
                {
                    httpResponse = wr.GetResponse();
                }
                catch (WebException wex)
                {
                    if (wex.Response != null)
                    {
                        using (var errorResponse = (HttpWebResponse)wex.Response)
                        {
                            using (var reader = new StreamReader(errorResponse.GetResponseStream()))
                            {
                                json = reader.ReadToEnd();
                            }
                        }
                    }
                }
                catch (Exception /*ex*/)
                {
                    var obj2 = JsonConvert.DeserializeObject<T>(EmptyJSON);
                    return obj2;
                }
                if (string.IsNullOrWhiteSpace(json))
                {
                    using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                    {
                        json = streamReader.ReadToEnd() ?? "";
                    }
                }
                var obj = JsonConvert.DeserializeObject<T>(json);
                return obj;
            }
            catch (Exception /*ex*/)
            {
                var obj = JsonConvert.DeserializeObject<T>(EmptyJSON);
                return obj;
            }
        }
    }
}
