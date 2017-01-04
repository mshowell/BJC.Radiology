param($sourceId, $managedEntityId, $computerName) 
$logfile = "c:\windows\temp\mplogfile.log"
ac $logfile "Begin Radiology Channel Discover"
$api = new-object -comObject 'MOM.ScriptAPI' 
$discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId) 

ac $logfile "Created discovery objects"
		
#Import-Module “sqlps” -DisableNameChecking

#ac $logfile "Import module passed"

#Create a database connection
$user = "Radiology"
$pwd = "Radiology"
$connectionString = "Server=$computerName;uid=$user; pwd=$pwd;Database=Radiology;Integrated Security=False;"
ac $logfile $connectionString

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

ac $logfile "ready to attempt database connection"
try
    {
    $connection.Open()
	ac $logfile "open worked"

	#if successful, look for availability of Radiology database
    try #to open our intermediate processing table and look for unique channels
        {
        
        $command = $connection.CreateCommand()
        $query = "SELECT distinct facility, procedurecode, priority FROM orders2 order by facility, procedurecode, priority"
        $command.CommandText = $query

		ac $logfile "ready to execute discovery query"
        $result = $command.ExecuteReader()
		ac $logfile "query worked"

        $table = new-object “System.Data.DataTable”
        $table.Load($result)
		ac $logfile "data loaded"
		
		
       	#if Radiology database found, create the properties for the BJC.Radiology.Radiology instance
        #for each unique channel, create an object to pass back to SCOM
		ac $logfile "Now start loop through values"
        $table.DefaultView | ForEach-Object -Process   {

            $DisplayName = [string]$_.facility + "-" + $_.procedurecode + ": " + $_.priority
			$message = "Creating new instance for " + $DisplayName
			#ac $logfile $message
            $instance = $discoveryData.CreateClassInstance("$MPElement[Name='BJC.Radiology.RadiologyChannel']$") 
			$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/Facility$", $_.facility) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/ProcedureCode$", $_.procedurecode) 
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.RadiologyChannel']/Priority$", $_.priority) 
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $DisplayName) 
			$discoveryData.AddInstance($instance) 
            }
		
			ac $logfile "Returning discovery data"
		$discoveryData
        }
    catch
        {
		ac $logfile "Something about query failed"
		$connection.Close()
		$discoveryData
		}
	}
catch
	{
	ac $logfile "Something about connection failed"
	$discoveryData
	}
