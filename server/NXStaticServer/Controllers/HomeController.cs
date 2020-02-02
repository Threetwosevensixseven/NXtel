using System.Web.Mvc;

namespace NXStaticServer.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            var auth = (Request.Url.Authority ?? "").Trim().ToLower();
            if (auth.Contains("time"))
                return Redirect("https://github.com/Threetwosevensixseven/nxtp/wiki/FAQ");
            else if (auth.Contains("nget"))
                return Redirect("https://github.com/Threetwosevensixseven/nget/wiki/FAQ");
            else
                return Redirect("https://github.com/Threetwosevensixseven/NXtel/wiki/FAQ");
        }

        public ActionResult NXtelDashboard()
        {
            return Redirect("http://dashboard.nxtel.org/");
        }

        public ActionResult NXtelInfo()
        {
            return Redirect("https://github.com/Threetwosevensixseven/NXtel/wiki/FAQ");
        }

        public ActionResult NXTPInfo()
        {
            return Redirect("https://github.com/Threetwosevensixseven/nxtp/wiki/FAQ");
        }

    }
}