class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.getAllRatings
    @selRatingsHash = {}
    orderBy = params[:orderBy]
    selectedRatings = params[:ratings]
    if params[:commit] == "Refresh"
      if selectedRatings != nil
        selectedRatings = selectedRatings.keys
        @all_ratings.each do |rating|
          if selectedRatings.include?(rating)
            @selRatingsHash[rating] = true
          else
            @selRatingsHash[rating] = false
          end
        end
      else
        @all_ratings.each { |rating| @selRatingsHash[rating] = false }
      end
    else
      if flash[:selRatings] != nil
        @selRatingsHash = flash[:selRatings]
        selectedRatings = @selRatingsHash.reject { |key, value| value == false }.keys
      end
    end
        
    @movies = Movie.getOrderedMoviesByRating(selectedRatings, orderBy)
    flash[:selRatings] = @selRatingsHash
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
