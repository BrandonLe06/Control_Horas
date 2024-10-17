using Control_Horas.Models;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Data.SqlClient;
using Dapper;

namespace Control_Horas.Controllers
{
    public class AprobacionHorasController : Controller
    {
        private readonly string _connectionString;

        public AprobacionHorasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("BitacoraDB");
        }

        [HttpGet]
        [HttpGet]
        public IActionResult Index()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                var registros = connection.Query<AprobacionHorasModel>(
                    "SELECT Fecha, CodigoEmpleado, CONVERT(VARCHAR, HoraEntrada, 108) AS HoraEntrada, " +
                    "CONVERT(VARCHAR, HoraSalida, 108) AS HoraSalida, HorasTrabajadas, HorasExtras, Aprobada " +
                    "FROM RegistroHoras WHERE Aprobada = 'P'"
                ).AsList();

                // Convertir a RegistroHorasModel
                var registrosHorasModel = registros.Select(r => new RegistroHorasModel
                {
                    Fecha = r.Fecha,
                    CodigoEmpleado = r.CodigoEmpleado,
                    HoraEntrada = r.HoraEntrada,
                    HoraSalida = r.HoraSalida,
                    HorasTrabajadas = r.HorasTrabajadas,
                    HorasExtras = r.HorasExtras,
                    Aprobada = r.Aprobada
                }).ToList();

                return View(registrosHorasModel);
            }
        }


        [HttpPost]
        public IActionResult AprobarHoras(List<string> idsAprobados, List<string> idsRechazados)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                // Actualizar los registros aprobados
                foreach (var CodigoEmpleado in idsAprobados)
                {
                    connection.Execute("UPDATE RegistroHoras SET Aprobada = 'A' WHERE CodigoEmpleado = @CodigoEmpleado", new { CodigoEmpleado });
                }

                // Actualizar los registros rechazados
                foreach (var CodigoEmpleado in idsRechazados)
                {
                    connection.Execute("UPDATE RegistroHoras SET Aprobada = 'R' WHERE CodigoEmpleado = @CodigoEmpleado", new { CodigoEmpleado });
                }
            }

            ViewBag.Mensaje = "Horas actualizadas correctamente.";
            return RedirectToAction("Index");
        }
    }
}
