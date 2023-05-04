ActiveAdmin.register User do
  permit_params :email, :password, :name

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :password
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end
end
