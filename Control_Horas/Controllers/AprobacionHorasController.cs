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
        public IActionResult Index()
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                var registros = connection.Query<RegistroHorasModel>("SELECT * FROM RegistroHoras WHERE Aprobada = 'P'").AsList();
                return View(registros);
            }
        }

        [HttpPost]
        public IActionResult AprobarHoras(List<string> idsAprobados, List<string> idsRechazados)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                foreach (var codigoEmpleado in idsAprobados)
                {
                    // Actualizar el registro a 'A' para aprobado
                    connection.Execute("UPDATE RegistroHoras SET Aprobada = 'A' WHERE CodigoEmpleado = @CodigoEmpleado", new { CodigoEmpleado = codigoEmpleado });
                }

                foreach (var codigoEmpleado in idsRechazados)
                {
                    // Actualizar el registro a 'R' para rechazado
                    connection.Execute("UPDATE RegistroHoras SET Aprobada = 'R' WHERE CodigoEmpleado = @CodigoEmpleado", new { CodigoEmpleado = codigoEmpleado });
                }
            }

            ViewBag.Mensaje = "Horas actualizadas correctamente.";
            return RedirectToAction("Index");
        }
    }
}
