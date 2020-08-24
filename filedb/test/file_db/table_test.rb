require 'test_helper'

class FileDb::TableTest < Minitest::Test
  def setup
    @db = FileDb::Database.new('fixtures/data.json')
    @movies = @db.table("movies")
  end
  
  def test_select_returns_all_movies
    movies_list = @db.database['movies'].map{|movie| movie.transform_keys(&:to_sym)}
    assert_equal(movies_list, @movies.select)
  end

  def test_select_with_where_params
    assert_equal([{ id: 1, title: "The Gold Rush", year:1925, director_id:1 }], @movies.select(where: { id: 1 }))
    assert_equal([
      {
        "id":1,
        "title":"The Gold Rush",
        "year":1925,
        "director_id":1
      },
      {
        "id":2,
        "title":"City Lights",
        "year":1931,
        "director_id":1
      },
      {
        "id":4,
        "title":"Modern Times",
        "year":1936,
        "director_id":1
      }
    ], @movies.select(where: { director_id: 1 }))
    assert_equal([{ id: 1, title: "The Gold Rush", year:1925, director_id:1 }], @movies.select(where: {director_id: 1, year: 1925}))
  end

  def test_where
    assert_equal([{ id: 1, title: "The Gold Rush", year:1925, director_id:1 }], @movies.where(id: 1))
    assert_equal([{ id: 1, title: "The Gold Rush", year:1925, director_id:1 }], @movies.where(director_id: 1, year: 1925))
  end

  def test_insert
    @movies.insert({ title: "Birds", year: 1962, director_id: 2 })
    assert_equal({ id: 7, title: "Birds", year: 1962, director_id: 2 }, @movies.table.last)

    @movies.find(7).delete
  end

  def test_update
    @movies.insert({ title: "Birds", year: 1962, director_id: 2 })

    @movies.find(7).update(year: 1963)
    assert_equal({ id: 7, title: "Birds", year: 1963, director_id: 2 }, @movies.table.last)
    @movies.find(7).update(year: 1964, title: 'caca')
    assert_equal({ id: 7, title: "caca", year: 1964, director_id: 2 }, @movies.table.last)

    @movies.find(7).delete
  end

  def test_delete
    @movies.insert({ title: "Birds", year: 1962, director_id: 2 })

    @movies.find(7).delete
    refute_includes(@movies.table, { id: 7, title: "Birds", year: 1962, director_id: 2 })
  end

  def test_joins
    assert_equal("Charlie Chaplin", @movies.joins(:director).first[:name])
  end
end
