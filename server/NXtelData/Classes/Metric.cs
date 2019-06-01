using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Metric
    {
        public int? ClientCount { get; set; }
        public int? PageCount { get; set; }
        public int? DayCount { get; set; }
        public int? PopularPageNo { get; set; }
        public int? PopularCount { get; set; }
        public DateTime? Day { get; set; }
        public Dictionary<DateTime, Metric> DailyMetrics { get; set; }

        public static Metric Calculate(/*MySqlConnection ConX = null*/)
        {
            var rv = new Metric();
            rv.DailyMetrics = new Dictionary<DateTime, Metric>();

            MySqlConnection ConX = null;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            // Total unique client count
            string sql = @"SELECT COUNT(*) AS cnt from (
                SELECT ClientHash
                FROM stats
                GROUP BY ClientHash
            ) AS clients;";

            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    rv.ClientCount = rdr.GetInt32Safe("cnt");
                    break;
                }
            }

            // Total unique page count
            sql = @"SELECT COUNT(*) AS cnt from (
                    SELECT PageNo,COUNT(*) AS cnt
                    FROM stats
                    GROUP BY PageNo
                ) AS pages;";
            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    rv.PageCount = rdr.GetInt32Safe("cnt");
                    break;
                }
            }

            // Total unique day count
            sql = @"SELECT COUNT(*) AS cnt from (
                    SELECT DATE(`Timestamp`) AS dt,COUNT(*) AS cnt
                    FROM stats
                    GROUP BY dt
                ) AS days;";
            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    rv.DayCount = rdr.GetInt32Safe("cnt");
                    break;
                }
            }

            // Unique client count per day
            sql = @"SELECT dt,COUNT(*) AS cnt from (
                    SELECT DATE(`Timestamp`) AS dt,ClientHash,COUNT(*) AS cnt
                    FROM stats
                    GROUP BY dt,ClientHash
                ) AS clientdays
                GROUP BY dt
                ORDER BY dt DESC;";
            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var dt = rdr.GetDateTime("dt");
                    if (!rv.DailyMetrics.ContainsKey(dt))
                        rv.DailyMetrics.Add(dt, new Metric());
                    rv.DailyMetrics[dt].ClientCount = rdr.GetInt32Safe("cnt");
                }
            }

            // Unique page count per day
            sql = @"SELECT dt,COUNT(*) AS cnt from (
                    SELECT DATE(`Timestamp`) AS dt,PageNo,COUNT(*) AS cnt
                    FROM stats
                    GROUP BY dt,PageNo
                ) AS clientpages
                GROUP BY dt
                ORDER BY dt DESC;";
            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var dt = rdr.GetDateTime("dt");
                    if (!rv.DailyMetrics.ContainsKey(dt))
                        rv.DailyMetrics.Add(dt, new Metric());
                    rv.DailyMetrics[dt].PageCount = rdr.GetInt32Safe("cnt");
                }
            }

            // Most popular page per day
            sql = @"SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
                SELECT dt,MAX(ky) AS mx FROM (
                    SELECT dt,PageNo,
                    CAST(CONCAT(dt,'-',LPAD(CAST(COUNT(*) AS char),11,'0'),'-',LPAD(CAST(PageNo AS char),11,'0')) AS char) AS ky
                     FROM (
                        SELECT DATE(`Timestamp`) AS dt,PageNo
                        FROM stats
                        WHERE PageNo NOT IN(0,1)
                        GROUP BY dt,PageNo,ClientHash
                    ) AS daysclientspages
                    GROUP BY dt,PageNo
                ) AS dayspages
                GROUP BY dt
                ORDER BY dt DESC;";
            using (var cmd = new MySqlCommand(sql, ConX))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var dt = rdr.GetDateTime("dt");
                    if (!rv.DailyMetrics.ContainsKey(dt))
                        rv.DailyMetrics.Add(dt, new Metric());
                    string val = rdr.GetStringNullable("mx");
                    string c = val.Substring(11, 11);
                    string p = val.Substring(23, 11);
                    int count, page;
                    if (int.TryParse(c, out count))
                        rv.DailyMetrics[dt].PopularCount = count;
                    if (int.TryParse(p, out page))
                        rv.DailyMetrics[dt].PopularPageNo = page;
                }
            }

            if (openConX)
                ConX.Close();

            return rv;
        }

        public static string Format(int? Value)
        {
            if (Value == null)
                return "";
            return ((int)Value).ToString("N0");
        }
    }
}
