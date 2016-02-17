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
    @all_ratings = ['G' => 1, 'PG' => 1, 'PG-13' => 1, 'R' => 1]
    @title_class = ""
    @release_class = ""
    @movies = Movie.all
    if params[:ratings].nil? && not(session[:ratings].nil?)
      session_ratings = true
      selected_ratings = session[:ratings]
    end
    if params[:title].nil? && (not(params[:release_date].nil?) || not(session[:sortby].nil?))
      session_sort = true
      sorted_by = session[:sortby]
    end
    
    if to_redirect
      if session_ratings && session_sort
        if sorted_by == 'title'
          redirect_to movies_path(:ratings => selected_ratings, :title => true)
        elsif sorted_by == 'release'
          redirect_to movies_path(:ratings => selected_ratings, :release => true)
        end
      elsif session_sort
        if sorted_by == 'title'
          redirect_to movies_path(:title => true)
        elsif sorted_by == 'release'
          redirect_to movies_path(:release => true)
        end
      else
        redirect_to movies_path(:ratings => selected_ratings)
      end
    else
      if not(params[:ratings].nil?)
        @selected_ratings = params[:ratings]
      else
        @selected_ratings = @all_ratings
      end
      session[:ratings] = @selected_ratings
      @movies = @movies.where(rating: @selected_ratings.keys)
      if params[:title]
        @title_class = "hilite"
        @movies = @movies.order("title")
        session[:sortby] = 'title'
      elsif params[:release_date]
        @release_class = "hilite"
        @movies = @movies.order("release_date")
        session[:sortby] = 'release'
      end    
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
