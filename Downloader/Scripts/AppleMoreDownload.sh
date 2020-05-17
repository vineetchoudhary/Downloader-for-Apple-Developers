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

$1 --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Upgrade-Insecure-Requests: 1' --header 'Cookie: ADCDownloadAuth='$3'' --header 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15' --header 'Accept-Language: en-us\' -x 16 -s 16 $2 -d ~/Downloads --summary-interval=1
