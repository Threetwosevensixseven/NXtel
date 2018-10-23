using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Security.Principal;
using System.Text;

namespace Microsoft.AspNet.Identity
{ 
    public static class IdentityExtensions
    {
        public static string GetMailbox(this IIdentity identity)
        {
            var claim = ((ClaimsIdentity)identity).FindFirst("Mailbox");
            // Test for null to avoid issues during local testing
            return (claim != null) ? claim.Value : string.Empty;
        }
    }
}
