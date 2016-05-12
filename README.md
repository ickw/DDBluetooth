#DDBluetooth
Practical, block-based, and lightweight CoreBluetooth library for iOS.


##What You Can Do
###Initialization



### Scan
・specify scanning duration   
・callback when found peripheral   
・callback when scan stops   

```objective-c
[self.ddScanAgent startScanForServices:nil withPrefixes:nil interval:3.f
                                    found:^(CBPeripheral *peripheral) {
                                        // Do something with found peripheral
                                    }
                                     stop:^{
                                        // Do something on stop scanning
                                     }];
```


### Connect 
・Retry to connect for designated times with specified interval.  
・callback when connected   
・callback when timeout   
・callback when disconnected unexpectedly    

```
[self.ddConnectAgent startConnectionWithRetry:self.ddPeripheral
                                withMaxRetryCount:10
                                         interval:2.f
                                       didConnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {
                             
        if (error)
        {
        	// Do something when error happens due to;
        	// 1. timeout 
        	// 2. disconnected unexpectedly       
        }
        else
        {
			  if (status == ConnectionStatusConnected)
            {
                // Successfully connected
            }
            else
            {
                // Unexpected state
            }
        }
}];   
```   

### Discover Characteristic
・callback when finish discovering characteristics   
・callback when timeout   

```
[self.ddConnectAgent discover:self.ddPeripheral didDiscover:^(NSArray * _Nullable characteristics, NSError * _Nullable error) {

        if (error)
        {
			// Failed to discover characteristics
        }
        else
        {
			// Do something with discovered characteristics
        }
}];
```   
	
### Indication
・callback when success     
・callback when fail 

```
[self.ddTransactionAgent indicate:characteristic didIndicate:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {

        if (error)
        {
			// Failed to indicate
        }
        else
        {
            if (type == DDTransactionAgentCallbackTypeIndication)
            {
                // Successfully indicate 
            }
            else if (type == DDTransactionAgentCallbackTypeNotifiedValue)
            {
				// Although a delegate mothod is prepared for notification,
				// you can also handle notification within block.
            }
            else
            {
                // Failed to indicate
            }
        }
}];
```   

	
### Read Chararacteristics value
・callback when success    
・callback when fail   
・callback when timeout   

```
[self.ddTransactionAgent read:characteristic didRead:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {
        
        if (error)
        {
            // Failed to read
        }
        else
        {
            if (type == DDTransactionAgentCallbackTypeReadValue)
            {
				// Do something with read value
            }
            else
            {
				// Unexpected state
            }
        }
    }];
```


### Write to Characteristics
・When writing data size exceeds maximum write size at a time, data will be automatically split and sent one by one. 
・callback when success   
・callback when fail  
・callback when timeout 

```
[self.ddTransactionAgent writeSplit:characteristic
                                   data:data
                                   withResponse:isWriteWithResponse
                               didWrite:^(DDTransactionAgentCallbackType type, NSData *data, NSError *error) {
                                   
                                   if (error)
                                   {
												// Write failed
                                   }
                                   else
                                   {
                                       if (type == DDTransactionAgentCallbackTypeWriteValue)
                                       {
                                           // Successfully write data
                                       }
                                       else
                                       {
                                           // Unexpected state
                                       }
                                   }
                               }];
```  


### Disconnect
・callback when success   
・callback when fail   
・callback when timeout   

```
[self.ddConnectAgent disconnect:^(CBPeripheral * _Nullable peripheral, ConnectionStatus status, NSError * _Nullable error) {
        if (error)
        {
        	// Failed to disconnect
        }
        else
        {
			// Successfuly disconnect
        }
}];
```

##Practical Design for actual product development & iOS Cache Countermeasures

####Considering actual product development situation, the library comes with some useful features

- Re-Scan when didModifyValue called (*The peripheral (server) needs to enable indication of [Service Changed](https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.generic_attribute.xml) Characteristic.
If paring is not required, "didModifyService" wouldn't be called)
	
- Practical reconnect method to corp with iOS BTServer crash bug.
	- iPhone 5s and older devices seems to have a problem establishing a connection with peripherals that immediately disconnect after "didConnectPeripheral" called.

```
BTServer[57] <Error>: ATT Failed to set MTU to 158 with result BM3 STATUS 14  
BTServer[57] <Error>: Core Connection failed to device "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
BTServer[57] <Error>: ATT Aborting command as device "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" is no longer connected 
```


##Blocks Callback Design

### Scan
`found` - called whenever new peripheral is found   
`stop` - called when scan stops after specified interval


### Read / Write / Indication   

```
if(error) 
{
	// Handle error
}
else 
{
	// Do something
}
```

### Connect / Disconnect

```
if(error) 
{
	// Handle error
}
else 
{
	// Do something
}
```


##TODO

### Retrieve
・Retrive peripherals if exist   
・If intended peripherals cannot be retrieved, try to connect to designated peripheral with retry enabled.

