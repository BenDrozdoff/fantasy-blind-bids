# frozen_string_literal: true

ActiveAdmin.register User do
  menu false
  permit_params :email, :password, :password_confirmation
  controller do
    actions :all, except: %i(index show)
    def edit
      return head :unauthorized unless current_user.id == params[:id].to_i

      super
    end

    def update
      super do |success, failure|
        success.html { redirect_to admin_root_path }
        failure.html do
          redirect_to admin_root_path, flash: { error: @user.errors.values.join(", ") }
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.action :submit
  end
end
