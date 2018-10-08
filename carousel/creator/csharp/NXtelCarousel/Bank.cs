using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelCarousel
{
    public class Bank
    {
        public byte BankNo { get; set; }

        public List<Byte> Bytes { get; set; }

        public Bank(byte BankNo)
        {
            this.BankNo = BankNo;
            Bytes = new List<byte>();
        }
    }
}
