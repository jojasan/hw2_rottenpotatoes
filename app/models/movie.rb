class Movie < ActiveRecord::Base
  def Movie.getAllRatings
    ratings = Movie.all(:select => 'DISTINCT rating')
    strResults = []
    ratings.each { |record| strResults << record.rating }
    return strResults
  end

  # Returns all the movies that match the ratings (tested with array of ratings) ordered by the parameter given
  def Movie.getOrderedMoviesByRating(ratings, orderBy)
    if orderBy == nil
      return Movie.where(["rating IN (?)", ratings]).all
    else
      return Movie.where(["rating IN (?)", ratings]).all(:order => orderBy)
    end
  end
end
