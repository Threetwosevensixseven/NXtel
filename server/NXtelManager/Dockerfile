# NXtel manager, the content editor.
# Build from the server directory: docker build -f NXtelManager/Dockerfile -t nxtel-manager .
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY Markdown/ Markdown/
COPY NXtelData/ NXtelData/
COPY NXtelManager/ NXtelManager/
RUN dotnet publish NXtelManager/NXtelManager.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
# The help pages read these directories, and fail when they do not exist.
RUN mkdir -p App_Data/ContentHelp App_Data/GitHubWiki
EXPOSE 8080
ENTRYPOINT ["dotnet", "NXtelManager.dll"]
