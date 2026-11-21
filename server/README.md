# Running the NXtel server

The viewdata server is `NXtelServer`, a .NET 10 console app. It listens on TCP port 23280 and reads its pages from a MySQL database. It runs on Linux and macOS, and in Docker.

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

## Docker

`compose.yaml` runs the server and MySQL 8.4. From this directory:

```sh
docker compose up -d
```

The first start creates the database from the schema. Change both passwords in `compose.yaml` before you use it outside a test machine. The server is on port 23280 of the host. Server settings go in the `environment` section of the `server` service.

To build only the server image: `docker build -t nxtel-server .`

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
