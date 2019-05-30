using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public static class Stats
    {
        public static bool Update(IPEndPoint EndPoint, Page Page)
        {
            if (EndPoint == null || Page == null || Page.PageNo < 0 || Page.FrameNo < 0)
                return false;
            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"INSERT INTO stats (ClientHash,PageNo,FrameNo) VALUES (@ClientHash,@PageNo,@FrameNo);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("ClientHash", EndPoint.CalculateHash());
            cmd.Parameters.AddWithValue("PageNo", Page.PageNo);
            cmd.Parameters.AddWithValue("FrameNo", Page.FrameNo);
            cmd.ExecuteNonQuery();

            sql = @"INSERT IGNORE INTO geo (ClientHash,IPAddress) VALUES (@ClientHash,@IPAddress);";
            cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("ClientHash", EndPoint.CalculateHash());
            cmd.Parameters.AddWithValue("IPAddress", EndPoint.ToUint32());
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }
    }
}
