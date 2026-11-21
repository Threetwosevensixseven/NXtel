using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using NXtelData;

namespace NXtelManager.Models
{
    // You can add profile data for the user by adding more properties to your ApplicationUser class, please visit http://go.microsoft.com/fwlink/?LinkID=317594 to learn more.
    public class ApplicationUser : IdentityUser
    {
        public string Mailbox { get; set; }
    }

    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<ApplicationUser>().ToTable("aspnetusers");
            modelBuilder.Entity<IdentityRole>().ToTable("aspnetroles");
            modelBuilder.Entity<IdentityUserRole<string>>().ToTable("aspnetuserroles");
            modelBuilder.Entity<IdentityUserClaim<string>>().ToTable("aspnetuserclaims");
            modelBuilder.Entity<IdentityUserLogin<string>>().ToTable("aspnetuserlogins");
            modelBuilder.Entity<IdentityUserToken<string>>().ToTable("aspnetusertokens");
            modelBuilder.Entity<IdentityRoleClaim<string>>().ToTable("aspnetroleclaims");
        }
    }
}
