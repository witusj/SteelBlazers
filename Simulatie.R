library(dplyr)
library(simmer)
source("Processen/Calculatie.R")

set.seed(1014)

customer <- 
  create_trajectory("Customer's path") %>%
  simmer::select(c("counter1", "counter2"), policy = "shortest-queue") %>%
  seize_selected %>%
  timeout(function() {rexp(1, 1/12)}) %>%
  release_selected

bank <- 
  simmer("bank") %>% 
  add_resource("counter1", 1) %>%
  add_resource("counter2", 1) %>%
  add_generator("Customer", customer, function() {c(0, rexp(4, 1/10), -1)})

bank %>% run(until = 400) 

bank %>% 
  get_mon_arrivals %>%
  mutate(service_start_time = end_time - activity_time) %>%
  arrange(start_time)

bank %>% 
  get_mon_resources %>%
  arrange(time)