class DocumentFormsController < ApplicationController
  helper_method :sort_column
  load_and_authorize_resource

  def index
# Upgrade 2.0.0 inizio
=begin
    @document_forms = DocumentForm.accessible_by(current_ability, :read).
                      paginate(:page => params[:page], :order => sort_column + ' ' + sort_direction)
=end
    @document_forms = DocumentForm.accessible_by(current_ability, :read).order(sort_column + ' ' + sort_direction).page(params[:page])
# Upgrade 2.0.0 fine
  end

  def list
    search_param  = [params[:term], params[:q]].find(&:present?)
    document_forms  = DocumentForm.accessible_by(current_ability, :read).autocomplete_list(search_param)

    respond_to do |format|
      format.json { render :json => document_forms.map(&:attributes) }
    end
  end

  def show
    terms
    @document_form = DocumentForm.find(params[:id])
  end

  def new
    terms
    @document_form = DocumentForm.new

  end

  def edit
    terms
    @document_form = DocumentForm.find(params[:id])
  end

  def create
    terms
# Upgrade 2.0.0 inizio Strong parameters
#    @document_form = DocumentForm.new(params[:document_form]).tap do |document_form|
    @document_form = DocumentForm.new(document_form_params).tap do |document_form|
# Upgrade 2.0.0 fine
                      document_form.created_by = current_user.id
                      document_form.updated_by = current_user.id
                      document_form.group_id = current_user.group_id
                     end
    if @document_form.save
      redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda creata')
    else
      render :action => "new"
    end
  end

  def update
    @document_form = DocumentForm.find(params[:id])

# Upgrade 2.0.0 inizio Strong parameters
=begin
    if @document_form.update_attributes(params[:document_form])
      redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
=end
    if @document_form.update_attributes(document_form_params)
      redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda aggiornata')
    else
      render :action => "edit"
    end
# Upgrade 2.0.0 fine
  end

  def destroy
    @document_form = DocumentForm.find(params[:id])
    @document_form.destroy

    redirect_to(document_forms_url)
  end

  private

  def sort_column
    params[:sort] || "name"
  end

# Upgrade 2.0.0 inizio Strong parameters
  def document_form_params
    params.require(:document_form).permit!
  end
# Upgrade 2.0.0 fine

end

