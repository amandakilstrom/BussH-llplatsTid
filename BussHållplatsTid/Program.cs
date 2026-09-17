using BussHållplatsTid.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHttpClient<IBusDepartureService, BusDepartureService>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["ResRobot:BaseUrl"]!);
});

var app = builder.Build();

app.MapControllers();

app.Run();