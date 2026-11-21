using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using NXtelData;

namespace NXtelManager
{
    public partial class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            //new Settings(AppContext.BaseDirectory).Save();
            var settings = new Settings(AppContext.BaseDirectory).Load();
            DBOps.ConnectionString = settings.ConnectionString;
            DBOps.Settings = settings;
            SQL.UpdateStructure();
            SQL.SetupData();
            ConfigureAuth(services);
            services.AddSession();
            // Property names in JSON results stay as they are in the C# classes, as ASP.NET MVC wrote them
            services.AddControllersWithViews(options => FilterConfig.RegisterGlobalFilters(options.Filters))
                .AddJsonOptions(options => options.JsonSerializerOptions.PropertyNamingPolicy = null);
            BundleConfig.RegisterBundles(BundleConfig.Bundles);
        }

        public void Configure(IApplicationBuilder app)
        {
            Controllers.EmailController.Services = app.ApplicationServices;
            app.UseDeveloperExceptionPage();
            BundleConfig.UseStaticFiles(app);
            app.UseMiddleware<MultipleButtonMiddleware>();
            app.UseRouting();
            app.UseSession();
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseEndpoints(RouteConfig.RegisterRoutes);
        }
    }
}
