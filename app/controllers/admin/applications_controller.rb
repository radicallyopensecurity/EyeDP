# frozen_string_literal: true

class Admin::ApplicationsController < AdminController
  private

  def model_attributes
    %w[name display_url uid internal secret redirect_uri scopes confidential]
  end

  def new_fields
    %w[name display_url uid internal secret redirect_uri scopes confidential]
  end

  def model
    Application
  end

  def model_params
    params.require('application').permit(
      :name, :display_url, :uid, :internal, :secret, :scopes,
      :redirect_uri, :confidential
    )
  end
end
