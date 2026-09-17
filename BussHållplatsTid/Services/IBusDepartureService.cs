using BussHållplatsTid.Models;

namespace BussHållplatsTid.Services
{
    public interface IBusDepartureService
    {
        Task<List<Departure>> GetDeparturesAsync();
    }
}