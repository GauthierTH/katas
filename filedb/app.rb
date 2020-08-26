require_relative 'lib/file_db'

class App
  def call(env)
    method = env['REQUEST_METHOD']
    path = env['REQUEST_PATH']
    body = JSON.parse(Rack::Request.new(env).body.read) if Rack::Request.new(env).body.read != ''

    db = FileDb::Database.new('fixtures/data.json')
    movies = db.table("movies")

    if method == 'GET' && path == '/movies'
      ['200', {"Content-Type" => 'application/json'}, [movies.table.to_json]]
    elsif method == 'GET' && path.match?(/movies/)
      id = path.split("/movies/").last.to_i
      movie = movies.find(id)
      ['200', {"Content-Type" => 'application/json'}, [movie.row.to_json]]
    elsif method == 'PUT' && path.match?(/movies/)
      id = path.split("/movies/").last.to_i
      movie = movies.find(id).update(body)
      ['200', {"Content-Type" => 'application/json'}, [movie.to_json]]
    elsif method == 'POST' && path == '/movies'
      movie = movies.insert(body)
      ['200', {"Content-Type" => 'application/json'}, [movie.to_json]]
    elsif method == 'DELETE' && path.match?(/movies/)
      id = path.split("/movies/").last.to_i
      movie = movies.find(id).delete
      ['200', {"Content-Type" => 'application/json'}, [movie.to_json]]
    end
  end
end
