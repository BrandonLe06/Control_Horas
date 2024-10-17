using Control_Horas.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Data.SqlClient;
using Dapper;

namespace Control_Horas.Controllers
{
    public class HorasController : Controller
    {
        private readonly string _connectionString;

        public HorasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("BitacoraDB");
        }

        [HttpGet]
        public IActionResult GrabarHoras()
        {
            return View();
        }

        [HttpPost]
        [HttpPost]
        public IActionResult GrabarHoras(RegistroHorasModel model)
        {
            if (ModelState.IsValid)
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    // Cálculo de horas
                    // Parsear la hora de entrada y salida
                    var horaEntrada = DateTime.ParseExact(model.HoraEntrada, "hh:mm tt", System.Globalization.CultureInfo.InvariantCulture);
                    var horaSalida = DateTime.ParseExact(model.HoraSalida, "hh:mm tt", System.Globalization.CultureInfo.InvariantCulture);

                    // 1. Total de horas trabajadas
                    double totalHorasTrabajadas = (horaSalida - horaEntrada).TotalHours;

                    // 2. Total de horas según jornada
                    double jornadaDiurnaInicio = 7.0; // 7 AM
                    double jornadaDiurnaFin = 14.983333; // 2:59 PM
                    double totalHorasSegunJornada = (jornadaDiurnaFin - jornadaDiurnaInicio);

                    // 3. Total de horas extras
                    double totalHorasExtras = totalHorasTrabajadas > totalHorasSegunJornada ? totalHorasTrabajadas - totalHorasSegunJornada : 0;

                    // Insertar en la base de datos
                    string sql = "INSERT INTO RegistroHoras (Fecha, CodigoEmpleado, HoraEntrada, HoraSalida, aprobada, HorasTrabajadas, HorasExtras) VALUES (@Fecha, @CodigoEmpleado, @HoraEntrada, @HoraSalida, 'P', @HorasTrabajadas, @HorasExtras)";

                    connection.Execute(sql, new
                    {
                        Fecha = model.Fecha,
                        CodigoEmpleado = model.CodigoEmpleado,
                        HoraEntrada = horaEntrada.ToString("HH:mm"), // Guardar en formato 24 horas
                        HoraSalida = horaSalida.ToString("HH:mm"),
                        HorasTrabajadas = totalHorasTrabajadas,
                        HorasExtras = totalHorasExtras
                    });
                }

                // Limpiar el modelo después de grabar
                ModelState.Clear();
                ViewBag.Mensaje = "Horas registradas con éxito.";
                return View(new RegistroHorasModel()); // Regresar un nuevo modelo limpio
            }

            return View(model);
        }

    }
}
