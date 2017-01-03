#Install-Module sqlps

$dataSource = "cscpessqldw01"
$user = "Radiology"
$pwd = "Radiology"
$database = "Radiology"
$connectionString = "Server=$dataSource;uid=$user; pwd=$pwd;Database=$database;Integrated Security=False;"


$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
 #$connection.ConnectionString = "Server=$dataSource;Database=$database;Integrated Security=True;"
try
    {
    $connection.Open()
    #Repository database is on this server so lets find our channels application object

    try #to open our intermediate processing table and look for unique channels
        {
        
        
        $command = $connection.CreateCommand()
        $query = "SELECT distinct facility, procedurecode, priority FROM orders2 order by facility, procedurecode, priority"
        $command.CommandText = $query

        $result = $command.ExecuteReader()


        $table = new-object “System.Data.DataTable”
        $table.Load($result)

        #for each unique channel, create an object to pass back to SCOM
        $table.DefaultView | ForEach-Object -Process   {


            [string]$_.facility + "-" + $_.procedurecode + ": " + $_.priority
        
            #$instance = $discoveryData.CreateClassInstance("$MPElement[Name='BJC.Radiology.RadiologyChannel']$") 
			#$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName) 
			#$instance.AddProperty("$MPElement[Name='TrondMP.WeatherData.AppComponentWeatherLocation']/XMLAddress$", $XMLFile) 
			#$instance.AddProperty("$MPElement[Name='TrondMP.WeatherData.AppComponentWeatherLocation']/FilePath$", $FileFullName) 
			#$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $DisplayName) 
			#$discoveryData.AddInstance($instance) 
            }
        }
    catch
        {
        #if 
        $connection.close()
        $errmsg = "Data Not Present"
        $errmsg
    
        }
    }
catch
    {

    $errmsg = "Not Present"
    $errmsg
    }



