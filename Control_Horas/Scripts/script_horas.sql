USE [master]
GO
/****** Object:  Database [Bitacora]    Script Date: 17/10/2024 13:18:13 ******/
CREATE DATABASE [Bitacora]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Bitacora', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\Bitacora.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Bitacora_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\Bitacora_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Bitacora] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Bitacora].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Bitacora] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Bitacora] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Bitacora] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Bitacora] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Bitacora] SET ARITHABORT OFF 
GO
ALTER DATABASE [Bitacora] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Bitacora] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Bitacora] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Bitacora] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Bitacora] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Bitacora] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Bitacora] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Bitacora] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Bitacora] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Bitacora] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Bitacora] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Bitacora] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Bitacora] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Bitacora] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Bitacora] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Bitacora] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Bitacora] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Bitacora] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Bitacora] SET  MULTI_USER 
GO
ALTER DATABASE [Bitacora] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Bitacora] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Bitacora] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Bitacora] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Bitacora] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Bitacora] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [Bitacora] SET QUERY_STORE = ON
GO
ALTER DATABASE [Bitacora] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Bitacora]
GO
/****** Object:  Table [dbo].[RegistroHoras]    Script Date: 17/10/2024 13:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegistroHoras](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[CodigoEmpleado] [nvarchar](50) NOT NULL,
	[HoraEntrada] [time](7) NOT NULL,
	[HoraSalida] [time](7) NOT NULL,
	[aprobada] [nvarchar](1) NULL,
	[HorasTrabajadas] [float] NULL,
	[HorasExtras] [float] NULL,
	[TipoHora] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 17/10/2024 13:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](255) NOT NULL,
	[Usuario] [nvarchar](50) NOT NULL,
	[Nombre] [nvarchar](100) NOT NULL,
	[Apellido] [nvarchar](100) NOT NULL,
	[Contrasena] [nvarchar](255) NOT NULL,
	[RolDeUsuario] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[ValidarUsuarioLogin]    Script Date: 17/10/2024 13:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Crear el procedimiento almacenado para validar el inicio de sesión del usuario
CREATE PROCEDURE [dbo].[ValidarUsuarioLogin]
    @Usuario NVARCHAR(50),
    @Contrasena NVARCHAR(255)
AS
BEGIN
    -- Verificar la existencia del usuario y validar la contraseña
    DECLARE @RolDeUsuario NVARCHAR(50);

    SELECT @RolDeUsuario = RolDeUsuario
    FROM Usuarios
    WHERE Usuario = @Usuario AND Contrasena = @Contrasena;

    -- Si el usuario existe y la contraseña es correcta, verificar el rol
    IF @RolDeUsuario IS NOT NULL
    BEGIN
        -- Determinar las opciones de acceso según el rol
        IF @RolDeUsuario = 'Ingreso'
        BEGIN
            SELECT 'Acceso permitido: Ingreso de horas' AS Mensaje, @RolDeUsuario AS Rol;
        END
        ELSE IF @RolDeUsuario = 'Aprobador'
        BEGIN
            SELECT 'Acceso permitido: Aprobación de horas' AS Mensaje, @RolDeUsuario AS Rol;
        END
        ELSE
        BEGIN
            SELECT 'Acceso denegado: Rol no reconocido' AS Mensaje, @RolDeUsuario AS Rol;
        END
    END
    ELSE
    BEGIN
        -- Si el usuario no existe o la contraseña es incorrecta, denegar el acceso
        SELECT 'Acceso denegado: Usuario o contraseña incorrectos' AS Mensaje, NULL AS Rol;
    END
END;
GO
USE [master]
GO
ALTER DATABASE [Bitacora] SET  READ_WRITE 
GO
