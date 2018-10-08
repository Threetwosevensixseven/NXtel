using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelCarousel
{
    public class Page
    {
        public byte Bank { get; set; }
        public byte Slot { get; set; }
        public short Duration { get; set; }

        public Page(short PageNo, short Duration)
        {
            this.Bank = Convert.ToByte(PageNo / 8);
            this.Slot = Convert.ToByte(PageNo % 8);
            this.Duration = Duration;
        }

        public byte DurationLSB { get { return Convert.ToByte(Duration % 256); } }

        public byte DurationMSB { get { return Convert.ToByte(Duration / 256); } }

    }
}
