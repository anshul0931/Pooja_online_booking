puts "⏳ Seeding Pooja Types..."

pooja_types = [
  { name: "Mangal Bhat Puja", description: "Manglik Dosh se sambandhit puja", price: 1000, duration: 60 },
  { name: "Panchamrit Abhishek", description: "Shiv ji ke liye pañch liquids se abhishek", price: 1500, duration: 45 },
  { name: "Laghu Rudrabhishek", description: "Shiv ji ka vishesh abhishek", price: 1200, duration: 40},
  { name: "Mahamrityunjaya Jaap", description: "Jeevan raksha ke liye mantra jaap", price: 2000, duration: 90 },
  { name: "Maa Baglamukhi Puja", description: "Shakti aur raksha ke liye", price: 1800, duration: 60 },
  { name: "Kaal Sarp Dosh Puja", description: "Grah dosh nivaran ke liye", price: 2500, duration: 120},
  { name: "Ark Vivah Puja", description: "Manglik dosh aur bandhan sambandhit kriya", price: 1500, duration: 60},
  { name: "Rin Mukti Puja", description: "Karz mukt hone ke liye", price: 2000, duration: 60}
]

pooja_types.each do |pt|
  PoojaType.find_or_create_by!(name: pt[:name]) do |pooja|
    pooja.description = pt[:description]
    pooja.price = pt[:price]
    pooja.duration = pt[:duration]
  end
end

puts "✅ Seeding completed successfully!"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?