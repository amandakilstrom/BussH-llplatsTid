using BussHållplatsTid.Models;

namespace BussHållplatsTid.Services;

public class BusDepartureService : IBusDepartureService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public BusDepartureService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    public async Task<List<Departure>> GetDeparturesAsync()
    {
        var apiKey = _configuration["ResRobot:ApiKey"];
        var stopId = _configuration["ResRobot:StopId"];

        var url = $"departureBoard?id={stopId}&format=json&accessId={apiKey}";

        var response = await _httpClient.GetFromJsonAsync<DepartureBoardResponse>(url);
        return response?.Departure ?? new List<Departure>();
    }
}