class DocumentFormsController < ApplicationController
  helper_method :sort_column
  load_and_authorize_resource

# Upgrade 2.2.0 inizio
  def current_ability
    if @current_ability.nil?
      if (current_user.is_multi_group_user?())
        if (["show","edit","update","destroy"].include?(params[:action]))
          d = DocumentForm.find(params[:id])
          @current_ability ||= Ability.new(current_user, d.group_id)
        elsif (["list"].include?(params[:action]))
          group_id = str2int(params[:group_id])
          @current_ability ||= Ability.new(current_user, group_id)
        elsif (["index"].include?(params[:action]))
          @current_ability ||= Ability.new(current_user, -1)
        elsif (["new","create"].include?(params[:action]))
          if params[:group_id].present?
            group_id = str2int(params[:group_id])
            @current_ability ||= Ability.new(current_user, group_id)
          end
        end
      end
    end
    if @current_ability.nil?
      @current_ability = super
    end
    return @current_ability
  end
# Upgrade 2.2.0 fine

  def index
# Upgrade 2.0.0 inizio
=begin
    @document_forms = DocumentForm.accessible_by(current_ability, :read).
                      paginate(:page => params[:page], :order => sort_column + ' ' + sort_direction)
=end
# Upgrade 2.2.0 inizio
#    @document_forms = DocumentForm.accessible_by(current_ability, :read).order(sort_column + ' ' + sort_direction).page(params[:page])
    @document_forms = DocumentForm.list.accessible_by(current_ability, :read).order(sort_column + ' ' + sort_direction).page(params[:page])
# Upgrade 2.2.0 fine
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
# Upgrade 2.2.0 inizio
#      document_form.group_id = current_user.group_id
      if current_user.is_multi_group_user?()
        document_form.group_id = current_ability.target_group_id
      else
        document_form.group_id = current_user.rel_user_groups[0].group_id
      end
# Upgrade 2.2.0 fine
    end
    if @document_form.save
# Upgrade 2.2.0 inizio
#      redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda creata')
      if params[:save_and_continue]
        redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda creata')
      else
        redirect_to(@document_form, :notice => 'Scheda creata')
      end
# Upgrade 2.2.0 fine
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
# Upgrade 2.2.0 inizio
#      redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda aggiornata')
      if params[:save_and_continue]
        redirect_to(edit_document_form_url(@document_form), :notice => 'Scheda aggiornata')
      else
        redirect_to(@document_form, :notice => 'Scheda aggiornata')
      end
# Upgrade 2.2.0 fine
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
# Upgrade 2.2.0 inizio
#    params[:sort] || "name"
    params[:sort] || "document_forms.name"
# Upgrade 2.2.0 fine
  end

# Upgrade 2.0.0 inizio Strong parameters
  def document_form_params
    params.require(:document_form).permit!
  end
# Upgrade 2.0.0 fine

end

