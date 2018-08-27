using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using NXtelData;

namespace NXtelServer.Classes
{
    public class Client
    {
        public IPEndPoint remoteEndPoint;
        public DateTime connectedAt;
        public EClientState clientState;
        public string commandIssued = string.Empty;
        public Stack<Page> History;

        public Client(IPEndPoint _remoteEndPoint, DateTime _connectedAt, EClientState _clientState)
        {
            this.remoteEndPoint = _remoteEndPoint;
            this.connectedAt = _connectedAt;
            this.clientState = _clientState;
            this.History = new Stack<Page>();
        }

        public Page CurrentPage
        {
            get
            {
                if (History.Count == 0)
                    return new Page();
                return History.Peek();
            }
        }
    }
}
