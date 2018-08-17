using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Template : PageBase
    {
        public int TemplateID { get; set; }
        public string Description { get; set; }
        public byte X { get; set; }
        public byte Y { get; set; }
        public int Size { get; set; }
        public byte? DateX { get; set; }
        public byte? DateY { get; set; }
        public byte? TimeX { get; set; }
        public byte? TimeY { get; set; }
        public byte? ContainerX { get; set; }
        public byte? ContainerY { get; set; }
        public byte? ContainerW { get; set; }
        public byte? ContainerH { get; set; }

        public Template()
        {
            TemplateID = -1;
            Description = "";
        }

        public static Template Load(int TemplateID)
        {
            var item = new Template();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM template WHERE TemplateID=" + TemplateID;
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                        break;
                    }
                }
            }
            return item;
        }

        public static int Save(Template Template)
        {
            if (Template == null)
                return -1;
            //using (var con = new MySqlConnection(DBOps.ConnectionString))
            //{
            //    con.Open();
            //    var key = Page.TemplateID <= 0 ? "" : "TemplateID,";
            //    var val = Page.TemplateID <= 0 ? "" : "@TemplateID,";
            //    string sql = @"INSERT INTO template
            //        (" + key + @"PageNo,Seq,Title,Contents,BoxMode,URL)
            //        VALUES(" + val + @"@PageNo,@Seq,@Title,@Contents,@BoxMode,@URL)
            //        ON DUPLICATE KEY UPDATE
            //        PageNo=@PageNo,Seq=@Seq,Title=@Title,BoxMode=@BoxMode,URL=@URL;
            //        SELECT LAST_INSERT_ID();";
            //    var cmd = new MySqlCommand(sql, con);
            //    cmd.Parameters.AddWithValue("PageID", Page.TemplateID);
            //    cmd.Parameters.AddWithValue("PageNo", Page.PageNo);
            //    cmd.Parameters.AddWithValue("Seq", Page.FrameNo);
            //    cmd.Parameters.AddWithValue("Title", (Page.Title ?? "").Trim());
            //    cmd.Parameters.AddWithValue("BoxMode", Page.BoxMode);
            //    cmd.Parameters.AddWithValue("URL", (Page.URL ?? "").Trim());
            //    var rv = cmd.ExecuteScalar();
            //    if (rv.GetType() == typeof(int))
            //        return (int)rv;
            //    else
                    return -1;
            //}
        }

        public void Read(MySqlDataReader rdr)
        {
            this.TemplateID = rdr.GetInt32("TemplateID");
            this.Description = rdr.GetString("Description").Trim();
            this.X = rdr.GetByte("X");
            this.Y = rdr.GetByte("Y");
            this.Size = rdr.GetInt32("Size");
            this.DateX = rdr.GetByteNullable("DateX");
            this.DateY = rdr.GetByteNullable("DateY");
            this.TimeX = rdr.GetByteNullable("TimeX");
            this.TimeY = rdr.GetByteNullable("TimeY");
            this.ContainerX = rdr.GetByteNullable("ContainerX");
            this.ContainerY = rdr.GetByteNullable("ContainerY");
            this.ContainerW = rdr.GetByteNullable("ContainerW");
            this.ContainerH = rdr.GetByteNullable("ContainerH");
            this.Contents = rdr.GetBytesNullable("Contents");
            this.URL = rdr.GetStringNullable("URL").Trim();
            this.ConvertContentsFromURL();
        }
    }
}
