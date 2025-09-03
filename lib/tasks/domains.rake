# lib/tasks/domains.rake
namespace :domains do
  desc "Add all website domains to Heroku"
  task add_all: :environment do
    Website.where.not(domain_name: nil).find_each do |website|
      domain = website.domain_name

      puts "Adding domain: #{domain}"

      # Add both www and non-www versions
      system("heroku domains:add #{domain}")
      system("heroku domains:add www.#{domain}")

      puts "Domain #{domain} added successfully"
    end

    puts "All domains processed!"
  end
end