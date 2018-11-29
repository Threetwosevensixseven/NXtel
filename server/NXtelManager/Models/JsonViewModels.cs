using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using NXtelData;

namespace NXtelManager.Models
{
    public class GetDataViewModel
    {
        public int PageID { get; set; }
        public string PageNo { get; set; }
        public string Frame { get; set; }
        public bool NextPage { get; set; }
        public bool NextFrame { get; set; }
        public string GoesToPageFrameDesc { get; set; }

        public GetDataViewModel()
        {
            PageID = -1;
            PageNo = Frame = GoesToPageFrameDesc = "";
        }
    }
}