require 'sinatra'
require 'pg'
require 'sinatra/reloader'

set :bind, '0.0.0.0'

get '/' do  
  erb :index
end

get '/airlines' do
  db = PG.connect(host: 'localhost', dbname: 'on_time_performance')

  qone = <<-SQL
    SELECT COUNT(DISTINCT carrier)
    FROM on_time_performance;
  SQL

  @carriers = db.exec(qone)
  # @carriers.each {|x| puts x}

  qtwo = <<-SQL
    SELECT count(DEP_DELAY_NEW) + count(ARR_DELAY_NEW) AS count, CARRIER
    FROM on_time_performance
    WHERE DEP_DELAY_NEW > 0
    OR ARR_DELAY_NEW > 0
    GROUP BY CARRIER
    ORDER BY count DESC;
  SQL

  @mostleast = db.exec(qtwo)
  # @mostleast.each {|x| puts x}

  qthree = <<-SQL
    SELECT count(DEP_DELAY_NEW), ORIGIN_CITY_NAME
    FROM on_time_performance
    WHERE DEP_DELAY_NEW > 0
    GROUP BY ORIGIN_CITY_NAME
    ORDER BY count desc;
  SQL

  @departeddelays = db.exec(qthree)

  qfour = <<-SQL
    SELECT count(ARR_DELAY_NEW), DEST_CITY_NAME
    FROM on_time_performance
    GROUP BY DEST_CITY_NAME
    ORDER BY count desc;
  SQL

  @arrivingdelays = db.exec(qfour)

  qfive = <<-SQL
    SELECT ( (AVG(ARR_DELAY_NEW) + AVG(DEP_DELAY_NEW) ) / 2 ) AS average_minutes_late
    FROM on_time_performance;
  SQL

  @averagemin = db.exec(qfive)

  qsix = <<-SQL
    SELECT CARRIER, ( SUM(ARR_DELAY_NEW) + SUM(DEP_DELAY_NEW) ) / ( COUNT(ARR_DELAY_NEW) + COUNT(DEP_DELAY_NEW) ) AS average_minutes_late
    FROM on_time_performance
    GROUP BY CARRIER
    ORDER BY average_minutes_late desc;
  SQL

  @avglateairlines = db.exec(qsix)

  erb :airlines
end
