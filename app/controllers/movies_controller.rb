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
    
    # This case is for when the user goes to /movies without any parameter. I decided to show all movies (although no rating is selected)
    if params[:ratings] == nil and params[:orderBy] == nil and params[:commit] == nil
      # If there's data in session about the current search settings, then redirect with correct parameters
      if session[:searchSettings] != nil
        orderBy = session[:searchSettings][:orderBy]
        selectedRatings = session[:searchSettings][:selectedRatings]
        redirect_to movies_path({ :orderBy => orderBy, :ratings => selectedRatings })
        return
      # Else, just show all movies
      else
        @movies = Movie.all
        @all_ratings.each { |rating| @selRatingsHash[rating] = false }
        return
      end
    end
    
    selectedRatings = params[:ratings]
    if params[:commit] == "Refresh"
      if selectedRatings != nil
        # Only Selected Ratings appear as keys in the hash, their values are irrelevant (= to 1)
        selectedRatings = selectedRatings.keys
        @all_ratings.each do |rating|
          if selectedRatings.include?(rating)
            @selRatingsHash[rating] = true
          else
            @selRatingsHash[rating] = false
          end
        end
      else
        # This case is for when the user unchecks all ratings, since the params[:ratings] is nil
        @all_ratings.each { |rating| @selRatingsHash[rating] = false }
      end
    else
      # In this case, the hash has all the ratings, but the ones chosen have as value true (false otherwise)
      # I noticed that the values of the hash came as String, and NOT as boolean
      selectedRatings.each do |key, value|
        if value == "false"
          @selRatingsHash[key] = false
        else
          @selRatingsHash[key] = true
        end
      end
      selectedRatings.reject! { |key, value| value == "false" }
      selectedRatings = selectedRatings.keys
    end
    
    @movies = Movie.getOrderedMoviesByRating(selectedRatings, orderBy)
    # This line saves the current orderBy and selectedRagins settings
    session[:searchSettings] = { :orderBy => orderBy, :selectedRatings => @selRatingsHash}
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
