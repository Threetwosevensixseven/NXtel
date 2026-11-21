using System;
using System.IO;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager
{
    public partial class Startup
    {
        public void ConfigureAuth(IServiceCollection services)
        {
            // Configure the db context, user manager and signin manager to use a single instance per request
            services.AddDbContext<ApplicationDbContext>(options =>
                options.UseMySql(DBOps.ConnectionString, ServerVersion.AutoDetect(DBOps.ConnectionString)));
            services.AddIdentity<ApplicationUser, IdentityRole>(ApplicationUserManager.Configure)
                .AddEntityFrameworkStores<ApplicationDbContext>()
                .AddUserManager<ApplicationUserManager>()
                .AddSignInManager<ApplicationSignInManager>()
                .AddDefaultTokenProviders()
                // Register two factor authentication providers. This application uses Phone and Emails as a step of receiving a code for verifying the user
                .AddTokenProvider<PhoneNumberTokenProvider<ApplicationUser>>("Phone Code")
                .AddTokenProvider<EmailTokenProvider<ApplicationUser>>("Email Code");

            // Keep writing ASP.NET Identity 2 password hashes, so existing and new hashes stay in one format
            services.Configure<PasswordHasherOptions>(options =>
                options.CompatibilityMode = PasswordHasherCompatibilityMode.IdentityV2);

            // Keys for the sign in cookie and the email tokens, kept with the app data so sign ins survive a restart
            services.AddDataProtection()
                .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(AppContext.BaseDirectory, "App_Data", "Keys")));

            // Enable the application to use a cookie to store information for the signed in user
            // Configure the sign in cookie
            services.ConfigureApplicationCookie(options =>
            {
                options.LoginPath = "/Account/Login";
                options.AccessDeniedPath = "/Account/Login";
            });

            // Enables the application to validate the security stamp when the user logs in.
            // This is a security feature which is used when you change a password or add an external login to your account.
            services.Configure<SecurityStampValidatorOptions>(options =>
                options.ValidationInterval = TimeSpan.FromDays(30));
        }
    }
}
