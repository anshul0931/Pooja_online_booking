ActiveAdmin.register CustomBooking do
  permit_params :user_name, :phone, :email, :gotra, :seva_description, :status, :preferred_date, :location

  index do
    selectable_column
    id_column
    column :user_name
    column :phone
    column :email
    column :gotra
    column :preferred_date
    column :location
    column :status
    column :created_at
    actions
  end

  filter :user_name
  filter :email
  filter :phone
  filter :status
  filter :preferred_date

  form do |f|
    f.inputs do
      f.input :user_name
      f.input :phone
      f.input :email
      f.input :gotra
      f.input :seva_description, as: :text, input_html: { rows: 5 }
      f.input :preferred_date, as: :datepicker
      f.input :location
      f.input :status, as: :select, collection: ["pending", "contacted", "confirmed", "rejected"]
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user_name
      row :phone
      row :email
      row :gotra
      row :seva_description
      row :preferred_date
      row :location
      row :status
      row :created_at
      row :updated_at
    end
  end
end
