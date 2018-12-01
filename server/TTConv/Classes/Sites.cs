using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public enum Sites
    {
        [Description("NXtel Page")]
        [URL("https://admin.nxtel.org/Page/Edit/<NewID>#<Data>")]
        NXtelPage,

        [Description("NXtel Template")]
        [URL("https://admin.nxtel.org/Template/Edit/<NewID>#<Data>")]
        NXtelTemplate,

        [Description("Edit-tf")]
        [URL("https://edit.tf/#<Data>")]
        EditTF,

        [Description("ZXNet")]
        [URL("https://zxnet.co.uk/teletext/editor/#<Data>")]
        ZXNet
    }
}
