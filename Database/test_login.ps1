$connString = "Server=Z4n4t3\SQLEXPRESS;Database=DB_TornilloFlojo;User Id=tornillo_app;Password=TornilloApp#2026!;TrustServerCertificate=True;MultipleActiveResultSets=True;"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "usp_Usuario_Login"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    $cmd.Parameters.AddWithValue("@username", "admin") | Out-Null
    $cmd.Parameters.AddWithValue("@password_hash", "admin123") | Out-Null
    
    $reader = $cmd.ExecuteReader()
    if ($reader.HasRows) {
        while ($reader.Read()) {
            Write-Host "EXITO: Usuario encontrado ->" $reader['username'] "- Rol:" $reader['RolNombre']
        }
    } else {
        Write-Host "FALLO: No user found."
    }
    $conn.Close()
} catch {
    Write-Host "ERROR DE CONEXION: " $_.Exception.Message
}
