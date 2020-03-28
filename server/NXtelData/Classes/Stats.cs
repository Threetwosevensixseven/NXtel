using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Stats
    {
        public DateTime Timestamp { get; set; }
        public IPAddress IPAddress { get; set; }
        public int PageNo { get; set; }
        public int FrameNo { get; set; }
        public string ClientHash { get; set; }

        public Stats(DateTime timestamp, string ipAddress, string Page, string Frame)
        {
            Timestamp = timestamp;
            int pageNo;
            int.TryParse(Page, out pageNo);
            if (pageNo < 0)
                throw new InvalidDataException("Invalid page number");
            PageNo = pageNo;
            int frameNo = ((Frame ?? "").Trim()+ " ")[0] - 'a';
            if (frameNo < 0 || frameNo > 25)
                throw new InvalidDataException("Invalid frame number");
            FrameNo = frameNo;
            IPAddress = IPAddress.Parse(ipAddress);
            ClientHash = IPEndPointExtensions.CalculateHash(ipAddress);
        }

        public static bool Update(IPEndPoint EndPoint, Page Page)
        {
            if (EndPoint == null || EndPoint.Address == null || Page == null || Page.PageNo < 0 || Page.FrameNo < 0)
                return false;
            return Update(DateTime.Now, EndPoint.Address.ToString(), Page.PageNo, Page.FrameNo);
        }

        public bool Update()
        {
            if (IPAddress == null)
                return false;
            return Update(Timestamp, IPAddress.ToString(), PageNo, FrameNo);
        }

        public static bool Update(DateTime Timestamp, string IPAddress, int Page, int Frame)
        {
            if (Timestamp == DateTime.MinValue || string.IsNullOrWhiteSpace(IPAddress) || (Page < 0 && Frame < 0))
                return false;
            uint ip = IPEndPointExtensions.ToUint32(IPAddress);
            if (ip == 0)
                return false;
            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string hash = IPEndPointExtensions.CalculateHash(IPAddress);
            string sql = @"INSERT INTO stats (ClientHash,Timestamp,PageNo,FrameNo) 
                VALUES (@ClientHash,@Timestamp,@PageNo,@FrameNo);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("ClientHash", hash);
            cmd.Parameters.AddWithValue("Timestamp", Timestamp);
            cmd.Parameters.AddWithValue("PageNo", Page);
            cmd.Parameters.AddWithValue("FrameNo", Frame);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }

        public static string Connect(IPEndPoint EndPoint, out DateTime LastSeen)
        {
            LastSeen = DateTime.MinValue;
            if (EndPoint == null || EndPoint.Address == null)
                return "";
            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            uint ip = IPEndPointExtensions.ToUint32(EndPoint);
            string hash = IPEndPointExtensions.CalculateHash(EndPoint);
            string sql = @"INSERT IGNORE INTO geo (ClientHash,IPAddress) VALUES (@ClientHash,@IPAddress);";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("ClientHash", hash);
                cmd.Parameters.AddWithValue("IPAddress", ip);
                cmd.ExecuteNonQuery();
                cmd.CommandText = @"UPDATE geo gg
                    JOIN geo g ON gg.ClientHash=g.ClientHash
                    SET gg.IPAddress=@IPAddress
                    WHERE g.IPAddress IS NULL
                    AND g.Geo IS NULL
                    AND g.ClientHash=@ClientHash;";
                cmd.ExecuteNonQuery();
            }

            sql = @"SELECT MAX(`Timestamp`) AS ts
                FROM stats
                WHERE ClientHash=@ClientHash;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("ClientHash", hash);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        LastSeen = rdr.GetDateTimeSafe("ts");
                        break;
                    }
                }
            }

            if (openConX)
                ConX.Close();

            return hash;
        }
    }
}
