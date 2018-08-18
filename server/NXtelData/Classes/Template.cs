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
        public byte Width { get; set; }
        public byte Height { get; set; }
        public string Expression { get; set; }

        public Template()
        {
            TemplateID = -1;
            Description = Expression = "";
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

        public static bool Save(Template Template, out string Err)
        {
            Err = "";
            try
            {
                if (Template.TemplateID <= 0)
                    return Template.Create(out Err);
                else
                    return Template.Update(out Err);
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Create(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"INSERT INTO template
                    (Description,X,Y,Width,Height,Expression,URL,Contents)
                    VALUES(@Description,@X,@Y,@Width,@Height,@Expression,@URL,@Contents);
                    SELECT LAST_INSERT_ID();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                    cmd.Parameters.AddWithValue("X", X);
                    cmd.Parameters.AddWithValue("Y", Y);
                    cmd.Parameters.AddWithValue("Width", Width);
                    cmd.Parameters.AddWithValue("Height", Height);
                    cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv > 0)
                        TemplateID = rv;
                    if (TemplateID <= 0)
                        Err = "The template could not be saved.";
                    return TemplateID > 0;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Update(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"UPDATE template
                    SET Description=@Description,X=@X,Y=@Y,Width=@Width,Height=@Height,
                    Expression=@Expression,URL=@URL,Contents=@Contents
                    WHERE TemplateID=@TemplateID;
                    SELECT ROW_COUNT();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("TemplateID", TemplateID);
                    cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                    cmd.Parameters.AddWithValue("X", X);
                    cmd.Parameters.AddWithValue("Y", Y);
                    cmd.Parameters.AddWithValue("Width", Width);
                    cmd.Parameters.AddWithValue("Height", Height);
                    cmd.Parameters.AddWithValue("Expression", (Expression ?? "").Trim());
                    cmd.Parameters.AddWithValue("URL", (URL ?? "").Trim());
                    cmd.Parameters.AddWithValue("Contents", Contents);
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv <= 0)
                        Err = "The template could not be saved.";
                    return rv > 0;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Delete(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"DELETE FROM template
                    WHERE TemplateID=@TemplateID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("TemplateID", TemplateID);
                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public void Read(MySqlDataReader rdr)
        {
            this.TemplateID = rdr.GetInt32("TemplateID");
            this.Description = rdr.GetString("Description").Trim();
            this.X = rdr.GetByte("X");
            this.Y = rdr.GetByte("Y");
            this.Width = rdr.GetByte("Width");
            this.Height = rdr.GetByte("Height");
            this.Expression = rdr.GetStringNullable("Expression").Trim();
            this.Contents = rdr.GetBytesNullable("Contents");
            this.URL = rdr.GetStringNullable("URL").Trim();
            this.ConvertContentsFromURL();
        }
    }
}
