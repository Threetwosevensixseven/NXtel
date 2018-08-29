using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Routes : List<Route>
    {
        private static Routes _masterList;

        public static Routes MasterList
        {
            get
            {
                if (_masterList == null)
                {
                    _masterList = new Routes();
                    _masterList.Add(new Route(95, "Enter"));
                    _masterList.Add(new Route('0'));
                    _masterList.Add(new Route('1'));
                    _masterList.Add(new Route('2'));
                    _masterList.Add(new Route('3'));
                    _masterList.Add(new Route('4'));
                    _masterList.Add(new Route('5'));
                    _masterList.Add(new Route('6'));
                    _masterList.Add(new Route('7'));
                    _masterList.Add(new Route('8'));
                    _masterList.Add(new Route('9'));
                }
                return _masterList;
            }
        }

        public static Routes LoadForPage(int PageID, MySqlConnection ConX = null)
        {
            var sorted = new List<Route>();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT * 
                FROM route
                WHERE PageID=" + PageID + @"
                ORDER BY KeyCode;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Route();
                    item.Read(rdr);
                    sorted.Add(item);
                }
            }
            

            if (openConX)
                ConX.Close();

            sorted = sorted.OrderBy(r => r.Sort).ToList();
            var list = new Routes();
            list.AddRange(sorted);
            return list;
        }

        public bool DeleteForPage(int PageID, out string Err, MySqlConnection ConX = null)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"DELETE FROM route WHERE PageID=" + PageID;
                var cmd = new MySqlCommand(sql, ConX);
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }


        public bool SaveForPage(int PageID, out string Err, MySqlConnection ConX = null)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                var rv = DeleteForPage(PageID, out Err, ConX);
                if (!string.IsNullOrWhiteSpace(Err))
                    return false;
                foreach (var item in this)
                    item.SaveForPage(PageID, ConX);
                return true;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }
    }
}
