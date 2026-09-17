using BussHållplatsTid.Services;
using Microsoft.AspNetCore.Mvc;

namespace BussHållplatsTid.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DeparturesController : ControllerBase
{
    private readonly IBusDepartureService _departureService;

    public DeparturesController(IBusDepartureService departureService)
    {
        _departureService = departureService;
    }

    [HttpGet]
    public async Task<IActionResult> GetDepartures([FromQuery] string? direction = null)
    {
        var departures = await _departureService.GetDeparturesAsync(direction);
        return Ok(departures);
    }
}