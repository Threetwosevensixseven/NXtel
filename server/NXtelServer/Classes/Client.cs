using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace NXtelServer.Classes
{
    public class Client
    {
        public IPEndPoint remoteEndPoint;
        public DateTime connectedAt;
        public EClientState clientState;
        public string commandIssued = string.Empty;

        public Client(IPEndPoint _remoteEndPoint, DateTime _connectedAt, EClientState _clientState)
        {
            this.remoteEndPoint = _remoteEndPoint;
            this.connectedAt = _connectedAt;
            this.clientState = _clientState;
        }
    }
}
