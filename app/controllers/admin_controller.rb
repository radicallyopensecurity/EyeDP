# frozen_string_literal: true

class AdminController < ApplicationController # rubocop:disable Metrics/ClassLength
  # before_action :authenticate_user!
  before_action :ensure_user_is_admin!
  before_action :set_model, only: %i[show edit update destroy]
  # GET /admin/#{model}
  # GET /admin/#{model}.json
  def index
    @models = model
              .page(params[:page] || 1)
              .includes(includes)
              .order(order)
    @models = @models.where(filter) if filter
  end

  # GET /admin/#{model}/1
  # GET /admin/#{model}/1.json
  def show; end

  # GET /admin/#{model}/new
  def new
    @model = model.new
  end

  # GET /admin/#{model}/1/edit
  def edit; end

  # POST /admin/#{model}
  # POST /admin/#{model}.json
  def create
    @model = model.new(model_params)
    respond_to do |format|
      if @model.save
        format.html { redirect_to [:admin, @model], notice: "#{@model.class.name} was successfully created." }
        format.json { render :show, status: :created, location: [:admin, @model] }
      else
        format.html { render :new }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/#{model}/1
  # PATCH/PUT /admin/#{model}/1.json
  def update
    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to [:admin, @model], notice: "#{@model.class.name} was successfully updated." }
        format.json { render :show, status: :ok, location: [:admin, @model] }
      else
        format.html { render :edit }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/#{model}/1
  # DELETE /admin/#{model}/1.json
  def destroy
    @model.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @model.class], notice: "#{@model.class.name} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def model_attributes
    attrs = model.attribute_names
    attrs = whitelist_attributes if whitelist_attributes.any?
    attrs -= blacklist_attributes if blacklist_attributes.any?
    attrs
  end
  helper_method :model_attributes

  def whitelist_attributes
    []
  end

  def blacklist_attributes
    []
  end

  def includes
    []
  end

  def filter
    if filter_whitelist.include? params[:filter_by]
      { params[:filter_by] => params[:filter] }
    else
      {}
    end
  end

  def order # rubocop:disable Metrics/AbcSize
    sort = {
      sort_by: :created_at,
      sort_dir: :asc
    }
    sort[:sort_by] = params[:sort_by] if params[:sort_by] && sort_whitelist.include?(params[:sort_by])
    sort[:sort_dir] = params[:sort_dir] if params[:sort_dir] && %w[asc desc].include?(params[:sort_dir])
    { sort[:sort_by] => sort[:sort_dir] }
  end

  def filter_whitelist
    []
  end
  helper_method :filter_whitelist

  def sort_whitelist
    ['created_at']
  end
  helper_method :sort_whitelist

  def form_relations
    []
  end
  helper_method :form_relations

  def new_fields
    model.attribute_names
  end
  helper_method :new_fields

  def edit_fields
    new_fields
  end
  helper_method :edit_fields

  # Use callbacks to share common setup or constraints between actions.
  def set_model
    @model = model.find(params[:id])
  end

  def ensure_user_is_admin!
    raise(ActionController::RoutingError, 'Not Found') and return \
      unless current_user&.admin?
  end
end
