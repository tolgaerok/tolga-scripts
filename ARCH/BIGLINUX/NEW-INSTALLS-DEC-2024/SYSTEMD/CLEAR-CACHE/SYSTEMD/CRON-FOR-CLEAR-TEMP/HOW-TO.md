# Cron Job to Run Periodically

> Metadata
> ----------------------------------------------------------------
> AUTHOR="Tolga Erok"
> VERSION="1"
> DATE_CREATED="21/12/2024"
>

## Setup
#


To run the script every day at 3 AM, for example:

    Open Crontab Editor:

    crontab -e

Add the Following Line:

0 3 * * * ~/clear_temp_slowdowns.sh
