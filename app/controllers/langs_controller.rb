class LangsController < ApplicationController

  def index
# Upgrade 2.0.0 inizio
#    @langs = Lang.paginate(:page => params[:page], :order => "active DESC, code ASC")
    @langs = Lang.order("active DESC, code ASC").page(params[:page])
# Upgrade 2.0.0 fine
  end

  def show
    @lang = Lang.find(params[:id])
  end

  def new
    @lang = Lang.new
  end

  def edit
    @lang = Lang.find(params[:id])
  end

  def create
# Upgrade 2.0.0 inizio Strong parameters
#    @lang = Lang.new(params[:lang])
    @lang = Lang.new(lang_params)
# Upgrade 2.0.0 fine

    if @lang.save
      redirect_to(@lang, :notice => 'Scheda creata')
    else
      render :action => "new"
    end
  end

  def update
    @lang = Lang.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @lang.update_attributes(params[:lang])
      redirect_to(@lang, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
=end
    if @lang.update_attributes(lang_params)
      redirect_to(@lang, :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @lang = Lang.find(params[:id])
    @lang.destroy

    redirect_to(langs_url)
  end

# Upgrade 2.0.0 inizio Strong parameters
  private

  def lang_params
    params.require(:lang).permit!
  end
# Upgrade 2.0.0 fine

end
