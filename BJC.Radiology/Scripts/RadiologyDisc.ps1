param($sourceId, $managedEntityId, $computerName) 
$logfile = "c:\windows\temp\mplogfile.log"
ac $logfile "Begin Radiology Discover"
$api = new-object -comObject 'MOM.ScriptAPI' 
$discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId) 

#ac $logfile "Created discovery objects"
		
#Import-Module “sqlps” -DisableNameChecking

#ac $logfile "Import module passed"

#Create a database connection
#$user = "Radiology"
#$pwd = "Radiology"
#$connectionString = "Server=$computerName;uid=$user; pwd=$pwd;Database=Radiology;Integrated Security=False;"
#ac $logfile $connectionString

#$connection = New-Object System.Data.SqlClient.SqlConnection
#$connection.ConnectionString = $connectionString

#ac $logfile "ready to attempt database connection"
try
    {
  #  $connection.Open()
	if ($computerName = "CSCPESSQLDW01.CSCPESERVICE.COM") {
		$message = "open worked for $computerName"
		ac $logfile $message


	#if successful, look for availability of Radiology database
    try #to open our intermediate processing table and look for unique channels
        {
		$message = "Creating new instance for " + $computerName

        ac $logfile $message
		#ac $logfile "create class"
            $instance = $discoveryData.CreateClassInstance("$MPElement[Name='BJC.Radiology.Radiology']$") 
		#ac $logfile "Property 1"
			$instance.AddProperty("$MPElement[Name='Windows!Microsoft.Windows.Computer']/PrincipalName$", $computerName) 
		#ac $logfile "Property 2"
			$instance.AddProperty("$MPElement[Name='BJC.Radiology.Radiology']/HostServer$", $computerName) 
		#ac $logfile "Property 3"
			$displayname = "Radiology - " + $computerName
			$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayname) 
		#ac $logfile "Add Instance"
			$discoveryData.AddInstance($instance) 
       
		
		ac $logfile "Returning discovery data"
		$discoveryData
        }
    catch
        {
		#ac $logfile "Something about object creation failed"
		#$connection.Close()
		ac $logfile "Returning empty discovery A"
		$discoveryData
		}
	}
	else {ac $logfile "Not Radiology server"}
	}
catch
	{
	#ac $logfile "Something about connection failed"
	ac $logfile "Returning empty discovery B"
	$discoveryData
	}
