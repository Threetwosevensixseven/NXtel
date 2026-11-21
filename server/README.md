# Running the NXtel server and manager

The viewdata server is `NXtelServer`, a .NET 10 console app. It listens on TCP port 23280 and reads its pages from a MySQL database. The manager is `NXtelManager`, an ASP.NET Core web app for editing pages, templates, files, zones and users. Both run on Linux and macOS, and in Docker.

## Settings

The server reads `appsettings.json` from the directory that holds `NXtelServer.dll`. An environment variable with the same name as a key overrides that key, for example `TCPListeningPort=23281`.

- `ConnectionString` is the MySQL connection string, for example `server=localhost;port=3306;database=nxtel;uid=nxtel;pwd=...`.
- `TimeZone` is an IANA time zone name, for example `Europe/London`. Dates and times shown on pages use it. When it is empty, pages use the host's local time. Day and month names follow the process culture.
- `LogFile` is a file that gets a copy of the console output. Leave it empty to log to the console only.
- The other keys are the server options: start page, character set, space trimming, telnet IAC and so on.

The server reads commands from stdin (`clients`, `kill`, `killall`, `lock`, `unlock`). It stops when stdin is closed, so keep stdin open. Under Docker use `stdin_open: true`. In a shell or a service unit, pipe something that stays open, such as `tail -f /dev/null | dotnet NXtelServer.dll`.

## The database

Use MySQL 8.4 with default settings. `Schema/NXtelDbSchema.sql` creates the `nxtel` database with empty tables. Its stored procedure has the definer `nxtel@%`, so create a user with that name before you import it:

```sh
mysql -uroot -p -e "CREATE USER 'nxtel'@'%' IDENTIFIED BY 'changeme'; GRANT ALL ON nxtel.* TO 'nxtel'@'%';"
mysql -uroot -p < Schema/NXtelDbSchema.sql
```

An empty database gives an empty start page. Pages are added with the manager.

## The manager

The manager reads `appsettings.json` from the directory that holds `NXtelManager.dll`, with the same environment variable overrides as the server. Its keys are the ones the old `Web.config` had, plus `ConnectionString`, `AdditionalConnections` and the mail settings `SmtpHost`, `SmtpUserName` and `SmtpPassword`.

- The database must be called `nxtel`, because some of the manager's SQL names it.
- When `UpdateSQL` is `true`, the manager adds the columns and tables that ASP.NET Core Identity needs to the `aspnet*` tables at startup. Existing passwords keep working, and new ones are stored in the same format.
- The help pages need the directories named by `ContentHelpDirectory` and `ExternalWikiDirectory`. By default they are `App_Data/ContentHelp` and `App_Data/GitHubWiki` next to `NXtelManager.dll`. Create them before the first start.
- `App_Data` also holds database backups and the keys for the sign in cookie.
- The Server page downloads the file named by `LogFile`, so point it at the server's log file.

To run it outside Docker:

```sh
dotnet publish NXtelManager/NXtelManager.csproj -c Release -o /opt/nxtel-manager
cd /opt/nxtel-manager
mkdir -p App_Data/ContentHelp App_Data/GitHubWiki
ConnectionString='server=127.0.0.1;port=3306;database=nxtel;uid=nxtel;pwd=changeme' ASPNETCORE_URLS=http://0.0.0.0:8080 dotnet NXtelManager.dll
```

## NXtelGeo

`NXtelGeo` is a console app that fills in the latitude and longitude of visitor addresses in the `geo` table. It looks each address up at `GeoEndpoint`, at most `GeoRequestsPerMinute` times a minute. It reads `appsettings.json` from its own directory, with the same environment variable overrides. It processes the database in `ConnectionString` and then each database in `AdditionalConnections`, then exits. Run it from cron or a systemd timer:

```sh
dotnet publish NXtelGeo/NXtelGeo.csproj -c Release -o /opt/nxtel-geo
dotnet /opt/nxtel-geo/NXtelGeo.dll
```

With `-i` it waits for a key press before it exits.

## Docker

`compose.yaml` runs the server, the manager and MySQL 8.4. From this directory:

```sh
docker compose up -d
```

The first start creates the database from the schema. Change the passwords in `compose.yaml` before you use it outside a test machine. The server is on port 23280 of the host and the manager on port 8080. Settings go in the `environment` section of each service. Docker restarts the server if it stops. The server and the manager share a volume for the server's log file.

To build only the server image: `docker build -t nxtel-server .`. For the manager: `docker build -f NXtelManager/Dockerfile -t nxtel-manager .`

## Linux

Install the .NET 10 SDK to build, or the .NET 10 runtime to run a published copy. Install MySQL 8.4 from your distribution, or run only the database from the Compose file with `docker compose up -d db` after you add a `ports` entry for 3306.

```sh
dotnet publish NXtelServer/NXtelServer.csproj -c Release -o /opt/nxtel
cd /opt/nxtel
# Edit appsettings.json, or set ConnectionString and the other keys as environment variables.
tail -f /dev/null | dotnet NXtelServer.dll
```

## macOS

Install the .NET 10 SDK and MySQL 8.4 (`brew install mysql@8.4`), or run the database from the Compose file as for Linux. Then:

```sh
cd NXtelServer
ConnectionString='server=127.0.0.1;port=3306;database=nxtel;uid=nxtel;pwd=changeme' dotnet run
```

`dotnet run` keeps the terminal's stdin open.
