using System.Data.Common;
using System.Data.Entity;
using System.Data.Entity.Migrations.History;
using Microsoft.AspNet.Identity.EntityFramework;
using MySql.Data.Entity;
using NXtelManager.Models;

namespace NXtelManager.Migrations
{
    [DbConfigurationType(typeof(MySqlEFConfiguration))]
    public class MySqlHistoryContext : HistoryContext
    {
        public MySqlHistoryContext(DbConnection connection, string defaultSchema)
            : base(connection, defaultSchema)
        {
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<ApplicationUser>().ToTable("aspnetusers");
            modelBuilder.Entity<IdentityRole>().ToTable("aspnetroles");
            modelBuilder.Entity<IdentityUserRole>().ToTable("aspnetuserroles");
            modelBuilder.Entity<IdentityUserClaim>().ToTable("aspnetuserclaims");
            modelBuilder.Entity<IdentityUserLogin>().ToTable("aspnetuserlogins");
            modelBuilder.Entity<HistoryRow>().Property(h => h.MigrationId).HasMaxLength(100).IsRequired();
            modelBuilder.Entity<HistoryRow>().Property(h => h.ContextKey).HasMaxLength(200).IsRequired();
        }
    }
}