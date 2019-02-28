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
                    _masterList.Add(new Route(RouteKeys.Enter, "Enter"));
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
                    _masterList.Add(new Route(RouteKeys.Blue, "Blue"));
                    _masterList.Add(new Route(RouteKeys.Red, "Red"));
                    _masterList.Add(new Route(RouteKeys.Magenta, "Magenta"));
                    _masterList.Add(new Route(RouteKeys.Green, "Green"));
                    _masterList.Add(new Route(RouteKeys.Cyan, "Cyan"));
                    _masterList.Add(new Route(RouteKeys.Yellow, "Yellow"));
                    _masterList.Add(new Route(RouteKeys.White, "White"));
                    _masterList.Add(new Route(RouteKeys.Black, "Black"));
                    _masterList.Add(new Route(RouteKeys.Carousel, "Carousel"));
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

            string sql = @"SELECT r.*,p.PageNo AS CurrentPageNo,p.FrameNo AS CurrentFrameNo,
                dp.PageID AS DirectPageID,dp.PageNo AS DirectPageNo,dp.FrameNo AS DirectFrameNo,
                np.PageID AS NextPageID,np.PageNo AS NextPagePageNo,np.FrameNo AS NextPageFrameNo,
                nf.PageID AS NextFrameID,nf.PageNo AS NextFramePageNo,nf.FrameNo AS NextFrameFrameNo
                FROM route r
                JOIN `page` p on p.PageID=r.PageID
                LEFT JOIN `page` dp ON dp.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=r.NextPageNo AND pp.FrameNo=r.NextFrameNo LIMIT 1)
                LEFT JOIN `page` np ON np.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=p.PageNo+1 AND pp.FrameNo=0 LIMIT 1)
                LEFT JOIN `page` nf ON nf.PageID=(SELECT PageID FROM `page` pp WHERE pp.PageNo=p.PageNo AND pp.FrameNo=p.FrameNo+1 LIMIT 1)
                WHERE r.PageID=" + PageID + @"
                ORDER BY r.KeyCode;";
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

        public void AddOrUpdate(byte KeyCode, int NextPageNo, int NextFrameNo)
        {
            var route = this.FirstOrDefault(r => r.KeyCode == KeyCode);
            if (route == null)
            {
                route = new Route();
                route.KeyCode = KeyCode;
                this.Add(route);
            }
            route.NextPageNo = NextPageNo;
            route.NextFrameNo = NextFrameNo;
            route.GoNextPage = false;
            route.GoNextFrame = false;
        }

        public void AddOrUpdate(byte KeyCode, bool GoNextPage, bool GoNextFrame)
        {
            if (GoNextPage && GoNextFrame)
                GoNextPage = false;
            var route = this.FirstOrDefault(r => r.KeyCode == KeyCode);
            if (route == null)
            {
                route = new Route();
                route.KeyCode = KeyCode;
                this.Add(route);
            }
            route.NextPageNo = null;
            route.NextFrameNo = null;
            route.GoNextPage = GoNextPage;
            route.GoNextFrame = GoNextFrame;
        }
    }
}
