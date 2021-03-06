Include (%callout, OPCUA.Constants)

Class OPCUA.Adapter.Common Extends Ens.InboundAdapter
{

/// Configurable settings
Parameter SETTINGS = "URL:Connection,ConnectionRetryTimeout:Connection,DataSourceClass:Data,Username:User,Password:User,SecurityMode:Security,ClientURI:Security,PublicCertificate:Security,PrivateKey:Security,TrustListDir:Security,RevocationListDir:Security";

// *** PROPERTIES INFLUENCED BY SETTINGS ***

/// The URL of the server from which data is sought. 
/// (e.g. <i>opc.tcp://servername:4840</i>)
Property URL As %String;

/// The duration (in seconds), since the last time that 
/// the OPC UA client was able to connect to the target
/// OPC UA server, after which no more connection attempts
/// will be made.
Property ConnectionRetryTimeout As %Integer [ InitialExpression = 600 ];

/// The name of the DataSource class specifying the 
/// data types and nodes from which to obtain data
/// as well as the fields in which to deposit the results.
Property DataSourceClass As %String;

/// The username with which to log on to the OPC UA server.
Property Username as %String;

/// The password with which to log on to the OPC UA server.
Property Password as %String;

Property SecurityMode as %String(DISPLAYLIST=",None,Sign & Encrypt",VALUELIST=",1,3") [ InitialExpression = "1", Required ];

/// The "application URI" of this IRIS OPC UA connector. 
/// Notice that this identifying string may need to match
/// comparable identifying strings noted within certificates
/// used to identify this application to the target OPC UA
/// server.
Property ClientURI as %String;

/// The full pathname of the certificate that is to be 
/// used to identify the IRIS OPC UA connector as a client 
/// to the OPC UA server. Notice that this certificate may 
/// need to have been signed by a certicate authority that
/// is trusted by the target OPC UA server. Should be
/// supplied in DER format.
Property PublicCertificate as %String;

/// The full pathname of the private key that is to be used
/// by this IRIS OPC UA connector in communications with the
/// target OPC UA server. Should be supplied in DER format.
Property PrivateKey as %String;

/// The full pathname of the directory in which the certificates
/// of trusted sources are kept. Importantly, this directory
/// may need to hold a valid certificate of the certificate authority
/// that signs a target OPC UA server's identifying certificates,
/// or a trusted certificate of a target OPC UA server itself.
/// Certificates in this directory should be supplied in 
/// DER format.
Property TrustListDir as %String;

/// The full pathname of the directory in which certificate 
/// revocation lists (CRLs) are to be held. Such CRLs may be
/// required for connecting to any given OPC UA server even  
/// in the event that no certificates have been revoked in
/// regards to that server.
Property RevocationListDir as %String;

// *** PRIVATE PROPERTIES ***

Property Client As OPCUA.Client [ Private ];

Property IsConnected As %Integer [ Private ];

Property LastReportedError As %Status [ Private ]; 

Property ConnectionRetryEndTime As %TimeStamp [ Private ];

// *** METHODS ***

Method OnInit() As %Status
{
	#dim tSC as %Status = $$$OK

	try {

		set ..IsConnected = 0

		set ..Client = ##class(OPCUA.Client).%New()
		set tSC = ..Client.Initialize()
		Quit:$$$ISERR(tSC)

		set tSC = ..Client.SetupClient("",..SecurityMode,..ClientURI,..PublicCertificate,..PrivateKey,..TrustListDir,..RevocationListDir)
		Quit:$$$ISERR(tSC)

	} catch (e) {
		Set tSC=e.AsStatus()
	}
	
	if $$$ISERR(tSC) {
		$$$LOGERROR("OPCUA Client initialization failed [c.oi] : "_$SYSTEM.Status.GetErrorText(tSC))
		Quit tSC
	} 
	
	Quit tSC  // Quit $$$OK
}

Method Connect() As %Status [ Private ]
{
	#dim tSC as %Status = $$$OK
	
	try {
	
		set tSC = ..Client.Connect(..URL,..Username,..Password)
		//Quit:$$$ISERR(tSC)

	} catch (e) {
		set tSC = e.AsStatus()
	}

	Quit tSC
}

Method Disconnect() As %Status [ Private ]
{
	#dim tSC as %Status = $$$OK
	
	try {
	
		set tSC = ..Client.Disconnect()
		//Quit:$$$ISERR(tSC)

	} catch (e) {
		set tSC = e.AsStatus()
	}

	Quit tSC
}

Method OnTearDown() As %Status
{
	#dim tSC as %Status = $$$OK

	try {
	
		set tSC = ..Client.Disconnect()
				
	} catch (e) {
		Set tSC=e.AsStatus()
	}
	
	Quit tSC
}

}
