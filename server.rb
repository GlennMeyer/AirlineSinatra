require 'sinatra'
require 'pg'
require 'sinatra/reloader'

set :bind, '0.0.0.0'

get '/' do
  db = PG.connect(host: 'localhost', dbname: 'on_time_performance')

  # How many different airlines are represented in this dataset?

  qone = <<-SQL
    SELECT COUNT(DISTINCT carrier)
    FROM on_time_performance;
  SQL

  @carriers = db.exec(qone)

  # Which airline had the largest quantity of delayed arriving flights? Which had the fewest?

  qtwo = <<-SQL
    SELECT count(ARR_DELAY_NEW) AS count, CARRIER
    FROM on_time_performance
    WHERE DEP_DELAY_NEW > 0
    OR ARR_DELAY_NEW > 0
    GROUP BY CARRIER
    ORDER BY count DESC;
  SQL

  @carrierdelays = db.exec(qtwo)

  # Which departing airport had the highest number of delayed flights? Which had the fewest?

  qthree = <<-SQL
    SELECT count(DEP_DELAY_NEW), ORIGIN_CITY_NAME
    FROM on_time_performance
    WHERE DEP_DELAY_NEW > 0
    GROUP BY ORIGIN_CITY_NAME
    ORDER BY count desc;
  SQL

  @departeddelays = db.exec(qthree)

  # Which arriving airport had the highest number of delayed flights? Which had the fewest?

  qfour = <<-SQL
    SELECT count(ARR_DELAY_NEW), DEST_CITY_NAME
    FROM on_time_performance
    GROUP BY DEST_CITY_NAME
    ORDER BY count desc;
  SQL

  @arrivingdelays = db.exec(qfour)

  # What was the average number of minutes late across all airlines?

  qfive = <<-SQL
    SELECT ( (AVG(ARR_DELAY_NEW) + AVG(DEP_DELAY_NEW) ) / 2 ) AS average_minutes_late
    FROM on_time_performance;
  SQL

  @averagemin = db.exec(qfive)

  # What was the average number of minutes late for each airline?
  
  qsix = <<-SQL
    SELECT CARRIER, ( AVG(ARR_DELAY_NEW) + AVG(DEP_DELAY_NEW) ) / 2 AS average_minutes_late
    FROM on_time_performance
    GROUP BY CARRIER
    ORDER BY average_minutes_late desc;
  SQL

  @avglateairlines = db.exec(qsix)

  erb :airlines
end
