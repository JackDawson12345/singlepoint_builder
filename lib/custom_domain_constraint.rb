# lib/custom_domain_constraint.rb
class CustomDomainConstraint
  def matches?(request)
    return true if Rails.env.development? && request.host.include?('localhost')

    # Check if the request is for a custom domain (not your main Heroku domain)
    domain = request.host.downcase
    main_domains = [
      'https://single-point-commerce-c9fbd3b6fe59.herokuapp.com/',
      'yourmainsite.com'  # Add your main domain if you have one
    ]

    !main_domains.include?(domain) && Website.exists?(domain_name: domain)
  end
end