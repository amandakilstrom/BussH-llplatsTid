# --- 1. Bygg Angular ---
FROM node:22-alpine AS frontend
WORKDIR /src/frontend
COPY frontend/package*.json frontend/.npmrc* ./
RUN npm ci
COPY frontend/ ./
RUN npx ng build --configuration production

# --- 2. Publicera API:t ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS api
WORKDIR /src
COPY BussHållplatsTid/*.csproj BussHållplatsTid/
RUN dotnet restore BussHållplatsTid/BussHållplatsTid.csproj
COPY BussHållplatsTid/ BussHållplatsTid/
RUN dotnet publish BussHållplatsTid/BussHållplatsTid.csproj -c Release -o /app --no-restore

# --- 3. Slutlig image ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=api /app ./
COPY --from=frontend /src/frontend/dist/frontend/browser ./wwwroot
EXPOSE 8080
ENTRYPOINT ["dotnet", "BussHållplatsTid.dll"]
