# NXtel viewdata server.
# Build from this directory: docker build -t nxtel-server .
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY NXtelData/ NXtelData/
COPY NXtelServer/ NXtelServer/
RUN dotnet publish NXtelServer/NXtelServer.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 23280
ENTRYPOINT ["dotnet", "NXtelServer.dll"]
