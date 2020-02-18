#!/bin/sh
#!/

#  AppleMoreDownload.sh
#  DeveloperToolsDownloader
#
#  Created by Vineet Choudhary on 17/02/20.
#  Copyright © 2020 Developer Insider. All rights reserved.

# $1 - aria2c
# $2 - Download Path
# $3 - Download Auth Token

$1 --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Upgrade-Insecure-Requests: 1' --header 'Cookie: ADCDownloadAuth='$3'' --header 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/10.0 Mobile/14B72 Safari/602.1' --header 'Accept-Language: en-us\' -x 16 -s 16 $2 -d ~/Downloads
