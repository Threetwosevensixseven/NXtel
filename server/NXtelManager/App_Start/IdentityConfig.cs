using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using NXtelData;
using NXtelManager.Models;

namespace NXtelManager
{
    public class IdentityMessage
    {
        public string Destination { get; set; }
        public string Subject { get; set; }
        public string Body { get; set; }
    }

    public class EmailService
    {
        public Task SendAsync(IdentityMessage message)
        {
            try
            {
                SmtpClient client = new SmtpClient(Options.Configuration["SmtpHost"]);
                string userName = Options.Configuration["SmtpUserName"];
                if (!string.IsNullOrEmpty(userName))
                    client.Credentials = new NetworkCredential(userName, Options.Configuration["SmtpPassword"]);
                var msg = new MailMessage();
                msg.From = new MailAddress(Options.AdminEmailAddress);
                msg.To.Add(new MailAddress(message.Destination));
                foreach (string bcc in Options.AdminEmailBCCList)
                {
                    try
                    {
                        msg.Bcc.Add(new MailAddress(bcc));
                    }
                    catch { }
                }
                msg.Subject = Options.AppName + " - " + (message.Subject ?? "").Trim();
                msg.Body = message.Body;
                return client.SendMailAsync(msg);
            }
            catch
            {
                return null;
            }
            finally { }
        }
    }

    public class SmsService
    {
        public Task SendAsync(IdentityMessage message)
        {
            // Plug in your SMS service here to send a text message.
            return Task.FromResult(0);
        }
    }

    // Configure the application user manager used in this application. UserManager is defined in ASP.NET Identity and is used by the application.
    // The methods that take a user ID keep the ASP.NET Identity 2 calls the controllers make.
    public class ApplicationUserManager : UserManager<ApplicationUser>
    {
        public ApplicationUserManager(IUserStore<ApplicationUser> store, Microsoft.Extensions.Options.IOptions<IdentityOptions> optionsAccessor,
            IPasswordHasher<ApplicationUser> passwordHasher, IEnumerable<IUserValidator<ApplicationUser>> userValidators,
            IEnumerable<IPasswordValidator<ApplicationUser>> passwordValidators, ILookupNormalizer keyNormalizer,
            IdentityErrorDescriber errors, IServiceProvider services, ILogger<UserManager<ApplicationUser>> logger)
            : base(store, optionsAccessor, passwordHasher, userValidators, passwordValidators, keyNormalizer, errors, services, logger)
        {
            EmailService = new EmailService();
            SmsService = new SmsService();
        }

        public EmailService EmailService { get; set; }
        public SmsService SmsService { get; set; }

        public static void Configure(IdentityOptions options)
        {
            // Configure validation logic for usernames
            options.User.AllowedUserNameCharacters = null;
            options.User.RequireUniqueEmail = true;

            // Configure validation logic for passwords
            options.Password.RequiredLength = 6;
            options.Password.RequireNonAlphanumeric = true;
            options.Password.RequireDigit = true;
            options.Password.RequireLowercase = true;
            options.Password.RequireUppercase = true;

            // Configure user lockout defaults
            options.Lockout.AllowedForNewUsers = true;
            options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
            options.Lockout.MaxFailedAccessAttempts = 5;
        }

        public ApplicationUser FindById(string userId)
        {
            return FindByIdAsync(userId).Result;
        }

        public async Task SendEmailAsync(string userId, string subject, string body)
        {
            var email = await GetEmailAsync(userId);
            await EmailService.SendAsync(new IdentityMessage { Destination = email, Subject = subject, Body = body });
        }

        public async Task<bool> IsEmailConfirmedAsync(string userId)
        {
            return await IsEmailConfirmedAsync(await FindByIdAsync(userId));
        }

        public async Task<string> GenerateEmailConfirmationTokenAsync(string userId)
        {
            return await GenerateEmailConfirmationTokenAsync(await FindByIdAsync(userId));
        }

        public async Task<IdentityResult> ConfirmEmailAsync(string userId, string token)
        {
            return await ConfirmEmailAsync(await FindByIdAsync(userId), token);
        }

        public async Task<string> GeneratePasswordResetTokenAsync(string userId)
        {
            return await GeneratePasswordResetTokenAsync(await FindByIdAsync(userId));
        }

        public async Task<IdentityResult> ResetPasswordAsync(string userId, string token, string newPassword)
        {
            return await ResetPasswordAsync(await FindByIdAsync(userId), token, newPassword);
        }

        public async Task<IList<string>> GetValidTwoFactorProvidersAsync(string userId)
        {
            return await GetValidTwoFactorProvidersAsync(await FindByIdAsync(userId));
        }

        public async Task<IdentityResult> AddLoginAsync(string userId, UserLoginInfo login)
        {
            return await AddLoginAsync(await FindByIdAsync(userId), login);
        }

