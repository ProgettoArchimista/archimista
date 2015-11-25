class PlacesController < ApplicationController

  def index
# Upgrade 2.0.0 inizio
=begin
    @places = Place.paginate(:page => params[:page],
      :conditions => "qualifier = 'comune'",
      :order => "display_name")
=end
    @places = Place.where("qualifier = 'comune'").order("display_name").page(params[:page])
# Upgrade 2.0.0 fine
  end
=begin
  def list
    term = params[:term] || ""
    @places = Place.all(:select => "id, display_name AS value",
                        :conditions => "lower(display_name) LIKE '#{term}%'",
                        :order => 'display_name',
                        :limit => 10)

    respond_to do |format|
      format.json { render :json => @places.map(&:attributes) }
    end
  end
=end
  def cities
    term = params[:term] || ""
    @places = Place.search(term, 'display_name').by_qualifier('comune').list('display_name')
    respond_to do |format|
      format.json { render :json => @places.map(&:attributes) }
    end
  end

  def countries
    term = params[:term] || ""
    @places = Place.search(term, 'name').by_qualifier('nazione').list('name')
    respond_to do |format|
      format.json { render :json => @places.map(&:attributes) }
    end
  end

  def show
    @place = Place.find(params[:id])
  end

  def new
    @place = Place.new
  end

  def edit
    @place = Place.find(params[:id])
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @place = Place.new(params[:place])
    @place = Place.new(place_params)
# Upgrade 2.0.0 fine

    if @place.save
      redirect_to(@place, :notice => 'Scheda creata')
    else
      render :action => "new"
    end
  end

  def update
    @place = Place.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @place.update_attributes(params[:place])
      redirect_to(@place, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
=end
    if @place.update_attributes(place_params)
      redirect_to(@place, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    redirect_to(places_url)
  end

# Upgrade 2.0.0 inizio Strong parameters
  private

  def place_params
    params.require(:place).permit!
  end
# Upgrade 2.0.0 fine

end
