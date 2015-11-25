class ActivitiesController < ApplicationController

  def index
    #@activities = Activity.paginate :page => params[:page], :order => 'id'
  end

  def list
    term = params[:term] || ""
# Upgrade 2.0.0 inizio
=begin
    @activities = Activity.all(:select => "id, activity_en AS value",
    :conditions => "lower(activity_en) LIKE '#{term}%'",
    :order => 'activity_en')
=end
    @activities = Activity.select("id, activity_en AS value").
    where("lower(activity_en) LIKE '#{term}%'").
    order('activity_en')
# Upgrade 2.0.0 fine

    respond_to do |format|
      format.html
      format.json { render :json => @activities.map(&:attributes) }
    end
  end

end
