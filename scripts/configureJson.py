# ******************************************************************************
# * @file    configureJson.py
# * @author  MCD Application Team
# * @brief   Configure the Config.json file
# ******************************************************************************
# * @attention
# *
# * <h2><center>&copy; Copyright (c) 2022 STMicroelectronics.
# * All rights reserved.</center></h2>
# *
# * This software component is licensed by ST under BSD 3-Clause license,
# * the "License"; You may not use this file except in compliance with the
# * License. You may obtain a copy of the License at:
# *                        opensource.org/licenses/BSD-3-Clause
# *
# ******************************************************************************
import json
import random


CONFIG_PATH     = 'C:\\STM32CubeExpansion_Cloud_AZURE_V2.1.0\\Projects\\B-U585I-IOT02A\\Applications\\TFM_Azure_IoT\\AzureScripts\\Config.json'
SUB             = 'y'
APP_NAME        = 'devcon'
SSID            = 'st_iot_demo'
PSWD            = 'stm32u585'
RESOURCE_GROUP  = 'devcon'
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
    credentials['Entered']['AppName'] = APP_NAME + '-' + ''.join([str(random.randint(0, 999)).zfill(3) for _ in range(2)])
    credentials['Entered']['SSID'] = SSID
    credentials['Entered']['Password'] = PSWD
    credentials['Entered']['ResourceGroup'] = RESOURCE_GROUP
    credentials['Entered']['Location'] = LOCATION

    writeCredentialsToFile(credentials, CONFIG_PATH)



if __name__ == "__main__":
    main()