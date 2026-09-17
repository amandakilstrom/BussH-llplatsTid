namespace BussHållplatsTid.Models;

public class Departure
{
    public string Name { get; set; } = "";
    public string Stop { get; set; } = "";
    public string StopExtId { get; set; } = "";
    public string Time { get; set; } = "";
    public string Date { get; set; } = "";
    public string Direction { get; set; } = "";
    public bool Reachable { get; set; }
    public ProductAtStop? ProductAtStop { get; set; }
}