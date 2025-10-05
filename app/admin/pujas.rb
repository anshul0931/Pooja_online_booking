ActiveAdmin.register Puja do
  permit_params :title, :description, :duration_minutes, :base_price, :image

  index do
    selectable_column
    id_column
    column :title
    column :base_price
    column :duration_minutes
    column "Image" do |puja|
      if puja.image.attached?
        image_tag url_for(puja.image), width: 80
      end
    end
    actions
  end

  form do |f|
    f.inputs "Puja Details" do
      f.input :title
      f.input :description
      f.input :duration_minutes
      f.input :base_price
      f.input :image, as: :file, hint: (f.object.image.attached? ? image_tag(url_for(f.object.image), width: 100) : content_tag(:span, "No image yet"))
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :description
      row :duration_minutes
      row :base_price
      row :image do |puja|
        image_tag url_for(puja.image), width: 200 if puja.image.attached?
      end
    end
  end
end
