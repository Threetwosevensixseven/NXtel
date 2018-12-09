using System.Data.Entity;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using NXtelData;

namespace NXtelManager.Models
{
    // You can add profile data for the user by adding more properties to your ApplicationUser class, please visit http://go.microsoft.com/fwlink/?LinkID=317594 to learn more.
    public class ApplicationUser : IdentityUser
    {
        public string Mailbox { get; set; }

        public async Task<ClaimsIdentity> GenerateUserIdentityAsync(UserManager<ApplicationUser> manager, bool isPersistent)
        {
            // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
            var userIdentity = await manager.CreateIdentityAsync(this, DefaultAuthenticationTypes.ApplicationCookie);
            userIdentity.SetIsPersistent(isPersistent);
            //userIdentity.AddClaim(new Claim("Mailbox", (Mailbox ?? "").ToString()));
            return userIdentity;
        }
    }

    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext()
            : base(DBOps.ConnectionString, throwIfV1Schema: false)
        {
        }

        public static ApplicationDbContext Create()
        {
            return new ApplicationDbContext();
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<ApplicationUser>().ToTable("aspnetusers");
            modelBuilder.Entity<IdentityRole>().ToTable("aspnetroles");
            modelBuilder.Entity<IdentityUserRole>().ToTable("aspnetuserroles");
            modelBuilder.Entity<IdentityUserClaim>().ToTable("aspnetuserclaims");
            modelBuilder.Entity<IdentityUserLogin>().ToTable("aspnetuserlogins");
        }
    }
}