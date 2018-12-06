using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Web;
using Microsoft.AspNet.Identity;

namespace System.Security.Claims
{
    public static class ClaimsIdentityExtensions
    {
        private const string PersistentLoginClaimType = "PersistentLogin";

        public static bool GetIsPersistent(this ClaimsIdentity identity)
        {
            return identity.Claims.FirstOrDefault(c => c.Type == PersistentLoginClaimType) != null;
        }

        public static void SetIsPersistent(this ClaimsIdentity identity, bool isPersistent)
        {
            var claim = identity.Claims.FirstOrDefault(c => c.Type == PersistentLoginClaimType);
            if (isPersistent)
            {
                if (claim == null)
                {
                    identity.AddClaim(new Claim(PersistentLoginClaimType, Boolean.TrueString));
                }
            }
            else if (claim != null)
            {
                identity.RemoveClaim(claim);
            }
        }
    }
}