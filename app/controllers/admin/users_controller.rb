# frozen_string_literal: true

class Admin::UsersController < AdminController
  def create
    super
    @model.send_admin_welcome_email if @model.persisted?
  end

  def reset_password
    @model = User.find(params[:user_id])
    respond_to do |format|
      if @model.force_password_reset!
        format.html { redirect_to [:admin, @model], notice: "#{@model.class.name} was successfully updated." }
        format.json { render :show, status: :ok, location: [:admin, @model] }
      else
        format.html { render :edit }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # def model_attributes
  #   model.attribute_names - ['id', 'created_at', 'updated_at', 'encrypted_password']
  # end

  def includes
    [:groups]
  end

  def whitelist_attributes
    %w[email name username groups expires_at last_activity_at]
  end

  def model
    User
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def model_params
    p = params.require(:user).permit(
      :email, :username, :email, :name, :expires_at,
      :password, :last_activity_at, group_ids: []
    )
    p[:group_ids] ||= []
    p.delete(:password) if p[:password] && p[:password].empty?
    p
  end

  def sort_whitelist
    %w[created_at username email]
  end

  def filter_whitelist
    %w[username email]
  end

  def filter
    if filter_whitelist.include? params[:filter_by]
      users = User.arel_table
      users[params[:filter_by]].matches("%#{params[:filter]}%")
    else
      {}
    end
  end
end
