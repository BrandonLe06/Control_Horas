namespace Control_Horas.Models
{
    public class AprobacionHorasModel
    {
        public DateTime Fecha { get; set; }
        public string CodigoEmpleado { get; set; }
        public string HoraEntrada { get; set; }
        public string HoraSalida { get; set; }
        public double HorasTrabajadas { get; set; }
        public double HorasExtras { get; set; }
        public string Aprobada { get; set; } = "P"; // Por defecto "P"
    }
}
