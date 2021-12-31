# подключение библиотек
library(Robyn)
library(reticulate)
set.seed(123)

# force multicore when using RStudio
Sys.setenv(R_FUTURE_FORK_ENABLE="true")
options(future.fork.enable = TRUE)

#load data
dt_simulated_weekly <- read.table("~/test_data.csv", header=T, sep=";")

## Check holidays from Prophet
data("dt_prophet_holidays")

## Set robyn_object. It must have extension .RDS. The object name can be different than Robyn:
robyn_object <- "~/out_data/MyRobyn.RDS"

# model init
cols <- colnames(dt_simulated_weekly)
paid_media_vars <- cols[grepl("_i$", cols)]
hyperparameters <- list()
{for(i in paid_media_vars)
{hyperparameters[[paste(i,'_alphas', sep="")]][1:2] <- c(0.5, 3)
hyperparameters[[paste(i,'_gammas', sep="")]][1:2] <- c(0.3, 1)
hyperparameters[[paste(i,'_shapes', sep="")]][1:2] <- c(0.0001, 10)
hyperparameters[[paste(i,'_scales', sep="")]][1:2] <- c(0, 0.1)
}}

InputCollect <- robyn_inputs(
  dt_input = dt_simulated_weekly
  ,dt_holidays = dt_prophet_holidays
  ,date_var = "af_date"
  ,dep_var = "revenue"
  ,dep_var_type = "conversion"
  ,prophet_vars = c("trend", "season", "weekday", "holiday")
  ,prophet_signs = c("default","default", "default", "default")
  ,prophet_country = "RU"
  ,paid_media_vars = paid_media_vars
  ,paid_media_spends = cols[grepl("_s$", cols)]
  ,cores = 6
  ,adstock = "weibull_pdf"
  ,iterations = 6000
  ,nevergrad_algo = "TwoPointsDE"
  ,trials = 5
  ,hyperparameters = hyperparameters
)

OutputCollect <- robyn_run(
  InputCollect = InputCollect
  , plot_folder = robyn_object
  , pareto_fronts = 5
  , plot_pareto = TRUE
)
pngs <- OutputCollect$allSolutions
minimum <- 0
{for(i in pngs)
  {AllocatorCollect <- robyn_allocator(
    InputCollect = InputCollect
    , OutputCollect = OutputCollect
    , optim_algo = "MMA_AUGLAG"
    , select_model = i
    , scenario = "max_historical_response"
    , channel_constr_low = rep(0.5, length(paid_media_vars))
    , channel_constr_up = rep(2, length(paid_media_vars))
  )
  if(AllocatorCollect$dt_optimOut$optmResponseUnitTotalLift[1]>minimum)
    {minimum <- AllocatorCollect$dt_optimOut$optmResponseUnitTotalLift[1]
    exp <- i
  }}
print(minimum)
print(exp)}
to_remove = list.files(OutputCollect$plot_folder)
to_remove <- to_remove[!grepl(exp, to_remove) & to_remove!="spend_exposure_fitting.png" ]
file.remove(paste(OutputCollect$plot_folder,to_remove,sep=''))
