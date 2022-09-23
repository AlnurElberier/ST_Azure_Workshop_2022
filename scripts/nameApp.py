import json
import random


CONFIG_PATH     = 'C:\\STM32CubeExpansion_Cloud_AZURE_V2.0.1\\Projects\\B-U585I-IOT02A\\Applications\\TFM_Azure_IoT\\AzureScripts\\Config.json'
SUB             = 'y'
APP_NAME        = 'handson'
SSID            = 'st_iot_demo'
PSWD            = 'stm32u585'
RESOURCE_GROUP  = 'iot-demo'
LOCATION        = 'westus'





# Load credentials from the CONFIG_PATH into credentials dictionary
def loadCredentials(CONFIG_PATH):
    configFile = open(CONFIG_PATH)
    credentials = json.load(configFile)
    configFile.close()
    return credentials

# Update Credentials File
def writeCredentialsToFile(credentials, CONFIG_PATH):
    with open(CONFIG_PATH, 'w') as outfile:
        json.dump(credentials, outfile, indent=4)



def main():
    credentials = loadCredentials(CONFIG_PATH)

    credentials['Entered']['Subscription'] = SUB
    credentials['Entered']['AppName'] = APP_NAME + ''.join([str(random.randint(0, 999)).zfill(3) for _ in range(2)])
    credentials['Entered']['SSID'] = SSID
    credentials['Entered']['Password'] = PSWD
    credentials['Entered']['ResourceGroup'] = RESOURCE_GROUP
    credentials['Entered']['Location'] = LOCATION

    writeCredentialsToFile(credentials, CONFIG_PATH)



if __name__ == "__main__":
    main()