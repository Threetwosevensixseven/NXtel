using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using NXtelData;

namespace NXtelManager.Models
{
    public class PageEditModel
    {
        public Page Page { get; set; }
        public IEnumerable<SelectListItem> Templates { get; set; }
        public IEnumerable<SelectListItem> Routes { get; set; }
        public IEnumerable<SelectListItem> Files { get; set; }
        public IEnumerable<SelectListItem> Zones { get; set; }
        public bool SendURL { get; set; }
        public int CopyPageID { get; set; }
        public bool Copying { get; set; }
        public string OldTitle { get; set; }
        public string OldPageNo { get; set; }
        public string OldFrame { get; set; }
        public string OldToPageNo { get; set; }
        public string OldToFrame { get; set; }
        public IEnumerable<SelectListItem> Owners { get; set; }
        public Permissions Permissions { get; set; }

        public Dictionary<string, object> CarouselDic;
        public Dictionary<string, object> FileDic;

        public PageEditModel()
        {
            Templates = GetSelectList(NXtelData.Templates.LoadStubs());
            Routes = GetSelectList(NXtelData.Routes.MasterList);
            Files = GetSelectList(NXtelData.TSFiles.LoadStubs());
            Zones = GetSelectList(NXtelData.Zones.Load());
            Owners = GetSelectList(NXtelData.Users.LoadOwners());
            CarouselDic = new Dictionary<string, object>();
            CarouselDic.Add("maxlength", 2);
            CarouselDic.Add("style", "width:36px;text-align:right;display:inline");
            CarouselDic.Add("class", "form-control input-sm");
            CarouselDic.Add("onkeypress", "javascript:return allownumbers(event);");
            FileDic = new Dictionary<string, object>();
            FileDic.Add("style", "width:auto");
            FileDic.Add("class", "form-control input-sm");
            Permissions = new Permissions();
            //CarouselDic.Add("placeholder", "10");
        }

        public IEnumerable<SelectListItem> GetSelectList(Templates Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.TemplateID.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }

        public IEnumerable<SelectListItem> GetSelectList(Routes Items)
        {
            var rv = new List<SelectListItem>();
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.KeyCode.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }

        public IEnumerable<SelectListItem> GetSelectList(TSFiles Files)
        {
            var rv = new List<SelectListItem>();
            rv.Add(new SelectListItem { Value = "-1", Text = "None" });
            if (Files == null) return rv;
            foreach (var item in Files)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.TeleSoftwareID.ToString(),
                    Text = (item.Key ?? "").Trim()
                });
            }
            return rv;
        }

        public IEnumerable<SelectListItem> GetSelectList(Zones Zones)
        {
            var rv = new List<SelectListItem>();
            //rv.Add(new SelectListItem { Value = "-1", Text = "None" });
            if (Files == null) return rv;
            foreach (var item in Zones)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.ID.ToString(),
                    Text = (item.Description ?? "").Trim()
                });
            }
            return rv;
        }
        public IEnumerable<SelectListItem> GetSelectList(Users Items)
        {
            var rv = new List<SelectListItem>();
            rv.Add(new SelectListItem { Value = "-1", Text = "Unowned" });
            if (Items == null) return rv;
            foreach (var item in Items)
            {
                rv.Add(new SelectListItem
                {
                    Value = item.UserNo.ToString(),
                    Text = (item.Name ?? "").Trim()
                });
            }
            return rv;
        }

        public string GetOwner(int OwnerID)
        {
            var owner = Owners.FirstOrDefault(o => o.Value == OwnerID.ToString());
            return owner == null ? "Unowned" : owner.Text;
        }
    }

    public class PageRouteViewModel
    {
        public int PageID { get; set; }
        public string CurrentPageNo { get; set; }
        public string CurrentFrame { get; set; }
        public string PageNo { get; set; }
        public string Frame { get; set; }
        public bool NextPage { get; set; }
        public bool NextFrame { get; set; }
        public string GoesToPageFrameDesc { get; set; }

        public PageRouteViewModel()
        {
            PageID = -1;
            PageNo = Frame = GoesToPageFrameDesc = "";
        }
    }

}