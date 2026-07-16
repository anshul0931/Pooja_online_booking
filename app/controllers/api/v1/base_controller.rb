module Api
  module V1
    class BaseController < ActionController::API
      # API controllers inherit from ActionController::API which doesn't include CSRF protection.
      # This keeps the API stateless and doesn't affect the HTML application views.

      # Includes Rails routes url_helpers for generating Active Storage URLs
      include Rails.application.routes.url_helpers

      private

      def puja_image_url(puja)
        if puja.image.attached?
          rails_blob_url(puja.image)
        else
          filename = local_image_for_puja(puja.title)
          ActionController::Base.helpers.asset_url(filename)
        end
      end

      def temple_image_url(temple)
        filename = local_image_for_temple(temple.name)
        ActionController::Base.helpers.asset_url(filename)
      end

      def local_image_for_puja(title)
        t = title.to_s.downcase
        if t.include?("kaal sarp") || t.include?("kalsarp")
          "kalsarp.webp"
        elsif t.include?("mangal") || t.include?("bhat") || t.include?("ark") || t.include?("vivah")
          "ganeshji.webp"
        elsif t.include?("abhishek") || t.include?("rudrabhishek") || t.include?("mrityunjaya") || t.include?("mahamrityunjaya") || t.include?("shiv")
          "Mahakaleshwar.webp"
        elsif t.include?("pitru") || t.include?("shradh") || t.include?("pind") || t.include?("pin_daan") || t.include?("pinda")
          "pin_daan.webp"
        elsif t.include?("rin") || t.include?("mukti")
          "Shree-Mahakaleshwar-Temple.webp"
        else
          "ganeshji.webp"
        end
      end

      def local_image_for_temple(name)
        n = name.to_s.downcase
        if n.include?("mahakal") || n.include?("mahakaleshwar")
          "Shree-Mahakaleshwar-Temple.webp"
        elsif n.include?("ganesh") || n.include?("chintaman")
          "ganeshji.webp"
        else
          "Mahakaleshwar.webp"
        end
      end
    end
  end
end
