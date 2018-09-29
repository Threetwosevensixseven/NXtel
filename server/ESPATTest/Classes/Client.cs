using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace ESPATTest.Classes
{
    public class Client
    {
        public const byte ENTER = 0x5F;
        public IPEndPoint remoteEndPoint;
        public DateTime connectedAt;

        public Client(IPEndPoint _remoteEndPoint, DateTime _connectedAt)
        {
            this.remoteEndPoint = _remoteEndPoint;
            this.connectedAt = _connectedAt;
        }
    }
}
