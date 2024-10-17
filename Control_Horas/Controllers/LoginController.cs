using Control_Horas.Models;
using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using Dapper;
using Microsoft.Extensions.Configuration;

namespace Control_Horas.Controllers
{
    public class LoginController : Controller
    {
        private readonly string _connectionString;

        public LoginController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("BitacoraDB");
        }

        [HttpGet]
        public IActionResult Index()
        {
            return View(new LoginModel()); 
        }

        [HttpPost]
        public IActionResult Index(LoginModel model)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                var parameters = new { Usuario = model.Usuario, Contrasena = model.Contrasena };
                var result = connection.QueryFirstOrDefault<LoginModel>("ValidarUsuarioLogin", parameters, commandType: System.Data.CommandType.StoredProcedure);

                if (result != null && result.Rol != null)
                {
                    if (result.Rol == "Ingreso")
                    {
                        return RedirectToAction("GrabarHoras", "Horas");
                    }
                    else if (result.Rol == "Aprobador")
                    {
                        return RedirectToAction("Index", "AprobacionHoras");
                    }
                    else
                    {
                        model.Mensaje = "Acceso denegado: Rol no reconocido.";
                        return View(model);
                    }
                }
                else
                {
                    model.Mensaje = "Usuario o contraseña incorrectos.";
                    return View(model);
                }
            }
        }
    }
}
