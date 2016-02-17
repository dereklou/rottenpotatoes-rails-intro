class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :ratings, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G', 'PG', 'PG-13', 'R']
    @title_class = ""
    @release_class = ""
    @movies = Movie.all
    if params[:ratings].nil?
      if session[:ratings].nil?
        session[:ratings] = @all_ratings
      end
      @selected_ratings = session[:ratings]
    else
      @selected_ratings = params[:ratings].keys
      session[:ratings] = @selected_ratings
    end
    @movies = @movies.where(rating: @selected_ratings)
    if params[:title]
      @title_class = "hilite"
      @movies = @movies.order("title")
      session[:sortby] = 'title'
    elsif params[:release_date]
      @release_class = "hilite"
      @movies = @movies.order("release_date")
      session[:sortby] = 'release'
    elsif session[:sortby] == 'title'
      @title_class = "hilite"
      @movies = @movies.order("title")
    elsif session[:sortby] == 'release'
      @release_class = "hilite"
      @movies = @movies.order("release_date")
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
