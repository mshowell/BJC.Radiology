param($sourceId, $managedEntityId, $computerName, $Debug="true") 

$api = new-object -comObject 'MOM.ScriptAPI' 
$discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId) 
		
Import-Module “sqlps” -DisableNameChecking

#Create a database connection
$user = "Radiology"
$pwd = "Radiology"
$connectionString = "Server=cscpessqldw01;uid=$user; pwd=$pwd;Database=Radiology;Integrated Security=False;"

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

try
    {
    $connection.Open()
	#if successful, look for availability of Radiology database
    try #to open our intermediate processing table and look for unique channels
        {
        
        $command = $connection.CreateCommand()
        $query = "SELECT distinct facility, procedurecode, priority FROM orders2 order by facility, procedurecode, priority"
        $command.CommandText = $query

        $result = $command.ExecuteReader()


        $table = new-object “System.Data.DataTable”
        $table.Load($result)

		
        $instance = $discoveryData.CreateClassInstance("$MPElement[Name='BJC.Radiology.Radiology']$") 
		$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName) 
		$instance.AddProperty("$MPElement[Name='BJC.Radiology.Radiology']/HostServer$", $computerName) 
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", 'Radiology - ' + $DisplayName) 
		$discoveryData.AddInstance($instance) 
           
       	#if Radiology database found, create the properties for the BJC.Radiology.Radiology instance
        #for each unique channel, create an object to pass back to SCOM
        $table.DefaultView | ForEach-Object -Process   {

            $DisplayName = [string]$_.facility + "-" + $_.procedurecode + ": " + $_.priority
        
            $instance = $discoveryData.CreateClassInstance("$MPElement[Name='BJC.Radiology.RadiologyChannel']$") 
			$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/Facility$", $_.facility) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/ProcedureCode$", $_.procedurecode) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/Priority$", $_.priority) 
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $DisplayName) 
			$discoveryData.AddInstance($instance) 
            }
		
		$discoveryData
        }
    catch
        {
		$connection.Close()
		$discoveryData
		}
catch
	{
	$discoveryData
	}
