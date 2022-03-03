
library(trailrun)


# Job 1 ------------------------------------------------------------------

# Pull all school trends data (update)

# Pull data at 11:30pm CST

schedule_r_run(r = "update_pull_school.R",
               schedule = "30 23 * * *",
               run_name = "update_gtrends_school_data")

