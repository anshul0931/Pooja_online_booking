ActiveAdmin.register Booking do
  # ✅ Permit the correct attributes
  permit_params :puja_id, :user_name, :phone, :email, :samagri_required,
                :package, :status, :notes, :location, :booking_date, :customer_type,
                :address, :total_price, :payment_method

  # ✅ Index page
  index do
    selectable_column
    id_column
    column :puja  # previously pooja_type
    column :user_name
    column :phone
    column :email
    column :customer_type
    column :payment_method
    column :status
    column :total_price
    column :booking_date
    actions
  end

  # ✅ Filters
  filter :puja
  filter :user_name
  filter :email
  filter :status
  filter :customer_type
  filter :payment_method
  filter :booking_date

  # ✅ Form for creating/editing bookings
  form do |f|
    f.inputs do
      f.input :puja  # previously pooja_type
      f.input :user_name
      f.input :phone
      f.input :email
      f.input :customer_type, as: :select, collection: ["Indian", "NRI"]
      f.input :payment_method, as: :select, collection: ["Cash on Pooja", "Bank Transfer", "UPI"]
      f.input :samagri_required
      f.input :location
      f.input :booking_date, as: :datepicker
      f.input :total_price
      f.input :status, as: :select, collection: ["pending", "confirmed", "cancelled"]
      f.input :notes
    end
    f.actions
  end

  # ✅ Show page
  show do
    attributes_table do
      row :id
      row :puja  # previously pooja_type
      row :user_name
      row :phone
      row :email
      row :customer_type
      row :payment_method
      row :samagri_required
      row :location
      row :booking_date
      row :total_price
      row :status
      row :notes
      row :created_at
      row :updated_at
    end
  end
end