        public async Task<IdentityResult> RemoveLoginAsync(string userId, UserLoginInfo login)
        {
            return await RemoveLoginAsync(await FindByIdAsync(userId), login.LoginProvider, login.ProviderKey);
        }

        public async Task<IList<UserLoginInfo>> GetLoginsAsync(string userId)
        {
            return await GetLoginsAsync(await FindByIdAsync(userId));
        }

        public async Task<string> GetEmailAsync(string userId)
        {
            return await GetEmailAsync(await FindByIdAsync(userId));
        }

        public async Task<string> GetPhoneNumberAsync(string userId)
        {
            return await GetPhoneNumberAsync(await FindByIdAsync(userId));
        }

        public async Task<IdentityResult> SetPhoneNumberAsync(string userId, string phoneNumber)
        {
            return await SetPhoneNumberAsync(await FindByIdAsync(userId), phoneNumber);
        }

        public async Task<string> GenerateChangePhoneNumberTokenAsync(string userId, string phoneNumber)
        {
            return await GenerateChangePhoneNumberTokenAsync(await FindByIdAsync(userId), phoneNumber);
        }

        public async Task<IdentityResult> ChangePhoneNumberAsync(string userId, string phoneNumber, string token)
        {
            return await ChangePhoneNumberAsync(await FindByIdAsync(userId), phoneNumber, token);
        }

        public async Task<bool> GetTwoFactorEnabledAsync(string userId)
        {
            return await GetTwoFactorEnabledAsync(await FindByIdAsync(userId));
        }

        public async Task<IdentityResult> SetTwoFactorEnabledAsync(string userId, bool enabled)
        {
            return await SetTwoFactorEnabledAsync(await FindByIdAsync(userId), enabled);
        }

        public async Task<IdentityResult> ChangePasswordAsync(string userId, string currentPassword, string newPassword)
        {
            return await ChangePasswordAsync(await FindByIdAsync(userId), currentPassword, newPassword);
        }

        public async Task<IdentityResult> AddPasswordAsync(string userId, string password)
        {
            return await AddPasswordAsync(await FindByIdAsync(userId), password);
        }
    }

    // Configure the application sign-in manager which is used in this application.
    public class ApplicationSignInManager : SignInManager<ApplicationUser>
    {
        public ApplicationSignInManager(ApplicationUserManager userManager, IHttpContextAccessor contextAccessor,
            IUserClaimsPrincipalFactory<ApplicationUser> claimsFactory, Microsoft.Extensions.Options.IOptions<IdentityOptions> optionsAccessor,
            ILogger<SignInManager<ApplicationUser>> logger, IAuthenticationSchemeProvider schemes,
            IUserConfirmation<ApplicationUser> confirmation)
            : base(userManager, contextAccessor, claimsFactory, optionsAccessor, logger, schemes, confirmation)
        {
        }

        public override async Task<ClaimsPrincipal> CreateUserPrincipalAsync(ApplicationUser user)
        {
            var userPrincipal = await base.CreateUserPrincipalAsync(user);
            var userIdentity = (ClaimsIdentity)userPrincipal.Identity;
            userIdentity.AddClaim(new Claim("Mailbox", (user.Mailbox ?? "").ToString()));
            userIdentity.SetIsPersistent(true);
            return userPrincipal;
        }

        public async Task<bool> HasBeenVerifiedAsync()
        {
            return await GetTwoFactorAuthenticationUserAsync() != null;
        }

        public async Task<string> GetVerifiedUserIdAsync()
        {
            var user = await GetTwoFactorAuthenticationUserAsync();
            return user == null ? null : user.Id;
        }

        public async Task<bool> SendTwoFactorCodeAsync(string provider)
        {
            var user = await GetTwoFactorAuthenticationUserAsync();
            if (user == null)
                return false;
            var manager = (ApplicationUserManager)UserManager;
            var token = await manager.GenerateTwoFactorTokenAsync(user, provider);
            if (provider == "Phone Code")
                await manager.SmsService.SendAsync(new IdentityMessage { Destination = user.PhoneNumber, Body = string.Format("Your security code is {0}", token) });
            else if (provider == "Email Code")
                await manager.EmailService.SendAsync(new IdentityMessage { Destination = user.Email, Subject = "Security Code", Body = string.Format("Your security code is {0}", token) });
            return true;
        }
    }

    // The sign in results of ASP.NET Identity 2, which the controllers switch on.
    public enum SignInStatus
    {
        Success,
        LockedOut,
        RequiresVerification,
        Failure
    }

    public static class SignInResultExtensions
    {
        public static SignInStatus ToStatus(this SignInResult result)
        {
            if (result.Succeeded)
                return SignInStatus.Success;
            if (result.IsLockedOut)
                return SignInStatus.LockedOut;
            if (result.RequiresTwoFactor)
                return SignInStatus.RequiresVerification;
            return SignInStatus.Failure;
        }
    }
}
